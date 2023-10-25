//! Implementation of the container/separator control set.
//! look for "// Container/separator controls" in raygui.h for what this implements/should implement.

const std = @import("std");
const elements = @import("elements.zig");

const rgui = @import("../raygui.zig");
const Rect = rgui.Rect;
const Widget = rgui.Widget;

const c = @import("../c.zig");

const WidgetArrayList = std.ArrayList(Widget);

/// A raygui window. Contains an std.ArrayList(raygui.Element) to store raygui elements.
pub const Window = struct {
    const Self = @This();

    rect: c.Rectangle,
    name: []const u8,

    // window state
    closed: bool = false,
    being_dragged: bool = false,

    // Window Properties
    titleBarHeight: f32 = 24,

    // elements.Element Padding
    hPad: f32 = 10,
    vPad: f32 = 5,

    /// raygui.Elements inside window.
    widgets: WidgetArrayList,

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
            .widgets = WidgetArrayList.init(alloc),
        };
    }

    /// Only needed if allocator is not ArenaAllocator.
    pub fn deinit(self: *Self) void {
        self.widgets.deinit();
    }

    /// Add a raygui.Element to the container
    pub fn append(self: *Self, elem: Widget) !void {
        try self.widgets.append(elem);
    }

    /// Draw/Update loop should handle the destruction of the window
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        const mX: f32 = @as(f32, @floatFromInt(c.GetMouseX()));
        const mY: f32 = @as(f32, @floatFromInt(c.GetMouseY()));

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
        for (self.widgets.items, 0..) |*elem, i| {
            elem.move(
                self.rect.x + self.hPad,
                self.rect.y + self.titleBarHeight + self.vPad + @as(f32, @floatFromInt(i)) * (self.vPad + elem.getRect().height),
            );

            elem.draw();
        }
    }

    fn boundsCheck(self: *Self) void {
        if (self.rect.x < 0) {
            self.rect.x += @abs(self.rect.x);
        }
        if (self.rect.y < 0) {
            self.rect.y += @abs(self.rect.y);
        }

        const screenWidth = @as(f32, @floatFromInt(c.GetScreenWidth()));
        const screenHeight = @as(f32, @floatFromInt(c.GetScreenHeight()));

        if (self.rect.x + self.rect.width > screenWidth) {
            const toMove = (self.rect.x + self.rect.width) - screenWidth;
            self.rect.x -= @abs(toMove);
        }
        if (self.rect.y + self.titleBarHeight > screenHeight) {
            const toMove = (self.rect.y + self.titleBarHeight) - screenHeight;
            self.rect.y -= @abs(toMove);
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

/// A raygui GroupBox. Contains an std.ArrayList(raygui.Element) to store raygui elements.
/// See containers.Window for docs. All containers are very similar.
pub const GroupBox = struct {
    const Self = @This();

    rect: c.Rectangle,
    name: []const u8,

    // GroupBox state
    closed: bool = false,

    // GroupBox Properties
    borderWidth: f32 = 5,

    // elements.Element Padding
    hPad: f32 = 5,
    vPad: f32 = 5,

    // elements.Elements inside GroupBox.
    elements: WidgetArrayList,

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
            .elements = WidgetArrayList.init(alloc),
        };
    }

    /// Only needed if allocator is not ArenaAllocator.
    pub fn deinit(self: *Self) void {
        self.elements.deinit();
    }

    pub fn append(self: *Self, elem: Widget) !void {
        try self.elements.append(elem);
    }

    /// Draw/Update loop should handle the destruction of the GroupBox
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        self.closed = c.GuiGroupBox(self.rect, @as([*c]const u8, self.name.ptr)) != 0;
        for (self.elements.items, 0..) |*elem, i| {
            elem.move(
                self.rect.x + self.borderWidth + self.hPad,
                self.rect.y + self.borderWidth + self.vPad + @as(f32, @floatFromInt(i)) * (self.vPad + elem.getRect().height),
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

/// A raygui Line.
/// Used as a separator.
///
/// Can contain text.
pub const Line = struct {
    const Self = @This();

    rect: c.Rectangle,
    text: []const u8,

    // Line Properties
    borderWidth: f32 = 5,

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
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

    /// Draw/Update loop should handle the destruction of the Line
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        _ = c.GuiLine(self.rect, @as([*c]const u8, self.text.ptr));
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

/// A raygui Panel.
/// Used to group controls.
///
/// Can contain text.
pub const Panel = struct {
    const Self = @This();

    rect: c.Rectangle,
    text: []const u8,

    // Panel Properties
    borderWidth: f32 = 5,

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
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

    /// Draw/Update loop should handle the destruction of the Panel
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        _ = c.GuiPanel(self.rect, @as([*c]const u8, self.text.ptr));
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

/// A raygui TabBar.
pub const TabBar = struct {
    const Self = @This();
    const e = Widget;

    rect: c.Rectangle,
    texts: [][]const u8,

    // TabBar Properties
    borderWidth: f32 = 5,
    active: i32,

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
    pub fn init(names: [][]const u8, rect: Rect) Self {
        return .{
            .names = names,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
        };
    }

    /// Draw/Update loop should handle the destruction of the TabBar
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        _ = c.GuiTabBar(self.rect, @ptrCast(self.texts), @intCast(self.texts.len), &self.active);
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

/// A raygui ScrollPanel.
pub const ScrollPanel = struct {
    const Self = @This();
    const e = Widget;

    rect: c.Rectangle,
    text: []const u8,

    // ScrollPanel Properties
    content: c.Rectangle,
    borderWidth: f32 = 5,
    scroll: c.Vector2 = undefined,
    view: c.Rectangle = undefined,

    /// Recommended Allocator: ArenaAllocator.
    /// Other allocators must use deinit.
    pub fn init(text: []const []const u8, rect: Rect, content: Rect, scroll: *c.Vector2, view: *Rect) Self {
        _ = view;
        _ = scroll;
        return .{
            .text = text,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
            .content = .{
                .x = content.x,
                .y = content.y,
                .width = content.width,
                .height = content.height,
            },
        };
    }

    /// Draw/Update loop should handle the destruction of the ScrollPanel
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *Self) void {
        _ = c.GuiScrollPanel(self.rect, @as([*c]const u8, self.text.ptr), self.content, &self.scroll, &self.view);
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
