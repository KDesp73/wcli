const std = @import("std");

pub const WeatherResponse = struct {
    location: Location,
    current: Current,
};

pub const Location = struct {
    name: []const u8,
    region: []const u8,
    country: []const u8,
    lat: f64,
    lon: f64,
    tz_id: []const u8,
    localtime_epoch: i64,
    localtime: []const u8,
};

pub const Current = struct {
    last_updated_epoch: i64,
    last_updated: []const u8,

    temp_c: f64,
    temp_f: f64,
    is_day: u1, // 0 = night, 1 = day

    condition: Condition,

    wind_mph: f64,
    wind_kph: f64,
    wind_degree: i32,
    wind_dir: []const u8,

    pressure_mb: f64,
    pressure_in: f64,
    precip_mm: f64,
    precip_in: f64,

    humidity: u8,
    cloud: u8,

    feelslike_c: f64,
    feelslike_f: f64,
    windchill_c: f64,
    windchill_f: f64,
    heatindex_c: f64,
    heatindex_f: f64,
    dewpoint_c: f64,
    dewpoint_f: f64,

    vis_km: f64,
    vis_miles: f64,
    uv: f64,

    gust_mph: f64,
    gust_kph: f64,
};

pub const Condition = struct {
    text: []const u8,
    icon: []const u8,
    code: i32,
};

pub fn parse(alloc: std.mem.Allocator, json: []const u8) !WeatherResponse {
    const parsed = try std.json.parseFromSlice(
        WeatherResponse,
        alloc,
        json,
        .{},
    );
    defer parsed.deinit();
    return parsed.value;
}
