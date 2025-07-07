const std = @import("std");
const WeatherResponse = @import("json.zig").WeatherResponse;
const Config = @import("config.zig").Config;

pub fn render(conf: Config, res: WeatherResponse) !void {
    _ = conf;
    const condition = res.current.condition.text;

    std.log.info("{s}", .{condition});
    std.log.info("{s}, {s}", .{res.location.name, res.location.country});

}
