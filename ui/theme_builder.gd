extends RefCounted

static func build() -> Theme:
	var p = preload("res://ui/ui_palette.gd")
	var theme := Theme.new()
	var font := load("res://assets/fonts/FusionPixel.otf") as FontFile
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	theme.default_font = font
	theme.default_font_size = p.MEDIUM
	for type in ["Label", "Button", "OptionButton", "CheckButton", "LineEdit", "PopupMenu", "SpinBox"]:
		theme.set_color("font_color", type, p.TEXT)
	for spec in [["SmallLabel",p.SMALL,p.TEXT],["MutedLabel",p.SMALL,p.TEXT_DIM],["AmberLabel",p.SMALL,p.AMBER],["EnergyLabel",p.SMALL,p.CYAN],["DangerLabel",p.LARGE,p.RED],["LargeLabel",p.LARGE,p.TEXT],["TitleLabel",p.TITLE,p.TEXT]]:
		theme.set_type_variation(spec[0], "Label")
		theme.set_font_size("font_size", spec[0], spec[1])
		theme.set_color("font_color", spec[0], spec[2])
	theme.set_color("font_shadow_color", "Label", p.BLACK)
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)
	var panel := texture_style("panel_chamfer")
	for type in ["PanelContainer", "Panel", "PopupMenu"]: theme.set_stylebox("panel", type, panel)
	for type in ["Button", "OptionButton"]:
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			theme.set_stylebox(state, type, texture_style("button_" + state))
		theme.set_color("font_hover_color", type, p.AMBER)
		theme.set_color("font_focus_color", type, p.AMBER)
		theme.set_color("font_pressed_color", type, p.AMBER)
		theme.set_color("font_disabled_color", type, p.TEXT_DIM)
	theme.set_type_variation("SecondaryButton", "Button")
	theme.set_font_size("font_size", "SecondaryButton", p.SMALL)
	theme.set_color("font_color", "SecondaryButton", p.TEXT_DIM)
	theme.set_type_variation("SlotButton", "Button")
	theme.set_font_size("font_size", "SlotButton", p.SMALL)
	theme.set_type_variation("ActiveSlot", "SlotButton")
	theme.set_stylebox("normal", "ActiveSlot", texture_style("button_hover"))
	for type in ["HBoxContainer", "VBoxContainer", "GridContainer"]:
		theme.set_constant("separation", type, p.GAP)
		theme.set_constant("h_separation", type, p.PAD)
		theme.set_constant("v_separation", type, p.GAP)
	for side in ["left", "right", "top", "bottom"]: theme.set_constant("margin_"+side, "MarginContainer", p.MARGIN)
	for spec in [["ProgressBar",p.CYAN],["BossBar",p.RED],["TrailBar",Color(p.TEXT,0.6)],["ReloadBar",p.AMBER]]:
		if spec[0] != "ProgressBar": theme.set_type_variation(spec[0], "ProgressBar")
		var bg := StyleBoxFlat.new(); bg.bg_color = p.EMPTY
		var fill := StyleBoxFlat.new(); fill.bg_color = spec[1]
		theme.set_stylebox("background",spec[0],bg); theme.set_stylebox("fill",spec[0],fill)
	var line := StyleBoxLine.new(); line.color = p.PANEL_EDGE; line.thickness = 2
	theme.set_stylebox("separator","HSeparator",line)
	return theme

static func texture_style(filename: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load("res://ui/textures/"+filename+".png")
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,8)
		style.set_content_margin(side,12)
	return style
