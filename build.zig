const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const rgui = b.dependency("raygui", .{});

    const raygui = b.addModule("raygui-zig", .{
        .source_file = .{ .path = "src/raygui.zig" },
    });

    const exe = b.addExecutable(.{
        .name = "zigRayGuiBindings",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.linkSystemLibrary("raylib");
    exe.addIncludePath(rgui.path("src"));
    // exe.addCSourceFile(
    //     .{
    //         .file = .{ .path = "src/rgui_i.c" },
    //         .flags = &[_][]const u8{},
    //     },
    // );

    exe.addModule("raygui", raygui);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/raygui.zig" },
        .target = target,
        .optimize = optimize,
    });

    unit_tests.linkLibC();
    unit_tests.linkSystemLibrary("raylib");
    unit_tests.addIncludePath(.{ .path = "lib/headers" });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
