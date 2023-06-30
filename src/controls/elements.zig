//! Implementation of the basic control set.
//! look for "// Basic controls set" in raygui.h for what this implements/should implement.

const std = @import("std");

const rgui = @import("../raygui.zig");
const Rect = rgui.Rect;

const c = @cImport({
    @cInclude("raylib.h");

    // import raygui
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

/// The basic label.
pub const Label = struct {
    const Self = @This();

    rect: c.Rectangle,
    text: []const u8,

    pub fn init(text: []const u8, rect: Rect) Self {
        return .{
            .text = text,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    pub fn draw(self: *Self) void {
        _ = c.GuiLabel(self.rect, @as([*c]const u8, self.text.ptr));
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        self.rect.width = w;
        self.rect.height = h;
    }
};

/// The basic Raylib button.
/// TODO: Maybe implement GuiLabelButton
pub const Button = struct {
    const Self = @This();

    rect: c.Rectangle,
    name: []const u8,

    // Button state
    value: bool = false,

    pub fn init(name: []const u8, rect: Rect) Self {
        return .{
            .name = name,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    pub fn draw(self: *Self) void {
        self.value = c.GuiButton(self.rect, @as([*c]const u8, self.name.ptr)) != 0;
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        self.rect.width = w;
        self.rect.height = h;
    }
};

/// The basic Raylib checkbox.
pub const Checkbox = struct {
    const Self = @This();

    rect: c.Rectangle,
    name: []const u8,

    // Checkbox state
    value: bool = false,

    pub fn init(name: []const u8, rect: Rect) Self {
        return .{
            .name = name,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    pub fn draw(self: *Self) void {
        const prev_val = self.value;

        if (c.GuiCheckBox(
            self.rect,
            @as([*c]const u8, self.name.ptr),
            &self.value,
        ) != 0 and prev_val) {
            self.value = !self.value;
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        self.rect.width = w;
        self.rect.height = h;
    }
};

/// The basic Raylib toggle.
pub const Toggle = struct {
    const Self = @This();

    rect: c.Rectangle,
    name: []const u8,

    // Checkbox state
    value: bool = false,

    pub fn init(name: []const u8, rect: Rect) Self {
        return .{
            .name = name,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    pub fn draw(self: *Self) void {
        const prev_val = self.value;

        if (c.GuiToggle(
            self.rect,
            @as([*c]const u8, self.name.ptr),
            &self.value,
        ) != 0 and prev_val) {
            self.value = !self.value;
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        self.rect.width = w;
        self.rect.height = h;
    }
};
