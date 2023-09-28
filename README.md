# zig-raygui

A WIP binding for raygui for zig.

Will turn into a library in future using `build.zig`, but for now, I'll just stick with the current setup.

You must provide the necessary setup to include both `raylib.h` and `raygui.h` in `raygui.zig`.
This can be done by using `exe.linkSystemLibrary([]const u8)`, `exe.addIncludePath([]const u8)`, or just adding the headers next to `raygui.zig`.

```zig
const raygui = b.dependency("raygui-zig");
const raysan_raygui = raygui.builder.dependency("raygui", .{});
exe.addIncludePath(
    raysan_raygui.path("src"),
);
```

## Note

Due to a regression in the zig compiler, your `build.zig` must 
contain 

```zig
const raygui = b.dependency("raygui-zig");
exe.addCSourceFile(
    .{
        .file = raygui.path("src/rgui_i.c"),
        .flags = &[_][]const u8{},
    },
);
```

## TODO (In order of priority)

* Implement bindings for the rest of `raygui.h`
* Create proper docs for the autodoc.
* Create a better method to render things in a container element. (This include making a better interface for both elements and containers)
    * Containers should nest without problems/major hacks
* Implement scrollable containers.
