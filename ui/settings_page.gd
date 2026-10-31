extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
var game: Node
var back: Callable
var body: BoxContainer
var back_button: Button

func _ready() -> void:
	custom_minimum_size.x = 560
	rebuild()

func rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	F.label(self, "SETTINGS", "LargeLabel")
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	body = F.box(scroll)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(body, "AUDIO", "AmberLabel")
	for spec in [["master", "MASTER VOLUME"], ["music", "MUSIC VOLUME"], ["sfx", "SOUND EFFECTS"]]:
		add_volume(spec[0], spec[1])
	add_toggle("muted", "MUTE ALL")
	if game.settings.display_supported():
		F.label(body, "DISPLAY", "AmberLabel")
		var fullscreen := add_toggle("fullscreen", "FULLSCREEN")
		fullscreen.disabled = not game.settings.fullscreen_supported()
		if fullscreen.disabled: F.label(body, "Fullscreen is available in the standalone game window.", "MutedLabel")
		add_toggle("vsync", "VERTICAL SYNC")
	F.label(body, "ACCESSIBILITY / PRESENTATION", "AmberLabel")
	add_toggle("tutorials", "SHOW TUTORIAL HINTS")
	add_toggle("reduced_flash", "REDUCE SCREEN FLASH")
	add_toggle("death_camera", "DEATH CAMERA MOTION")
	F.label(self, "Changes apply immediately and are saved automatically.", "MutedLabel")
	var actions := F.box(self, true)
	F.button(actions, "PREVIEW SOUND", func(): game.settings.preview_sound(), true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.button(actions, "RESTORE DEFAULTS", func(): game.settings.restore_defaults(); rebuild(), true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button = F.button(self, "BACK", back)

func add_volume(key: String, title: String) -> void:
	var row := F.box(body, true)
	var label := F.label(row, title)
	label.custom_minimum_size.x = 150
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = game.settings.options[key]
	slider.custom_minimum_size = Vector2(240, 30)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	var value_label := F.label(row, "%3d%%" % roundi(slider.value), "AmberLabel")
	value_label.custom_minimum_size.x = 48
	slider.value_changed.connect(func(value: float):
		value_label.text = "%3d%%" % roundi(value)
		game.settings.set_option(key, value))

func add_toggle(key: String, title: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.text = title
	toggle.button_pressed = bool(game.settings.options[key])
	toggle.toggled.connect(func(value: bool): game.settings.set_option(key, value))
	body.add_child(toggle)
	return toggle
