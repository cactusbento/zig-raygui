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
        open: bool = false,

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

        pub fn add(self: *Category, name: []const u8) !void {
            var button = elements.Button.init(name, .{});
            try self.option_list.append(button);
        }

        pub fn draw(self: *Category) void {
            const prev_button = self.top_level_button.value;

            const text_len_px = c.MeasureText(
                @ptrCast(self.name),
                @intFromFloat(self.rect.height - 4 - 2),
            );
            self.rect.width = @floatFromInt(text_len_px + 4);

            self.top_level_button.rect = self.rect;
            self.top_level_button.draw();

            if (self.top_level_button.value and !prev_button) {
                self.open = !self.open;
            }

            if (self.open) {
                for (self.option_list.items, 0..) |*butt, i| {
                    butt.rect = .{
                        .x = self.rect.x,
                        .y = self.rect.y + @as(f32, @floatFromInt(i + 1)) * self.rect.height,
                        .width = 100,
                        .height = self.rect.height,
                    };

                    butt.draw();

                    if (butt.value) {
                        self.open = false;
                    }
                }
            }
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
                .x = self.rect.x + cat.*.rect.width * @as(f32, @floatFromInt(i)),
                .width = cat.*.rect.width,

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
