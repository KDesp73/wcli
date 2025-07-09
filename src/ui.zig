const std  = @import("std");
const ansi = @import("ansi.zig");
const WeatherResponse = @import("json.zig").WeatherResponse;
const Config = @import("config.zig").Config;

const RenderFn = *const fn (std.io.AnyWriter, WeatherResponse) anyerror!void;
const ConditionUI = struct {
    codes: []const i32,
    renderer: RenderFn,

    pub fn render(self: @This(), writer: std.io.AnyWriter, res: WeatherResponse) !void {
        try self.renderer(writer, res);
    }

    pub fn matches(self: @This(), code: i32) bool {
        return std.mem.indexOfScalar(i32, self.codes, code) != null;
    }
};


const sunny_ascii =
    "{s}  \\   |   / {s}   {s}{s}{s}\n"   ++
    "{s}    /\"\"\"\\{s}      {d:.1} °C  ({d:.1} °F)\n" ++
    "{s} ― |     |  ―{s}  {d}%  {d:.1} mb\n"       ++
    "{s}    \\___/   {s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    "{s}  /   |   \\ {s}   {s}{s}{s}\n";
fn sunny_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const c = ansi.FgYellow;
    const r = ansi.Reset;
    const curr = res.current;

    try writer.print(sunny_ascii, .{
        c, r, c, curr.condition.text, r,
        c, r, curr.temp_c, curr.temp_f,
        c, r, curr.humidity, curr.pressure_mb,
        c, r, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        c, r, ansi.FgBlack, res.location.localtime, ansi.Reset
    });
}

const cloudy_ascii =
    "{s}            {s}   {s}{s}{s}\n"              ++
    "{s}     .--.   {s}   {d:.1} °C  ({d:.1} °F)\n" ++
    "{s}  .-(    ). {s}   {d}%  {d:.1} mb\n"        ++
    "{s} (___.__)__){s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    "{s}            {s}   {s}{s}{s}\n";
fn cloudy_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const c = ansi.FgBlue;
    const r = ansi.Reset;
    const curr = res.current;

    try writer.print(cloudy_ascii, .{
        c, r, c, curr.condition.text, r,
        c, r, curr.temp_c, curr.temp_f,
        c, r, curr.humidity, curr.pressure_mb,
        c, r, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        c, r, ansi.FgBlack, res.location.localtime, ansi.Reset,
    });
}

const rainy_ascii =
    " {s}     .--.   {s}   {s}{s}{s}\n"              ++
    " {s}  .-(    ). {s}   {d:.1} °C  ({d:.1} °F)\n" ++
    " {s} (___.__)__){s}   {d}%  {d:.1} mb\n"        ++
    " {s}  /  /  / / {s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    " {s}   /  /  /  {s}   {s}{s}{s}\n";
fn rainy_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const b = ansi.FgBlue;
    const g = ansi.FgLGrey;
    const cyan = ansi.FgCyan;
    const r = ansi.Reset;
    const curr = res.current;
    
    try writer.print(rainy_ascii, .{
        g, r, cyan, curr.condition.text, r,
        g, r, curr.temp_c, curr.temp_f,
        g, r, curr.humidity, curr.pressure_mb,
        b, r, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        b, r, ansi.FgBlack, res.location.localtime, ansi.Reset,
    });
}

const snowy_ascii =
    " {s}     .--.   {s}   {s}{s}{s}\n"              ++
    " {s}  .-(    ). {s}   {d:.1} °C  ({d:.1} °F)\n" ++
    " {s} (___.__)__){s}   {d}%  {d:.1} mb\n"        ++
    " {s}  *  *  * * {s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    " {s}   *  *  *  {s}   {s}{s}{s}\n";
fn snowy_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const g = ansi.FgLGrey;
    const r = ansi.Reset;
    const curr = res.current;
    
    try writer.print(snowy_ascii, .{
        g, r, ansi.Bold, curr.condition.text, r,
        g, r, curr.temp_c, curr.temp_f,
        g, r, curr.humidity, curr.pressure_mb,
        ansi.FgWhite, r, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        ansi.FgWhite, r, ansi.FgBlack, res.location.localtime, ansi.Reset,
    });
}

