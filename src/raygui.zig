//! Custom bindings for raygui.
//!
//! Tries to me more zig-like

const std = @import("std");

/// Container items from Raygui
pub const containers = @import("widgets/containers.zig");

/// Control elements from Raugui
pub const elements = @import("widgets/elements.zig");

/// Custom elements provided by this library.
pub const custom = @import("widgets/custom.zig");

/// C api made available for more direct contro / access to constants.
pub const c = @import("c.zig");

// --------------------------------------------------------------------
//                           GLOBALS
// --------------------------------------------------------------------

/// Functions not associated with anyspecific controls.
pub const config = struct {
    /// Global gui state control functions
    pub const global = struct {
        /// Enable gui controls
        pub fn enable() void {
            c.GuiEnable();
        }

        /// Disable gui controls
        pub fn disable() void {
            c.GuiDisable();
        }

        /// Lock gui controls
        pub fn lock() void {
            c.GuiLock();
        }

        /// Unlock gui controls
        pub fn unlock() void {
            c.GuiUnlock();
        }

        /// Check if gui is locked
        pub fn isLocked() bool {
            return c.GuiIsLocked();
        }

        /// Set controls alpha
        ///
        /// Will auto clamp:
        /// `0.0f <= alpha <= 1.0f`
        pub fn setAlpha(alpha: f32) void {
            if (alpha < 0.0 or alpha > 1.0) {
                std.log.err("Invalid alpha value [{d}], clamping to [0.0f, 1.0f].", .{alpha});
            }

            c.GuiSetAlpha(std.math.clamp(alpha, 0.0, 1.0));
        }

        /// Set gui state
        pub fn setState(state: i32) void {
            c.GuiSetState(state);
        }

        /// Get gui state
        pub fn getState() i32 {
            return c.GuiGetState();
        }
    };

    /// Font functions
    pub const fonts = struct {
        /// Set gui custom font
        pub fn setFont(font: c.Font) void {
            c.GuiSetFont(font);
        }

        /// Get gui custom font
        pub fn getFont() c.Font {
            return c.GuiGetFont();
        }
    };

    /// Style functions
    pub const styles = struct {
        /// Set one style property
        pub fn setStyle(control: i32, property: i32, value: i32) void {
            c.GuiSetStyle(control, property, value);
        }

        /// Get one style property
        pub fn getStyle(control: i32, property: i32) i32 {
            return c.GuiGetStyle(control, property);
        }

        /// Load style file over global style variable (.rgs)
        pub fn loadStyle(fileName: []const u8) void {
            c.GuiLoadStyle(fileName);
        }

        /// Load style default over global style
        pub fn loadStyleDefault() void {
            c.GuiLoadStyleDefault();
        }
    };

    /// Tooltips management functions
    pub const tooltips = struct {
        /// Enable gui tooltips
        pub fn enableTooltip() void {
            c.GuiEnableTooltip();
        }

        /// Disable gui tooltips
        pub fn disableTooltip() void {
            c.GuidisableTooltip();
        }

        /// Set tooltip string
        pub fn setTooltip(tooltip: []const u8) void {
            c.GuiSetTooltip(tooltip);
        }
    };
};

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

/// Interface for all the widgets/controls provided by this library.
pub const Widget = union(enum) {
    const Self = @This();

    window: *containers.Window,
    groupbox: *containers.GroupBox,
    line: *containers.Line,
    tabbar: *containers.TabBar,
    scrollpanel: *containers.ScrollPanel,

    checkbox: *elements.Checkbox,
    button: *elements.Button,
    label: *elements.Label,
    toggle: *elements.Toggle,
    dropdown: *elements.DropdownBox,

    pub fn draw(self: *Self) void {
        switch (self.*) {
            inline else => |*case| case.*.draw(),
        }
    }

    pub fn getRect(self: *Self) Rect {
        const cRect: c.Rectangle = switch (self.*) {
            inline else => |*case| case.*.*.rect,
        };

        return Rect{
            .x = cRect.x,
            .y = cRect.y,
            .width = cRect.width,
            .height = cRect.height,
        };
    }

    pub fn resize(self: *Self, w: f32, h: f32) void {
        switch (self.*) {
            inline else => |*case| case.*.resize(w, h),
        }
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        switch (self.*) {
            inline else => |*case| case.*.move(x, y),
        }
    }
};
