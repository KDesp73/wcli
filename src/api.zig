const std = @import("std");

pub const Api = struct {
    const Self = @This();
    default_endpoint: []u8 = "",
    allocator: std.mem.Allocator = undefined,

    pub fn init(alloc: std.mem.Allocator, endpoint: []u8) !Api {
        const api = Api {
            .allocator = alloc,
            .default_endpoint = endpoint
        };
        return api;
    }

    pub fn call(self: *Self, endpoint: ?[]const u8) !?[]u8 {
        const uri = try std.Uri.parse(
            if (endpoint) |ep| ep else self.default_endpoint,
        );

        var client = std.http.Client{ .allocator = self.allocator };
        defer client.deinit();

        var header_buf: [4096]u8 = undefined;
        var req = try client.open(
            .GET,
            uri,
            std.http.Client.RequestOptions {
                .headers = .{
                    .user_agent = .{ .override = "weathercli" },
                },
                .extra_headers = &.{},
                .redirect_behavior = .not_allowed,
                .server_header_buffer = &header_buf,
            });
        defer req.deinit();

        try req.send();
        try req.wait();

        if (req.response.status != .ok) {
            std.log.err("server replied with {d} {s}", .{
                @intFromEnum(req.response.status),
                req.response.reason,
            });
            return null;
        }

        const buf = try self.allocator.alloc(u8, 2*1024);
        const n = try req.read(buf);

        return buf[0..n];
    }

};
