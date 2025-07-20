const std = @import("std");
const Janitor = @import("janitor.zig").Janitor;

pub fn build(b: *std.Build) void {
    var j = Janitor.init(b);
    j.exe("wcli");
    j.dep("cli");
    j.dep("zig-dotenv");
    j.install();

    j.step(.run);
    j.step(.clean);

    j.customStep("install-local", "Install system-wide", makeInstallLocalStep);
    j.customStep("autocomplete", "Generate the autocomplete scripts", makeAutocompleteStep);
}

fn makeInstallLocalStep(step: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
    const cwd = std.fs.cwd();
    const exe_path = "zig-out/bin/wcli";
    const prefix = step.owner.option([]const u8, "prefix", "Specify the target directory") orelse "/usr/local/bin";

    var bin_dir = try std.fs.openDirAbsolute(prefix, .{});
    defer bin_dir.close();

    try cwd.copyFile(exe_path, bin_dir, "wcli", .{});
}

pub fn makeAutocompleteStep(step: *std.Build.Step, _: std.Build.Step.MakeOptions) !void {
    const allocator = step.owner.allocator;

    const scripts = [_][]const u8{
        "--zsh",  "./docs/autocomplete/_wcli.zsh",
        "--bash", "./docs/autocomplete/_wcli.bash",
        "--fish", "./docs/autocomplete/_wcli.fish",
    };

    var i: usize = 0;
    while (i < scripts.len) : (i += 2) {
        const script_flag = scripts[i];
        const output_file = scripts[i + 1];

        var process = std.process.Child.init(&[_][]const u8{
            "complgen", script_flag, output_file, "./docs/autocomplete/wcli.usage"
        }, allocator);

        process.stderr_behavior = .Inherit;
        process.stdout_behavior = .Inherit;

        try process.spawn();
        const result = try process.wait();
        if (result.Exited != 0) return error.AutocompleteGenerationFailed;
    }
}

