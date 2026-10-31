extends CanvasLayer

const F := preload("res://ui/ui_factory.gd")
const S := preload("res://ui/ui_strings.gd")
var game: Node
var start_button: Button
var developer_button: Button
var boss_test_button: Button
var menu: VBoxContainer
var controls: VBoxContainer
var settings_view: VBoxContainer
var level_select: VBoxContainer
var root: Control
var drift := 0.0
var entrance: Tween

func _ready() -> void:
	layer = 40
	root = F.root(self)
	root.theme = preload("res://ui/ui_theme.tres")
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.05, 0.78)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 640
	center.add_child(panel)
	menu = F.box(panel)
	menu.add_theme_constant_override("separation", 16)
	F.label(menu, "// FRONTLINE SYSTEMS / READY", "AmberLabel")
	F.label(menu, S.TITLE, "TitleLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var stripe := TextureRect.new()
	stripe.texture = preload("res://ui/textures/hazard_stripe.png")
	stripe.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	stripe.stretch_mode = TextureRect.STRETCH_TILE
	stripe.custom_minimum_size.y = 8
	stripe.custom_minimum_size.x = 400
	stripe.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.add_child(stripe)
	F.label(menu, S.SUBTITLE, "EnergyLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var button_center := CenterContainer.new()
	menu.add_child(button_center)
	var buttons := F.box(button_center)
	buttons.custom_minimum_size.x = 400
	start_button = F.button(buttons, S.START, func(): show_levels(true))
	F.button(buttons, S.SETTINGS, func(): show_settings(true))
	F.button(buttons, S.CONTROLS, func(): show_controls(true))
	if not OS.has_feature("web"): F.button(buttons, S.QUIT, func(): get_tree().quit(), true)
	var tests := F.box(root, true)
	tests.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	tests.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tests.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tests.offset_right = -12
	tests.offset_bottom = -12
	developer_button = F.button(tests, S.DEVELOPER, func(): game.start_game("checkpoint", 0, true), true)
	boss_test_button = F.button(tests, S.BOSS_TEST, func(): game.start_game("checkpoint", 0, false, true), true)
	developer_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boss_test_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(menu, S.VERSION, "MutedLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls = F.box(panel)
	build_controls(controls, func(): show_controls(false))
	controls.hide()
	settings_view = preload("res://ui/settings_page.gd").new()
	settings_view.game = game
	settings_view.back = func(): show_settings(false)
	panel.add_child(settings_view)
	settings_view.hide()
	level_select = preload("res://ui/level_select.gd").new()
	level_select.game = game
	level_select.back = func(): show_levels(false)
	panel.add_child(level_select)
	level_select.hide()
	visibility_changed.connect(func():
		if visible:
			show_controls(false)
			start_button.grab_focus()
			if entrance: entrance.kill()
			menu.modulate.a = 0
			entrance = create_tween()
			entrance.tween_property(menu, "modulate:a", 1.0, 0.25))
	start_button.grab_focus()

static func build_controls(parent: Node, back: Callable) -> void:
	F.label(parent, S.CONTROLS, "LargeLabel")
	var grid := GridContainer.new()
	grid.columns = 3
	parent.add_child(grid)
	for heading in ["KEYBOARD", "CONTROLLER", "ACTION"]: F.label(grid, heading, "AmberLabel")
	for row in S.CONTROLS_ROWS:
		for i in range(row.size()):
			if i < 2:
				var cap := preload("res://ui/key_cap.tscn").instantiate()
				cap.key_text = row[i]
				grid.add_child(cap)
			else: F.label(grid, row[i])
	F.button(parent, S.BACK, back)

func show_controls(value: bool) -> void:
	if is_instance_valid(level_select): level_select.hide()
	if is_instance_valid(settings_view): settings_view.hide()
	menu.visible = not value
	controls.visible = value
	if value: (controls.get_child(controls.get_child_count() - 1) as Button).grab_focus()
	else: start_button.grab_focus()

func show_settings(value: bool) -> void:
	level_select.hide()
	menu.visible = not value
	controls.hide()
	settings_view.visible = value
	if value:
		settings_view.rebuild()
		settings_view.back_button.grab_focus()
	else: start_button.grab_focus()

func show_levels(value: bool) -> void:
	menu.visible = not value
	controls.hide()
	settings_view.hide()
	level_select.visible = value
	if value: level_select.first_button.grab_focus()
	else: start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and (controls.visible or settings_view.visible or level_select.visible):
		if level_select.visible: show_levels(false)
		elif settings_view.visible: show_settings(false)
		else: show_controls(false)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not visible or game.state != "start": return
	drift += delta * 12
	game.background_layer.scroll_offset.x = -roundf(drift * 0.15)
	game.middle_layer.scroll_offset.x = -roundf(drift * 0.55)
	game.track_layer.scroll_offset.x = -roundf(drift)
