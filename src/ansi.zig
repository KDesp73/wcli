const std = @import("std");

const Ansi = @This();

pub const Reset       = "\x1b[0m";
pub const Bold        = "\x1b[1m";
pub const Underline   = "\x1b[4m";
pub const Reversed    = "\x1b[7m";

// Foreground colors
pub const FgBlack     = "\x1b[30m";
pub const FgRed       = "\x1b[31m";
pub const FgGreen     = "\x1b[32m";
pub const FgYellow    = "\x1b[33m";
pub const FgBlue      = "\x1b[34m";
pub const FgMagenta   = "\x1b[35m";
pub const FgCyan      = "\x1b[36m";
pub const FgWhite     = "\x1b[37m";

// Background colors
pub const BgBlack     = "\x1b[40m";
pub const BgRed       = "\x1b[41m";
pub const BgGreen     = "\x1b[42m";
pub const BgYellow    = "\x1b[43m";
pub const BgBlue      = "\x1b[44m";
pub const BgMagenta   = "\x1b[45m";
pub const BgCyan      = "\x1b[46m";
pub const BgWhite     = "\x1b[47m";

pub fn style(alloc: std.mem.Allocator, str: []u8, s: []u8) ![]u8 {
    return std.fmt.allocPrint(alloc, "{s}{s}{s}", .{s, str, Ansi.Reset});
}
