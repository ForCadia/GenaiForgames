extends CanvasLayer

const SPECS := {
	"jump_speed": ["Jump speed (px/s)", 720.0, 450.0, 950.0, 10.0],
	"gravity": ["Gravity (px/s2)", 1250.0, 800.0, 2000.0, 25.0],
	"stomp_speed": ["Stomp bounce (px/s)", 470.0, 200.0, 700.0, 10.0],
	"slide_time": ["Minimum slide (s)", 0.7, 0.1, 1.2, 0.05],
	"guard_drain": ["Guard drain (/s)", 66.67, 25.0, 120.0, 0.01],
	"guard_regen": ["Guard regen (/s)", 50.0, 20.0, 100.0, 1.0],
	"guard_delay": ["Guard regen delay (s)", 0.75, 0.1, 1.5, 0.05],
	"guard_lock": ["Guard break lock (s)", 0.5, 0.1, 1.5, 0.05],
	"rifle_cadence": ["Rifle shot interval (s)", 0.105, 0.05, 0.3, 0.005],
	"piercer_cadence": ["Piercer shot interval (s)", 0.52, 0.2, 1.0, 0.01],
	"scroll_multiplier": ["World scroll multiplier", 1.5, 0.75, 2.0, 0.05],
	"laser_gate_speed": ["Laser gate speed (px/s)", 315.0, 150.0, 500.0, 5.0],
}
var game: Node
var values := {}
var controls := {}
var sliders := {}
var expanded := false
var blocked := false
var release_pending := false
var body: VBoxContainer
var panel: PanelContainer
var summary_label: Label
var status_label: Label
var update_left := 0.0

func _ready() -> void:
	layer = 20
	var root := VBoxContainer.new()
	root.position = Vector2(570, 170)
	root.custom_minimum_size.x = 375
	add_child(root)
	var toggle := Button.new()
	toggle.text = "LAB B / Tuning [F1]"
	toggle.pressed.connect(toggle_panel)
	root.add_child(toggle)
	panel = PanelContainer.new()
	root.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(375, 430)
	panel.add_child(scroll)
	body = VBoxContainer.new()
	scroll.add_child(body)
	for key in SPECS:
		var spec: Array = SPECS[key]
		values[key] = spec[1]
		var row := HBoxContainer.new()
		body.add_child(row)
		var label := Label.new()
		label.text = "%s [%s..%s]" % [spec[0], spec[2], spec[3]]
		label.custom_minimum_size.x = 250
		label.add_theme_font_size_override("font_size", 11)
		row.add_child(label)
		var spin := SpinBox.new()
		spin.min_value = spec[2]
		spin.max_value = spec[3]
		spin.step = spec[4]
		spin.value = spec[1]
		spin.custom_minimum_size.x = 100
		spin.value_changed.connect(func(value: float):
			values[key] = value
			game.lab_parameters_changed(key))
		row.add_child(spin)
		controls[key] = spin
		var slider := HSlider.new()
		slider.min_value = spec[2]
		slider.max_value = spec[3]
		slider.step = spec[4]
		slider.value = spec[1]
		slider.custom_minimum_size.x = 350
		slider.value_changed.connect(func(value: float): spin.value = value)
		spin.value_changed.connect(func(value: float): slider.set_value_no_signal(value))
		body.add_child(slider)
		sliders[key] = slider
	var fx := CheckButton.new()
	fx.text = "Existing cosmetic particles"
	fx.button_pressed = true
	values["particles_enabled"] = true
	fx.toggled.connect(func(on: bool):
		values.particles_enabled = on
		game.lab_parameters_changed("particles_enabled"))
	controls["particles_enabled"] = fx
	body.add_child(fx)
	_add_button("Restore defaults", reset_defaults)
	_add_button("Export JSON [T]", export_data)
	_add_button("New tester: export + fresh session", new_tester)
	var help := Label.new()
	help.text = "Gameplay PAUSED while panel is open.\nEdits restart campaign and mark an administrative end.\nA/B pending your Prototype Card; 1/2 stay weapons."
	help.add_theme_font_size_override("font_size", 12)
	body.add_child(help)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 12)
	body.add_child(status_label)
	panel.visible = false
	summary_label = Label.new()
	summary_label.position = Vector2(18, 638)
	summary_label.add_theme_font_size_override("font_size", 12)
	add_child(summary_label)

func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	body.add_child(button)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F1:
			toggle_panel()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_T and not _editing_text():
			export_data()
			get_viewport().set_input_as_handled()

func _editing_text() -> bool:
	return get_viewport().gui_get_focus_owner() is LineEdit

func toggle_panel() -> void:
	expanded = not expanded
	panel.visible = expanded
	blocked = true
	release_pending = not expanded
	game.lab.record("panel_pause" if expanded else "panel_resume")
	# Timer-driven turrets and sprite animations pause with the simulation.
	get_tree().paused = expanded
	if not expanded:
		var focus := get_viewport().gui_get_focus_owner()
		if focus: focus.release_focus()

func _process(delta: float) -> void:
	if release_pending:
		var held := false
		for action in InputMap.get_actions():
			if Input.is_action_pressed(action): held = true
		if not held:
			release_pending = false
			blocked = false
	update_left -= delta
	if update_left <= 0:
		update_left = 0.25
		summary_label.text = "Variant: baseline (A/B pending)\n" + game.lab.summary() + "\nRetry = retried failures / all failures; median = death/victory runs."

func reset_defaults() -> void:
	for key in SPECS:
		values[key] = SPECS[key][1]
		controls[key].set_value_no_signal(values[key])
		sliders[key].set_value_no_signal(values[key])
	values.particles_enabled = true
	controls.particles_enabled.set_pressed_no_signal(true)
	game.lab_parameters_changed("restore_defaults")

func export_data() -> void:
	status_label.text = "JSON download requested; save it in telemetry/." if game.lab.export_json() else game.lab.last_error

func new_tester() -> void:
	# Archive first. Existing session files are never deleted.
	game.lab.finish(game.score, "session_change", game.player, game.segment, game.boss_mode)
	game.lab.failed_at = -1
	if not game.lab.export_json():
		status_label.text = game.lab.last_error + "; session retained."
		return
	game.lab.new_session()
	game._new_run()
	status_label.text = "New tester session. Previous archive retained locally."
