const std = @import("std");

pub const Cache = struct {
    const ttl = 300;

    pub fn is_fresh(file_path: []const u8, allocator: std.mem.Allocator) !bool {
        _ = allocator;
        var file = std.fs.cwd().openFile(file_path, .{}) catch return false;
        defer file.close();

        var buf: [1024]u8 = undefined;
        var r = std.fs.File.reader(file, &buf);
        const line = try r.interface.takeDelimiter('\n') orelse return false;
        const timestamp = try std.fmt.parseInt(i64, line, 10);
        const now = @as(i64, @intCast(std.time.timestamp()));

        return (now - timestamp) < Cache.ttl;
    }

    pub fn read_response(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
        var file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        var buf: [1024]u8 = undefined;
        var r = std.fs.File.reader(file, &buf);
        _ = try r.interface.takeDelimiter('\n'); // skip timestamp
        return try r.interface.allocRemaining(allocator, .limited(4096)); // read rest of data
    }

    pub fn write(file_path: []const u8, response: []const u8) !void {
        var file = try std.fs.cwd().createFile(file_path, .{ .truncate = true });
        defer file.close();

        var buf: [1024]u8 = undefined;
        var writer = std.fs.File.writer(file, &buf);
        try writer.interface.print("{}\n{s}", .{ std.time.timestamp(), response });
    }

    pub fn path(allocator: std.mem.Allocator) ![]const u8 {
        const home = try std.process.getEnvVarOwned(allocator, "HOME");
        defer allocator.free(home);
        return std.fmt.allocPrint(allocator, "{s}/.cache/wcli", .{home});
    }

    pub fn entry_path(location: []const u8, language: []const u8, allocator: std.mem.Allocator) ![]const u8 {
        const cache_path = try Cache.path(allocator);
        defer allocator.free(cache_path);
        return std.fmt.allocPrint(allocator, "{s}/{s}_{s}", .{ cache_path, location, language });
    }
};
