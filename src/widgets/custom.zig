const c = @import("../c.zig");
const rgui = @import("../raygui.zig");
const containers = rgui.containers;
const elements = rgui.elements;

const std = @import("std");

pub const MenuBar = struct {
    allocator: std.mem.Allocator,

    rect: c.Rectangle,

    categories: std.ArrayList(*Category),

    pub const Category = struct {
        allocator: std.mem.Allocator,

        /// Whether to show the underlying menu.
        active: bool = false,

        name: []const u8,
        rect: c.Rectangle,
        top_level_button: elements.Button,

        option_list: std.ArrayList(elements.Button),

        pub fn init(allocator: std.mem.Allocator, name: []const u8) Category {
            return .{
                .allocator = allocator,
                .name = name,
                .rect = undefined,

                .top_level_button = elements.Button.init(name, rgui.Rect{}),
                .option_list = std.ArrayList(elements.Button).init(allocator),
            };
        }

        pub fn deinit(self: *Category) void {
            self.option_list.deinit();
        }

        pub fn draw(self: *Category) void {
            const text_len_px = c.MeasureText(
                @ptrCast(self.name),
                @intFromFloat(self.rect.height - 4 - 2),
            );
            self.rect.width = @floatFromInt(text_len_px + 4);

            self.top_level_button.rect = self.rect;
            self.top_level_button.draw();
        }
    };

    pub fn init(allocator: std.mem.Allocator, rect: rgui.Rect) MenuBar {
        return .{
            .allocator = allocator,
            .rect = .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.width,
                .height = rect.height,
            },
            .categories = std.ArrayList(*Category).init(allocator),
        };
    }

    pub fn deinit(self: *MenuBar) void {
        self.categories.deinit();
    }

    /// Draw/Update loop should handle the destruction of the GroupBox
    /// Will loop through self.elements to draw what it has.
    pub fn draw(self: *MenuBar) void {
        c.DrawRectangleRec(self.rect, c.GRAY);

        // Draw button for each category.
        // Each category will draw its own list.
        for (self.categories.items, 0..) |*cat, i| {
            const cat_rect = c.Rectangle{
                .x = 150 * @as(f32, @floatFromInt(i)),
                .width = 150,

                .y = self.rect.y,
                .height = self.rect.height,
            };

            cat.*.rect = cat_rect;
            cat.*.draw();
        }
    }

    pub fn move(self: *MenuBar, x: f32, y: f32) void {
        self.rect.x = x;
        self.rect.y = y;
    }

    pub fn resize(self: *MenuBar, width: f32, height: f32) void {
        self.rect.width = width;
        self.rect.height = height;
    }
};
