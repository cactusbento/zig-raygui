/// Custom bindings for raygui
/// The main goal is to object orient some
/// components to more easily make UIs.
/// Especially to create simple panels
const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");

    // import raygui
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});
const rgui = @This();

const Rect = struct {
    x: f32 = 0,
    y: f32 = 0,
    width: f32 = 20,
    height: f32 = 20,
};

/// Interface for containers
/// Raygui constainer/separator controls.
/// Currently Sits unused
pub const Container = union(enum) {
    const Self = @This();

    window: Window,
    groupbox: GroupBox,

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

/// Interface for primitives
/// RayGui Controls / Advanced Controls
pub const Element = union(enum) {
    const Self = @This();

    checkbox: Checkbox,
    button: Button,

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

/// A raygui window. Contains an std.ArrayList(Element) to store raygui elements.
pub const Window = struct {
    const Self = @This();
    const e = Element;

    rect: c.Rectangle,
    name: []const u8,

    // window state
    closed: bool = false,
    being_dragged: bool = false,

    // Window Properties
    titleBarHeight: f32 = 24,

    // Element Padding
    hPad: f32 = 10,
    vPad: f32 = 5,

    // Elements inside window.
    elements: std.ArrayList(e),

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
    pub fn init(name: []const u8, alloc: std.mem.Allocator, rect: Rect) Self {
        return .{
            .name = name,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
            .elements = std.ArrayList(e).init(alloc),
        };
    }

    /// Only needed if allocator is not ArenaAllocator.
    pub fn deinit(self: *Self) void {
        self.elements.deinit();
    }

    pub fn append(self: *Self, elem: e) !void {
        try self.elements.append(elem);
    }

    /// Draw/Update loop should handle the destruction of the window
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        const mX: f32 = @floatFromInt(f32, c.GetMouseX());
        const mY: f32 = @floatFromInt(f32, c.GetMouseY());

        // Checks if mouse is on titlebar,
        // Valid area does not include the close button.
        const is_on_titlebar = @as(bool, c.CheckCollisionPointRec(.{
            .x = mX,
            .y = mY,
        }, .{
            .x = self.rect.x,
            .y = self.rect.y,
            .width = self.rect.width - self.titleBarHeight,
            .height = self.titleBarHeight,
        }));

        // Move window to mouse
        // ensure that the mouse is LEFT CLICK dragging from the titlebar
        if (is_on_titlebar and c.IsMouseButtonPressed(c.MOUSE_BUTTON_LEFT)) {
            self.being_dragged = true;
        }
        if (self.being_dragged and c.IsMouseButtonDown(c.MOUSE_BUTTON_LEFT)) {
            const mDelta = c.GetMouseDelta();
            self.move(self.rect.x + mDelta.x, self.rect.y + mDelta.y);
        }
        if (c.IsMouseButtonReleased(c.MOUSE_BUTTON_LEFT)) {
            self.being_dragged = false;
        }

        // Draw window and its contents
        self.closed = c.GuiWindowBox(self.rect, @as([*c]const u8, self.name.ptr)) != 0;
        for (self.elements.items, 0..) |*elem, i| {
            elem.move(
                self.rect.x + self.hPad,
                self.rect.y + self.titleBarHeight + self.vPad + @floatFromInt(f32, i) * (self.vPad + elem.getRect().height),
            );

            elem.draw();
        }
    }

    fn boundsCheck(self: *Self) void {
        if (self.rect.x < 0) {
            self.rect.x += @floatFromInt(f32, std.math.absInt(@intFromFloat(i32, self.rect.x)) catch 0);
        }
        if (self.rect.y < 0) {
            self.rect.y += @floatFromInt(f32, std.math.absInt(@intFromFloat(i32, self.rect.y)) catch 0);
        }

        const screenWidth = @floatFromInt(f32, c.GetScreenWidth());
        const screenHeight = @floatFromInt(f32, c.GetScreenHeight());

        if (self.rect.x + self.rect.width > screenWidth) {
            const toMove = (self.rect.x + self.rect.width) - screenWidth;
            self.rect.x -= @floatFromInt(f32, std.math.absInt(@intFromFloat(i32, toMove)) catch 0);
        }
        if (self.rect.y + self.titleBarHeight > screenHeight) {
            const toMove = (self.rect.y + self.titleBarHeight) - screenHeight;
            self.rect.y -= @floatFromInt(f32, std.math.absInt(@intFromFloat(i32, toMove)) catch 0);
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
        self.boundsCheck();
    }

    pub fn resize(self: *Self, width: f32, height: f32) void {
        self.rect.width = width;
        self.rect.height = height;
    }
};

/// A raygui GroupBox. Contains an std.ArrayList(Element) to store raygui elements.
pub const GroupBox = struct {
    const Self = @This();
    const e = Element;

    rect: c.Rectangle,
    name: []const u8,

    // GroupBox state
    closed: bool = false,

    // GroupBox Properties
    borderWidth: f32 = 5,

    // Element Padding
    hPad: f32 = 5,
    vPad: f32 = 5,

    // Elements inside GroupBox.
    elements: std.ArrayList(e),

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
    pub fn init(name: []const u8, alloc: std.mem.Allocator, rect: Rect) Self {
        return .{
            .name = name,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
            .elements = std.ArrayList(e).init(alloc),
        };
    }

    /// Only needed if allocator is not ArenaAllocator.
    pub fn deinit(self: *Self) void {
        self.elements.deinit();
    }

    pub fn append(self: *Self, elem: e) !void {
        try self.elements.append(elem);
    }

    /// Draw/Update loop should handle the destruction of the GroupBox
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        self.closed = c.GuiGroupBox(self.rect, @as([*c]const u8, self.name.ptr)) != 0;
        for (self.elements.items, 0..) |*elem, i| {
            elem.move(
                self.rect.x + self.borderWidth + self.hPad,
                self.rect.y + self.borderWidth + self.vPad + @floatFromInt(f32, i) * (self.vPad + elem.getRect().height),
            );

            elem.draw();
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *Self, width: f32, height: f32) void {
        self.rect.width = width;
        self.rect.height = height;
    }
};

// --------------------------------------------------------------------
//                           ELEMENTS
// --------------------------------------------------------------------

pub const Button = struct {
    const Self = @This();

    rect: c.Rectangle = .{
        .x = 0,
        .y = 0,
        .width = 0,
        .height = 0,
    },
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
