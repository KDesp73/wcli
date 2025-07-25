const std = @import("std");
const cli = @import("cli");
const api = @import("api.zig");
const env = @import("env.zig");
const ui = @import("ui.zig");
const json = @import("json.zig");
const Config = @import("config.zig").Config;
const Cache = @import("cache.zig").Cache;
const version = @import("version.zig").version;

var config = Config{};
const alloc = std.heap.page_allocator;

pub fn main() !void {
    var runner = try cli.AppRunner.init(alloc);

    const app = cli.App{
        .command = cli.Command{
            .name = "wcli",
            .description = .{ .one_line = "A weather tool for the terminal" },
            .options = try runner.allocOptions(&.{
                .{
                    .short_alias = 'v',
                    .long_name = "version",
                    .help = "Prints the version and exits",
                    .value_ref = runner.mkRef(&config.version),
                },
                .{
                    .long_name = "location",
                    .help = "Specify the location",
                    .value_ref = runner.mkRef(&config.location),
                    .required = true,
                },
                .{
                    .long_name = "lang",
                    .help = "Specify the language",
                    .value_ref = runner.mkRef(&config.language),
                },
                .{
                    .long_name = "json",
                    .help = "Print the json response and exit",
                    .value_ref = runner.mkRef(&config.json),
                },
            }),
            .target = .{ .action = .{ .exec = exec } },
        },
    };

    return runner.run(&app);
}

fn exec() !void {
    if (config.version) {
        try std.io.getStdOut().writer().print("v{s}\n", .{version});
        return;
    }

    const cache_root = try Cache.path(alloc);
    defer alloc.free(cache_root);

    std.fs.cwd().access(cache_root, .{}) catch |err| switch (err) {
        error.FileNotFound => try std.fs.makeDirAbsolute(cache_root),
        else => return err,
    };

    var Env = try env.Env.init(alloc);
    defer Env.deinit();

    const api_key = Env.getSystem(alloc, "WEATHER_API_KEY") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => {
            std.log.err("WEATHER_API_KEY environment variable is not set", .{});
            return;
        },
        else => {
            std.log.err("Failed to read WEATHER_API_KEY", .{});
            return;
        },
    };

    if (api_key == null) {
        std.log.err("WEATHER_API_KEY environment variable is not set", .{});
        return;
    }

    const cache_path = try Cache.entry_path(config.location, config.language, alloc);
    defer alloc.free(cache_path);

    var body: ?[]const u8 = null;
    if (try Cache.is_fresh(cache_path, alloc)) {
        body = try Cache.read_response(cache_path, alloc);
    } else {
        var buf = [_]u8{0} ** 1024;
        const url = try std.fmt.bufPrintZ(&buf, "https://api.weatherapi.com/v1/current.json?q={s}&lang={s}&key={s}", .{ config.location, config.language, api_key.? });

        var Api = try api.Api.init(alloc, url);
        body = try Api.call(null);

        if (body != null) try Cache.write(cache_path, body.?);
    }

    if (body == null) {
        std.log.err("No response received", .{});
        return;
    }
    defer alloc.free(body.?);

    if (config.json) {
        _ = try std.io.getStdOut().writer().print("{s}\n", .{body.?});
        return;
    }

    const parsed = json.parse(alloc, body.?) catch |err| switch (err) {
        error.SyntaxError => {
            std.log.err("Invalid JSON response", .{});
            return;
        },
        else => {
            std.log.err("Failed to parse response", .{});
            return;
        },
    };

    try ui.render(config, parsed);
}
