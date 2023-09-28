# zig-raygui

A WIP binding for raygui for zig.

You must provide a method to use raylib in your project, this can be done using
```zig
exe.linkSystemLibrary("raylib");
```

```zig
const raylib = b.dependency("raylib");
b.installArtifact(raylib.artifact("raylib"))
```
or a wrapper such as [Not-Nik/raylib-zig](https://github.com/Not-Nik/raylib-zig).

To actually use this library, add the following to your `build.zig`:

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
