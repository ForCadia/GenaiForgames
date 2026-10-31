# Title terminal frame

The title page now uses the user's Downloads/复古科幻像素屏幕框架.png as its monitor artwork, processed through the built-in image_gen tool to remove the external background. The other complete standing terminal is not used. Original Downloads assets are unchanged.

Project asset: `assets/ui_title_terminal.png` (1254×1254 RGBA). The monitor's interior screen remains opaque; its exterior is transparent. Godot uses an AtlasTexture region `(0,105,1254,1000)` to omit empty top/bottom space without modifying the asset.

`ui/menu.gd` displays the artwork with a NinePatchRect: source margins left/right138, top250, bottom135; uniformly scaled border details, stretchable screen center, 704px outer width with 24px top/right margins. The 528px content panel has no second rectangular backing. Frame height follows content so Guest continuation and name-read errors fit. Existing buttons, sounds, mode/name semantics and gameplay are retained. The real-game attract background remains visible outside the terminal. Mission selection, build tree and settings retain their existing presentation.

Verification: Godot import, three existing checks (player_profiles_smoke/start_modes_smoke/settings_smoke), and real-render captures of first-entry title, Guest continuation, name error, selector and build tree. Some checks retain their known exit-only ObjectDB cleanup warnings. Temporary screenshots remain under tmp; no export was built.

## Exact edit prompt

> Edit this exact supplied pixel-art sci-fi monitor frame for a Godot game UI. Remove ONLY the dark backdrop OUTSIDE the metal monitor silhouette, making the exterior fully transparent. Preserve the original olive/bronze metal frame design, cyan light bars, amber hazard corners, antenna, bolts, vents and crisp pixel clusters. Preserve the entire INSIDE dark blue screen as opaque, blank and clean. Do not add text, symbols, buttons, new objects, a stand or new frame details. Keep its same frontal perspective and proportions. Crop away excess empty outer padding, retaining the complete antenna and frame with about 8 pixels of transparent padding. Output one isolated monitor frame with genuinely transparent exterior.

Built-in image_gen was used, not the API/CLI fallback. Its resulting canvas retained some padding, handled by the Godot atlas region described above.
