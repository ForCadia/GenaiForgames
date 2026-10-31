extends VBoxContainer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
var game: Node
var back: Callable
var body: BoxContainer
var back_button: Button
var scroll: ScrollContainer

func _ready() -> void:
	custom_minimum_size.x = 600
	add_theme_constant_override("separation", 12)
	rebuild()

func rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	F.label(self, "SETTINGS", "LargeLabel")
	scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(600, 352)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)
	body = F.box(scroll)
	body.add_theme_constant_override("separation", 4)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section("AUDIO")
	for spec in [["master", "MASTER VOLUME"], ["music", "MUSIC VOLUME"], ["sfx", "SOUND EFFECTS"]]: add_volume(spec[0],spec[1])
	add_toggle("muted", "MUTE ALL")
	if game.settings.display_supported():
		section("DISPLAY")
		var fullscreen := add_toggle("fullscreen", "FULLSCREEN")
		fullscreen.disabled = not game.settings.fullscreen_supported()
		if fullscreen.disabled: fullscreen.tooltip_text = "Available in the standalone game window."
		add_toggle("vsync", "VERTICAL SYNC")
	section("ACCESSIBILITY / PRESENTATION")
	add_toggle("tutorials", "SHOW TUTORIAL HINTS")
	add_toggle("reduced_flash", "REDUCE SCREEN FLASH")
	add_toggle("death_camera", "DEATH CAMERA MOTION")
	F.label(self, "SCROLL FOR MORE  /  Changes apply and save automatically.", "MutedLabel")
	var actions := F.box(self,true)
	actions.add_theme_constant_override("separation",12)
	F.button(actions,"PREVIEW SOUND",func(): game.settings.preview_sound(),true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var reset := F.button(actions,"RESTORE DEFAULTS",func(): game.settings.restore_defaults(); rebuild(),true)
	reset.theme_type_variation = "MenuDanger"
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button = STYLE.primary(F.button(self,"BACK",back))

func section(title: String) -> void:
	var row := F.box(body,true)
	row.custom_minimum_size.y = 28
	row.add_theme_constant_override("separation",12)
	F.label(row,title,"AmberLabel").size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var line := HSeparator.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(line)

func add_volume(key: String, title: String) -> void:
	var row := F.box(body,true)
	row.custom_minimum_size.y = 44
	row.add_theme_constant_override("separation",12)
	var label := F.label(row,title,"MutedLabel")
	label.custom_minimum_size.x = 172
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var slider := HSlider.new()
	slider.max_value = 100
	slider.step = 1
	slider.value = game.settings.options[key]
	slider.custom_minimum_size = Vector2(240,32)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)
	var value_label := F.label(row,"%3d%%" % roundi(slider.value),"AmberLabel")
	value_label.custom_minimum_size.x = 48
	value_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(func(value: float):
		value_label.text = "%3d%%" % roundi(value)
		game.settings.set_option(key,value))

func add_toggle(key: String, title: String) -> Button:
	var toggle := Button.new()
	toggle.toggle_mode = true
	toggle.button_pressed = bool(game.settings.options[key])
	toggle.custom_minimum_size.y = 44
	toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	toggle.add_theme_font_size_override("font_size",12)
	var state := Label.new()
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	state.offset_left = -88
	state.offset_right = -16
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	toggle.add_child(state)
	var update := func(value: bool):
		state.text = "■ ON" if value else "□ OFF"
		state.modulate = STYLE.CYAN if value else STYLE.MUTED
	toggle.text = title
	update.call(toggle.button_pressed)
	toggle.toggled.connect(func(value: bool): update.call(value); game.settings.set_option(key,value))
	body.add_child(toggle)
	return toggle
