//! Custom bindings for raygui
//! The main goal is to object orient some
//! components to more easily make UIs.

const std = @import("std");

/// Container items from Raygui
pub const containers = @import("controls/containers.zig");

/// Control elements from Raugui
pub const elements = @import("controls/elements.zig");

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
//                           CONTAINERS
// --------------------------------------------------------------------

/// Interface for containers
/// Raygui constainer/separator controls.
/// Currently Sits unused
pub const Container = union(enum) {
    const Self = @This();

    window: containers.Window,
    groupbox: containers.GroupBox,

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

// --------------------------------------------------------------------
//                           ELEMENTS
// --------------------------------------------------------------------

/// Interface for primitives
/// RayGui Controls / Advanced Controls
pub const Element = union(enum) {
    const Self = @This();

    checkbox: elements.Checkbox,
    button: elements.Button,

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
