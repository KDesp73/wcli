const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "wcli",
        .root_module = exe_mod,
    });

    const zigcli_dep = b.dependency("cli", .{ .target = target });
    const zigcli_mod = zigcli_dep.module("cli");

    const zig_totp_dep = b.dependency("zig-dotenv", .{});
    exe.root_module.addImport("zig-dotenv", zig_totp_dep.module("zig-dotenv"));
    exe.root_module.addImport("cli", zigcli_mod);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.makeFn = makeCleanStep;

    const install_step = b.getInstallStep();
    var copyStep = b.step("copy-to-system-bin", "Copy binary to /usr/local/bin");
    copyStep.makeFn = makeInstallStep;
    install_step.dependOn(copyStep);

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

    try cwd.deleteTree(".zig-cache");
    try cwd.deleteTree("zig-out");
}
