extends Node
signal language_changed

const DEFAULTS := {
	"master": 80.0, "music": 100.0, "sfx": 90.0, "muted": false,
	"fullscreen": false, "vsync": true, "tutorials": true,
	"reduced_flash": false, "death_camera": true, "cosmetic_vfx": true,
	"language": "zh_CN",
}
const SAVE_PATH := "user://settings.cfg"
var options := DEFAULTS.duplicate()
var preview := AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	preload("res://ui/translations.gd").install()
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
			AudioServer.set_bus_send(index, "Master")
	var guarded := false
	for index in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0, index).resource_name == "EverFront Peak Guard": guarded = true
	if not guarded:
		var limiter := AudioEffectHardLimiter.new()
		limiter.resource_name = "EverFront Peak Guard"
		limiter.ceiling_db = -1.0
		AudioServer.add_bus_effect(0, limiter)
	if not _test_mode():
		var config := ConfigFile.new()
		if config.load(SAVE_PATH) == OK:
			for key in DEFAULTS:
				var value: Variant = config.get_value("settings", key, DEFAULTS[key])
				if key == "language":
					if value is String and value in ["zh_CN", "en"]: options[key] = value
				elif typeof(DEFAULTS[key]) == TYPE_BOOL:
					if value is bool: options[key] = value
				elif value is float or value is int: options[key] = clampf(float(value), 0, 100)
	TranslationServer.set_locale(options.language)
	apply_audio()
	if not _test_mode(): apply_display(not OS.get_cmdline_args().has("--fullscreen"))
	preview.bus = "SFX"
	preview.stream = preload("res://assets/sfx/item_pickup.wav")
	preview.volume_db = preload("res://audio_mix.gd").gain("item_pickup.wav")
	add_child(preview)

func _test_mode() -> bool:
	return "--lab-test" in OS.get_cmdline_user_args()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		set_option("muted",not bool(options.muted))
		get_viewport().set_input_as_handled()

func display_supported() -> bool:
	return DisplayServer.get_name() != "headless" and not OS.has_feature("web")

func fullscreen_supported() -> bool:
	return display_supported() and not OS.get_cmdline_args().has("--wid")

func set_option(key: String, value: Variant) -> void:
	if not DEFAULTS.has(key): return
	if key == "language":
		if value not in ["zh_CN", "en"] or options.language == value: return
		options.language = value
		TranslationServer.set_locale(value)
		save()
		language_changed.emit()
		return
	options[key] = bool(value) if DEFAULTS[key] is bool else clampf(float(value), 0, 100)
	apply_audio()
	if key in ["fullscreen", "vsync"]: apply_display()
	save()

func apply_audio() -> void:
	for spec in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"]]:
		var index := AudioServer.get_bus_index(spec[0])
		var amount: float = float(options[spec[1]]) / 100.0
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(amount, 0.0001)))
		AudioServer.set_bus_mute(index, amount <= 0 or (spec[0] == "Master" and bool(options.muted)))

func apply_display(include_fullscreen := true) -> void:
	if not display_supported(): return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if options.vsync else DisplayServer.VSYNC_DISABLED)
	if not include_fullscreen or not fullscreen_supported(): return
	var current := DisplayServer.window_get_mode()
	var is_full := current in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	if options.fullscreen and not is_full: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not options.fullscreen and is_full: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func restore_defaults() -> void:
	var previous_language: String = options.language
	options = DEFAULTS.duplicate()
	TranslationServer.set_locale(options.language)
	apply_audio()
	apply_display()
	save()
	if previous_language != options.language: language_changed.emit()

func save() -> void:
	if _test_mode(): return
	var config := ConfigFile.new()
	for key in options: config.set_value("settings", key, options[key])
	config.save(SAVE_PATH)

func preview_sound() -> void:
	preview.play()
