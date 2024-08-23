const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const port = try getPortFromArgs();
    const addr = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, port);
    var server = try addr.listen(.{ .reuse_address = true });
    std.log.info("Listening on port {d}...", .{port});

    var client = try server.accept();
    std.log.info("Accepted connection from {}", .{client.address});
    defer client.stream.close();
    const reader = client.stream.reader();
    while (true) {
        var buffer: [4096]u8 = undefined;
        const read_bytes = try reader.read(buffer[0..]);
        if (read_bytes == 0) {
            std.log.info("Client closed connection", .{});
            break;
        }
        try stdout.writeAll(buffer[0..read_bytes]);
    }
    std.log.info("Done", .{});
}

fn getPortFromArgs() !u16 {
    const alc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alc);
    defer std.process.argsFree(alc, args);
    var port: u16 = 12345;
    for (args[1..]) |arg| {
        port = try std.fmt.parseInt(u16, arg, 10);
        break;
    }
    return port;
}
