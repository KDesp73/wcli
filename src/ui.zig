const std = @import("std");
const WeatherResponse = @import("json.zig").WeatherResponse;
const Config = @import("config.zig").Config;

pub fn render(conf: Config, res: WeatherResponse) !void {
    _ = conf;

    std.log.info("{s}, {s}", .{res.location.name, res.location.country});
    std.log.info("{s} ({})", .{
        res.current.condition.text, res.current.condition.code
    });

}

pub fn print(resp: *const WeatherResponse) !void {
    var w = resp; // shorthand

    const out = std.io.getStdOut().writer();

    // ── Location ────────────────────────────────────────────────
    try out.print(
        \\{s}, {s}, {s}
        \\Lat/Lon:  {d:.4}, {d:.4}
        \\Time:     {s} (epoch {d})
        \\────────────────────────────────────────────────────────
        \\
        ,
        .{
            w.location.name,
            w.location.region,
            w.location.country,
            w.location.lat,
            w.location.lon,
            w.location.localtime,
            w.location.localtime_epoch,
        },
    );

    // ── Current Conditions ─────────────────────────────────────
    const c = &w.current;
    try out.print(
        \\Temp:      {d:.1} °C  ({d:.1} °F)
        \\Feels like {d:.1} °C  ({d:.1} °F)
        \\Humidity:  {d}%      Cloud: {d}%
        \\Wind:      {d:.1} kph  ({d:.1} mph)  {d}° {s}
        \\Pressure:  {d:.1} mb  ({d:.2} in)
        \\Precip:    {d:.1} mm  ({d:.1} in)
        \\Visibility {d:.1} km  ({d:.1} mi)
        \\UV index:  {d:.1}
        \\Condition: {s}
        \\Icon:      {s}
        \\────────────────────────────────────────────────────────
        \\Updated:   {s} (epoch {d})
        \\
        ,
        .{
            c.temp_c,        c.temp_f,
            c.feelslike_c,   c.feelslike_f,
            c.humidity,      c.cloud,
            c.wind_kph,      c.wind_mph, c.wind_degree, c.wind_dir,
            c.pressure_mb,   c.pressure_in,
            c.precip_mm,     c.precip_in,
            c.vis_km,        c.vis_miles,
            c.uv,
            c.condition.text,
            c.condition.icon,
            c.last_updated,  c.last_updated_epoch,
        },
    );
}

