const std = @import("std");

pub const Api = struct {
    const Self = @This();
    default_endpoint: []u8 = "",
    allocator: std.mem.Allocator = undefined,

    pub fn init(alloc: std.mem.Allocator, endpoint: []u8) !Api {
        const api = Api{ .allocator = alloc, .default_endpoint = endpoint };
        return api;
    }

    pub fn call(self: *Self, endpoint: ?[]const u8) !?[]u8 {
        const uri = try std.Uri.parse(
            if (endpoint) |ep| ep else self.default_endpoint,
        );

        var client = std.http.Client{ .allocator = self.allocator };
        defer client.deinit();

        var req = try client.request(.GET, uri, .{
            .headers = .{
                .user_agent = .{ .override = "wcli" },
                .accept_encoding = .{ .override = "identity" },
            },
            .redirect_behavior = @enumFromInt(0),
        });
        defer req.deinit();

        try req.sendBodiless();
        var redirect_buf: [4096]u8 = undefined;
        var response = try req.receiveHead(&redirect_buf);

        if (response.head.status != .ok) {
            std.log.err("server replied with {d} {s}", .{
                @intFromEnum(response.head.status),
                response.head.reason,
            });
            return null;
        }

        var transfer_buf: [1024]u8 = undefined;
        const reader = response.reader(&transfer_buf);
        const result = reader.allocRemaining(self.allocator, .limited(2 * 1024)) catch |err| {
            std.log.err("read error: {}", .{err});
            return null;
        };
        return result;
    }
};
