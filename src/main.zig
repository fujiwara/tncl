const std = @import("std");
const default_port = 12345;

pub fn main() !void {
    const port = try getPortFromArgs();
    const addr = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, port);
    var server = try addr.listen(.{ .reuse_address = true });
    std.log.info("Listening on port {d}...", .{port});

    var client = try server.accept();
    std.log.info("Accepted connection from {}", .{client.address});
    defer client.stream.close();

    var sender_thread = try std.Thread.spawn(.{}, sender, .{&client.stream});
    var reciever_thread = try std.Thread.spawn(.{}, reciever, .{&client.stream});

    sender_thread.join();
    reciever_thread.join();

    std.log.info("Done", .{});
}

fn reciever(stream: *std.net.Stream) !void {
    const stdout = std.io.getStdOut().writer();
    const reader = stream.reader();
    while (true) {
        var buffer: [4096]u8 = undefined;
        const read_bytes = try reader.read(buffer[0..]);
        if (read_bytes == 0) {
            std.log.info("client closed connection", .{});
            // client closed connection
            break;
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
            break;
        }
        try stream.writeAll(buffer[0..read_bytes]);
    }
}

fn getPortFromArgs() !u16 {
    const alc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alc);
    defer std.process.argsFree(alc, args);
    var port: u16 = default_port;
    for (args[1..]) |arg| {
        port = try std.fmt.parseInt(u16, arg, 10);
        break;
    }
    return port;
}
