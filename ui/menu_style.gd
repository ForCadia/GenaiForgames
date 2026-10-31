extends RefCounted
const BG := Color("0b121c")
const EDGE := Color("44586f")
const TEXT := Color("e8f0f8")
const MUTED := Color("9fb2c8")
const CYAN := Color("3de0f2")
const AMBER := Color("ffb224")
const RED := Color("ff4458")

static func frame(fill := BG, edge := EDGE, padding := 20) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.corner_detail = 1
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(side, padding)
	return style

static func theme() -> Theme:
	var result: Theme = preload("res://ui/ui_theme.tres").duplicate()
	result.set_stylebox("panel", "PanelContainer", frame(Color("0b121cf5"), EDGE, 20))
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "MutedLabel", MUTED)
	result.set_font_size("font_size", "SmallLabel", 16)
	result.set_font_size("font_size", "MutedLabel", 12)
	for variation in ["Button", "SecondaryButton", "MenuPrimary", "MenuDanger", "MenuCompact"]:
		if variation != "Button": result.set_type_variation(variation, "Button")
		result.set_font_size("font_size", variation, 16 if variation != "MenuCompact" else 12)
		result.set_color("font_color", variation, TEXT)
		result.set_color("font_hover_color", variation, Color.WHITE)
		result.set_color("font_pressed_color", variation, TEXT)
		result.set_color("font_focus_color", variation, AMBER)
		result.set_color("font_disabled_color", variation, Color("6f8299"))
		for state in ["normal", "hover", "pressed", "disabled"]:
			var fill := Color("111b2a")
			var edge := EDGE
			if state == "hover": fill = Color("172436"); edge = Color("7f95ad")
			if state == "pressed": fill = Color("25384b")
			if state == "disabled": fill = Color("0d1520"); edge = Color("2a3a4f")
			if variation == "MenuPrimary" and state != "disabled": fill = Color("332609"); edge = AMBER
			if variation == "MenuDanger" and state != "disabled": edge = Color("7a2a34")
			result.set_stylebox(state, variation, frame(fill, edge, 10))
		var focus := frame(Color(0,0,0,0), AMBER, 0)
		focus.set_border_width_all(2)
		result.set_stylebox("focus", variation, focus)
	for orientation in ["HSlider","VSlider"]:
		result.set_stylebox("slider",orientation,frame(Color("2a3a4f"),Color("2a3a4f"),3))
		result.set_stylebox("grabber_area",orientation,frame(Color("1c6f7c"),Color("1c6f7c"),3))
	for orientation in ["VScrollBar","HScrollBar"]:
		result.set_stylebox("scroll",orientation,frame(Color("111b2a"),Color("111b2a"),3))
		for state in ["grabber","grabber_highlight","grabber_pressed"]:
			result.set_stylebox(state,orientation,frame(AMBER,AMBER,3))
	return result

static func primary(button: Button) -> Button:
	button.theme_type_variation = "MenuPrimary"
	button.custom_minimum_size.y = 48
	return button
