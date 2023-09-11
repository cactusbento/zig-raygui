//! Custom bindings for raygui.
//!
//! The main goal is to object orient some
//! components to more easily make UIs.

const std = @import("std");

/// Container items from Raygui
pub const containers = @import("widgets/containers.zig");

/// Control elements from Raugui
pub const elements = @import("widgets/elements.zig");

const c = @cImport({
    @cInclude("raylib.h");

    // import raygui
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

const rgui = @This();

// --------------------------------------------------------------------
//                           TYPES
// --------------------------------------------------------------------

/// Rectangle struct from Raylib, but with default values.
pub const Rect = struct {
    x: f32 = 0,
    y: f32 = 0,
    width: f32 = 20,
    height: f32 = 20,
};

// --------------------------------------------------------------------
//                          WIDGETS
// --------------------------------------------------------------------

/// Interface for all the elements provided by this library.
pub const Widget = union(enum) {
    const Self = @This();

    window: containers.Window,
    groupbox: containers.GroupBox,

    checkbox: elements.Checkbox,
    button: elements.Button,
    label: elements.Label,
    toggle: elements.Toggle,

    pub fn draw(self: *Self) void {
        switch (self.*) {
            inline else => |*case| case.draw(),
        }
    }

    pub fn getRect(self: *Self) c.Rectangle {
        switch (self.*) {
            inline else => |*case| return case.*.rect,
        }
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        switch (self.*) {
            inline else => |*case| case.resize(w, h),
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        switch (self.*) {
            inline else => |*case| case.move(x, y),
        }
    }
};
