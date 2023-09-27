pub usingnamespace @cImport({
    @cInclude("raylib.h");

    // import raygui
    // @cDefine("RAYGUI_IMPLEMENTATION", {}); // zig segfaults 0.12.0-596
    @cInclude("raygui.h");
});