const foggy_ascii = 
    " {s}   _   _    {s}   {s}{s}{s}\n"              ++
    " {s} _   _   _  {s}   {d:.1} °C  ({d:.1} °F)\n" ++
    " {s}   _   _    {s}   {d}%  {d:.1} mb\n"        ++
    " {s} _   _   _  {s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    " {s}            {s}   {s}{s}{s}\n";
fn foggy_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const curr = res.current;
    try writer.print(foggy_ascii, .{
        ansi.FgMagenta, ansi.Reset, ansi.FgMagenta, curr.condition.text, ansi.Reset,
        ansi.FgMagenta, ansi.Reset, curr.temp_c, curr.temp_f,
        ansi.FgMagenta, ansi.Reset, curr.humidity, curr.pressure_mb,
        ansi.FgMagenta, ansi.Reset, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        ansi.FgMagenta, ansi.Reset, ansi.FgBlack, res.location.localtime, ansi.Reset,
    });
}
    
const thunder_ascii = 
    " {s}     .--.   {s}   {s}{s}{s}\n"              ++
    " {s}  .-(    ). {s}   {d:.1} °C  ({d:.1} °F)\n" ++
    " {s} (___.__)__){s}   {d}%  {d:.1} mb\n"        ++
    " {s}      /     {s}   {d:.1} kph  ({d:.1} mph)  {d}° {s}\n" ++
    " {s}      7     {s}   {s}{s}{s}\n";
fn thunder_renderer(writer: std.io.AnyWriter, res: WeatherResponse) !void {
    const curr = res.current;
    try writer.print(foggy_ascii, .{
        ansi.FgLGrey, ansi.Reset, ansi.FgCyan, curr.condition.text, ansi.Reset,
        ansi.FgLGrey, ansi.Reset, curr.temp_c, curr.temp_f,
        ansi.FgLGrey, ansi.Reset, curr.humidity, curr.pressure_mb,
        ansi.FgYellow, ansi.Reset, curr.wind_kph, curr.wind_mph, curr.wind_degree, curr.wind_dir,
        ansi.FgYellow, ansi.Reset, ansi.FgBlack, res.location.localtime, ansi.Reset,
    });
}

const sunny_codes   = &.{ 1000 };
const cloudy_codes  = &.{ 1003, 1006, 1009 };
const rainy_codes   = &.{ 1063, 1150, 1180, 1183, 1186, 1189, 1192, 1195 }; // TODO: introduce other rainy ascii drawings
const snowy_codes    = &.{ 1066, 1210, 1213, 1216, 1222, 1225 };
const foggy_codes   = &.{ 1030, 1135, 1147 };
const thunder_codes = &.{ 1087, 1273, 1276 };


const CONDITIONS = [_]ConditionUI{
    .{ .renderer = sunny_renderer, .codes = sunny_codes },
    .{ .renderer = cloudy_renderer, .codes = cloudy_codes },
    .{ .renderer = rainy_renderer, .codes = rainy_codes },
    .{ .renderer = snowy_renderer, .codes = snowy_codes },
    .{ .renderer = foggy_renderer, .codes = foggy_codes },
    .{ .renderer = thunder_renderer, .codes = thunder_codes },
};

fn findCondition(code: i32) ?ConditionUI {
    for (CONDITIONS) |cnd| {
        if (cnd.matches(code)) return cnd;
    }
    return null;
}

pub fn render(conf: Config, res: WeatherResponse) !void {
    _ = conf;

    const w = std.io.getStdOut().writer().any();
    const code = res.current.condition.code;

    if (findCondition(code)) |cnd| {
        // try w.writeAll("\n");
        try cnd.render(w, res);
        try w.writeAll("\n");
    } else {
        std.log.err("Unknown weather code {} – {s}\n", .{
            code,
            res.current.condition.text,
        });
    }
}
