const std = @import("std");

/// Represents a custom build step, either running or cleaning the build output.
pub const Step = enum {
    run,
    clean,
};

/// A utility struct to simplify and organize common Zig build steps.
///
/// This struct wraps around the Zig `std.Build` API and provides
/// a clean interface for setting up an executable target, managing dependencies,
/// creating custom build steps, and running or cleaning the project.
pub const Janitor = struct {
    const Self = @This();

    /// The main build object passed into `build.zig`.
    b: *std.Build,

    /// The compiled executable module, created via `exe()`.
    exeMod: ?*std.Build.Step.Compile,

    /// The target platform (e.g., x86_64-linux).
    target: std.Build.ResolvedTarget,

    /// The optimization mode (e.g., Debug, ReleaseFast).
    optimize: std.builtin.OptimizeMode,

    /// The name of the executable, for internal tracking.
    name: ?[]const u8,

    /// Initializes the Janitor helper with a reference to the build object.
    pub fn init(b: *std.Build) Self {
        return Self{
            .b = b,
            .exeMod = null,
            .name = null,
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
        };
    }

    /// Defines the executable target.
    ///
    /// This must be called before adding dependencies.
    pub fn exe(self: *Self, name: []const u8) void {
        self.name = name;
        self.exeMod = self.b.addExecutable(.{
            .name = name,
            .root_source_file = self.b.path("src/main.zig"),
            .target = self.target,
            .optimize = self.optimize,
        });
    }

    /// Adds a dependency to the executable's root module.
    ///
    /// `name` should match the dependency declared in `build.zig.zon`.
    pub fn dep(self: *Self, name: []const u8) void {
        if (self.exeMod == null) {
            std.log.err("Exe is not initialized", .{});
            return;
        }

        const d = self.b.dependency(name, .{});
        self.exeMod.?.root_module.addImport(name, d.module(name));
    }

    /// Declares a build option and returns its value.
    ///
    /// This is useful for configurable builds (e.g., `-Dflag=value`).
    pub fn opt(self: *Self, T: type, name: []const u8, desc: []const u8) ?T {
        return self.b.option(T, name, desc);
    }

    /// Marks the executable to be installed to `zig-out/bin` on build.
    pub fn install(self: *Self) void {
        if (self.exeMod) |e| {
            self.b.installArtifact(e);
        }
    }

    /// Adds a predefined step to the build pipeline.
    ///
    /// Supported steps: `.run` and `.clean`.
    pub fn step(self: *Self, s: Step) void {
        switch (s) {
            Step.run => self.addRunStep(),
            Step.clean => self.addCleanStep(),
        }
    }

    /// Adds a `run` step that builds and executes the binary.
    fn addRunStep(self: *Self) void {
        if (self.exeMod) |e| {
            const run_cmd = self.b.addRunArtifact(e);
            const run_step = self.b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        }
    }

    /// Adds a `clean` step that deletes the Zig cache and output directories.
    ///
    /// This allows running `zig build clean` to reset the build state.
    fn addCleanStep(self: *Self) void {
        const clean_step = self.b.step("clean", "Clean build output");
        clean_step.makeFn = struct {
            fn make(_: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
                const cwd = std.fs.cwd();
                cwd.deleteTree("zig-cache") catch |err| {
                    if (err != error.FileNotFound) return err;
                };
                cwd.deleteTree("zig-out") catch |err| {
                    if (err != error.FileNotFound) return err;
                };
            }
        }.make;
    }

    /// Adds a fully custom step with a user-defined function.
    ///
    /// `makeFn` must follow the `std.Build.Step.MakeFn` signature.
    pub fn customStep(self: *Self, name: []const u8, desc: []const u8, makeFn: std.Build.Step.MakeFn) void {
        const s = self.b.step(name, desc);
        s.makeFn = makeFn;
    }

    /// Attempts to get the current Git version/tag.
    ///
    /// Returns the output of `git describe --tags --always` trimmed of newline.
    /// If Git is unavailable or fails, returns `null`.
    pub fn getGitVersion(b: *std.Build) ?[]const u8 {
        const allocator = b.allocator;
        const result = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ "git", "describe", "--tags", "--always" },
        }) catch return null;

        if (result.term != .Exited or result.term.Exited != 0 or result.stdout.len == 0)
            return null;

        return std.mem.trimRight(u8, result.stdout, "\n");
    }
};
