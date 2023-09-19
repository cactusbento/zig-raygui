//! Implementation of the basic control set.
//! look for "// Basic controls set" in raygui.h for what this implements/should implement.

const std = @import("std");

const rgui = @import("../raygui.zig");
const Rect = rgui.Rect;

const c = @import("../c.zig");

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

/// The raygui DropdownBox.
pub const DropdownBox = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    rect: c.Rectangle,
    list: std.ArrayList(u8),
    list_buttons: std.ArrayList(Button),

    // DropdownBox state
    edit_mode: bool = false,

    open: bool = false,

    // itemSelected
    active: i32 = 0,

    pub fn init(allocator: std.mem.Allocator, rect: Rect) Self {
        return .{
            .allocator = allocator,
            .list = std.ArrayList(u8).init(allocator),
            .list_buttons = std.ArrayList(Button).init(allocator),
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    pub fn deinit(self: *Self) void {
        self.list.deinit();
        self.list_buttons.deinit();
    }

    pub fn add(self: *Self, text: []const u8) !void {
        var nB = Button.init(text, .{});
        try self.list_buttons.append(nB);

        try self.list.appendSlice(text);
        try self.list.append(';');
    }

    pub fn getActiveString(self: *Self) []const u8 {
        return self.list_buttons.items[@intCast(self.active)].name;
    }

    pub fn draw(self: *Self) void {
        // Draw the main button.
        if (c.GuiDropdownBox(
            self.rect,
            @ptrCast(self.list.items),
            &self.active,
            self.edit_mode,
        ) != 0) {
            self.open = !self.open;
        }

        // Draw the buttons to select the active item.
        if (self.open) {
            for (self.list_buttons.items, 0..) |*butt, i| {
                butt.rect = .{
                    .x = self.rect.x,
                    .y = self.rect.y + @as(f32, @floatFromInt(i + 1)) * self.rect.height,
                    .width = self.rect.width,
                    .height = self.rect.height,
                };

                butt.draw();

                if (butt.value) {
                    self.active = @intCast(i);
                    self.open = false;
                }
            }
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
///
/// Look, this library is the first time I'm touching raygui, and I don't know if
/// GuiToggle is supposed to look like a button.
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
