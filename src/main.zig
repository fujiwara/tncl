const std = @import("std");

pub fn main() !void {
    const opt = try getOptionsFromArgs();
    var server = try opt.address.listen(.{ .reuse_address = true });
    std.log.info("listening on {}...", .{opt.address});

    var client = try server.accept();
    std.log.info("accepted connection from {}", .{client.address});
    defer client.stream.close();

    var sender_thread = try std.Thread.spawn(.{}, sender, .{&client.stream});
    var receiver_thread = try std.Thread.spawn(.{}, receiver, .{&client.stream});

    sender_thread.join();
    receiver_thread.join();
}

fn receiver(stream: *std.net.Stream) !void {
    const stdout = std.io.getStdOut().writer();
    const reader = stream.reader();
    while (true) {
        var buffer: [4096]u8 = undefined;
        const read_bytes = try reader.read(buffer[0..]);
        if (read_bytes == 0) {
            std.log.info("client closed connection", .{});
            // client closed connection
            std.process.exit(0);
        }
        try stdout.writeAll(buffer[0..read_bytes]);
    }
}

fn sender(stream: *std.net.Stream) !void {
    const stdin = std.io.getStdIn().reader();
    while (true) {
        var buffer: [4096]u8 = undefined;
        const read_bytes = try stdin.read(buffer[0..]);
        if (read_bytes == 0) {
            std.log.info("stdin closed", .{});
            // stdin closed
            std.process.exit(0);
        }
        try stream.writeAll(buffer[0..read_bytes]);
    }
}

const Options = struct {
    address: std.net.Address,
};

const ParseAddressError = error{
    MissingArgument,
    InvalidPort,
};

fn parseAddress(arg: []const u8) ParseAddressError!std.net.Address {
    // Try parsing as port number only (backward compatible)
    if (std.fmt.parseInt(u16, arg, 10)) |port| {
        if (port == 0) return ParseAddressError.InvalidPort;
        return std.net.Address.initIp4(.{ 0, 0, 0, 0 }, port);
    } else |_| {}

    // Try parsing as addr:port
    if (std.mem.lastIndexOfScalar(u8, arg, ':')) |colon_pos| {
        const host = arg[0..colon_pos];
        const port_str = arg[colon_pos + 1 ..];
        const port = std.fmt.parseInt(u16, port_str, 10) catch return ParseAddressError.InvalidPort;
        if (port == 0) return ParseAddressError.InvalidPort;
        return std.net.Address.resolveIp(host, port) catch return ParseAddressError.InvalidPort;
    }

    return ParseAddressError.InvalidPort;
}

fn getOptionsFromArgs() !Options {
    var args = std.process.args();
    _ = args.next(); // cmd name is not used
    const arg = args.next() orelse return ParseAddressError.MissingArgument;
    const address = try parseAddress(arg);
    return .{ .address = address };
}

pub const std_options: std.Options = .{
    // Set the log level to info
    .log_level = .info,
};

const testing = std.testing;

fn expectAddress(expected: []const u8, addr: std.net.Address) !void {
    var buf: [64]u8 = undefined;
    const actual = std.fmt.bufPrint(&buf, "{}", .{addr}) catch unreachable;
    try testing.expectEqualStrings(expected, actual);
}

test "parseAddress: port only" {
    const addr = try parseAddress("8080");
    try expectAddress("0.0.0.0:8080", addr);
}

test "parseAddress: addr:port IPv4" {
    const addr = try parseAddress("127.0.0.1:8080");
    try expectAddress("127.0.0.1:8080", addr);
}

test "parseAddress: 0.0.0.0:443" {
    const addr = try parseAddress("0.0.0.0:443");
    try expectAddress("0.0.0.0:443", addr);
}

test "parseAddress: port 0 is invalid" {
    try testing.expectError(ParseAddressError.InvalidPort, parseAddress("0"));
}

test "parseAddress: invalid string" {
    try testing.expectError(ParseAddressError.InvalidPort, parseAddress("invalid"));
}
