const c = @cImport({
    @cInclude("raylib.h");

    // import raygui
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});
