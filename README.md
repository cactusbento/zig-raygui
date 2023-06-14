# zig-raygui

A WIP binding for raygui for zig.

Will turn into a library in future using `build.zig` after zig-0.11.0, but for now, I'll just stick with the current setup.

You must provide the necessary setup to include both `raylib.h` and `raygui.h` in `raygui.zig`.
This can be done by using `exe.linkSystemLibrary([]const u8)`, `exe.addIncludePath([]const u8)`, or just adding the headers next to `raygui.zig`.

## TODO

* Create a better method to render things in a container element. (This include making a better interface for both elements and containers)
    * Containers should nest without problems/major hacks
* Implement scrollable containers.
* Implement bindings for the rest of `raygui.h`
