const std = @import("std");

pub const raygui = @import("raygui.zig");
const containers = raygui.containers;
const elements = raygui.elements;
const custom = raygui.custom;

const c = @cImport({
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
    c.SetConfigFlags(c.FLAG_WINDOW_RESIZABLE);

    c.InitWindow(screenWidth, screenHeight, "raygui test window");
    defer c.CloseWindow();

    c.SetTargetFPS(60);

    var menubar = custom.MenuBar.init(alloc, .{
        .x = 0,
        .y = 0,
        .width = screenWidth,
        .height = 20,
    });
    defer menubar.deinit();

    var menubar_file = custom.MenuBar.Category.init(alloc, "File");
    defer menubar_file.deinit();

    var menubar_edit = custom.MenuBar.Category.init(alloc, "Edit");
    defer menubar_edit.deinit();

    try menubar.categories.append(&menubar_file);
    try menubar.categories.append(&menubar_edit);

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

    var testDropDown = elements.DropdownBox.init(alloc, .{
        .x = 100,
        .y = 200,
        .width = 200,
        .height = 20,
    });
    defer testDropDown.deinit();
    try testDropDown.add("lol");
    try testDropDown.add("kek");

    while (!c.WindowShouldClose()) {
        // Frame Work
        c.BeginDrawing();
        defer c.EndDrawing();
        c.ClearBackground(c.RAYWHITE);
        menubar.draw();

        testDropDown.draw();

        menubar.rect.width = @as(f32, @floatFromInt(c.GetRenderWidth()));

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
            std.debug.print("DropDown: {s}\n", .{testDropDown.getActiveString()});
        }

        // c.DrawFPS(10, 10);
    }
}
