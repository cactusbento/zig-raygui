const std = @import("std");

pub const raygui = @import("raygui.zig");
const containers = raygui.containers;
const elements = raygui.elements;

const ray = @cImport({
    @cInclude("raylib.h");
});

/// This is a test program to visually inspect the work done in this repository.
pub fn main() !void {
    const screenWidth = 160 * 5;
    const screenHeight = 160 * 4;

    // ArenaAllocator
    var base_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(base_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // Config
    ray.SetConfigFlags(ray.FLAG_WINDOW_RESIZABLE);

    ray.InitWindow(screenWidth, screenHeight, "raygui test window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var test_checkbox = elements.Checkbox.init("TestCheckBox", .{});
    var test_button = elements.Button.init("TestButtonA", .{ .width = 100, .height = 20 });
    var openWindow = elements.Button.init("open testWindow", .{
        .x = 50,
        .y = 50,
        .width = 125,
        .height = 20,
    });

    var testWindow = containers.Window.init("testWindow", alloc, .{
        .x = 100,
        .y = 100,
        .width = 300,
        .height = 200,
    });
    defer testWindow.deinit();

    var testGroupBox = containers.GroupBox.init("testGroupBox", alloc, .{
        .x = 300,
        .y = 200,
        .width = 120,
        .height = 40,
    });
    try testGroupBox.append(.{ .button = @constCast(&elements.Button.init("GBButton", .{ .width = 100 })) });

    try testWindow.append(.{ .button = &test_button });
    try testWindow.append(.{ .checkbox = &test_checkbox });
    try testWindow.append(.{ .groupbox = &testGroupBox });

    while (!ray.WindowShouldClose()) {
        // Frame Work
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.RAYWHITE);

        // Will also draw what's inside self.elements.
        // So, it will draw testButton and testCheckBox
        if (!testWindow.closed) {
            testWindow.draw();
        } else {
            openWindow.draw();

            if (openWindow.value) {
                openWindow.name = "New Name";
                testWindow.closed = false;
                testWindow.move(100, 100);
            }
        }

        if (test_button.value) {
            std.debug.print("Button Pressed!\n", .{});
        }

        ray.DrawFPS(10, 10);
    }
}
