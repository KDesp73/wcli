const std = @import("std");
const dotenv = @import("zig-dotenv");

pub const Env = struct {
    const path = ".env";
    alloc: std.mem.Allocator,
    env: dotenv.Dotenv,
    data: []u8,

    pub fn init(alloc: std.mem.Allocator) !Env {
        const e = Env { 
            .env = dotenv.Dotenv.init(alloc, .{}),
            .data = try std.fs.cwd().readFileAlloc(alloc, Env.path, 1 << 20),
            .alloc = alloc
        };
        return e; 
    }

    pub fn deinit(self: *Env) void {
        self.env.deinit();
        self.alloc.free(self.data);
    }

    pub fn getDotEnv(self: *Env, key: []const u8) !?[]const u8 {
        try self.env.parse(self.data);
        return self.env.get(key);
    }

    pub fn getSystem(self: *Env, allocator: std.mem.Allocator, key: []const u8) !?[]const u8 {
        _ = self;
        return try std.process.getEnvVarOwned(allocator, key);
    }
};

