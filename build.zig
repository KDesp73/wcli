const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the module and executable
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "wcli",
        .root_module = exe_mod,
    });

    // Dependencies
    const cli_dep = b.dependency("cli", .{ .target = target });
    exe.root_module.addImport("cli", cli_dep.module("cli"));

    const dotenv_dep = b.dependency("zig-dotenv", .{});
    exe.root_module.addImport("zig-dotenv", dotenv_dep.module("zig-dotenv"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{ .root_module = exe_mod });
    const test_cmd = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_cmd.step);

    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.makeFn = makeCleanStep;

    const install_local = b.step("install-local", "Copy binary to /usr/local/bin");
    install_local.makeFn = makeInstallStep;
}

fn makeInstallStep(_: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
    const cwd = std.fs.cwd();
    const exe_path = "zig-out/bin/wcli";

    var bin_dir = try std.fs.openDirAbsolute("/usr/local/bin", .{});
    defer bin_dir.close();

    try cwd.copyFile(exe_path, bin_dir, "wcli", .{});
}

fn makeCleanStep(_: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
    const cwd = std.fs.cwd();

    cwd.deleteTree("zig-cache") catch |err| {
        if (err != error.FileNotFound) return err;
    };
    cwd.deleteTree("zig-out") catch |err| {
        if (err != error.FileNotFound) return err;
    };
}
