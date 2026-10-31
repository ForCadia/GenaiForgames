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
var build_view: VBoxContainer
var wallet_label: Label
var center: CenterContainer
var panel: PanelContainer
var build_button: Button
var root: Control
var fresh_guest_button: Button
var name_input: LineEdit
var profile_label: Label
var profile_notice: Label
var drift := 0.0
var entrance: Tween

func _ready() -> void:
	layer = 40
	root = F.root(self)
	root.theme = preload("res://ui/menu_style.gd").theme()
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.05, 0.40)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center = CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = 640
	center.add_child(panel)
	menu = F.box(panel)
	menu.add_theme_constant_override("separation", 14)
	F.label(menu, "// FRONTLINE SYSTEMS / READY", "AmberLabel")
	F.label(menu, S.TITLE, "TitleLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var stripe := TextureRect.new()
	stripe.texture = preload("res://ui/textures/hazard_stripe.png")
	stripe.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	stripe.stretch_mode = TextureRect.STRETCH_TILE
	stripe.custom_minimum_size.y = 8
	stripe.custom_minimum_size.x = 440
	stripe.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.add_child(stripe)
	F.label(menu, S.SUBTITLE, "EnergyLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var button_center := CenterContainer.new()
	menu.add_child(button_center)
	var buttons := F.box(button_center)
	buttons.custom_minimum_size.x = 440
	buttons.add_theme_constant_override("separation", 12)
	start_button = preload("res://ui/menu_style.gd").primary(F.button(buttons, S.START + "  [ENTER]", func(): game.open_player_session()))
	start_button.custom_minimum_size.y = 56
	var modes := F.box(buttons,true)
	modes.add_theme_constant_override("separation",12)
	fresh_guest_button = F.button(modes,"新游客 / 从零开始",func(): game.enter_guest_session(),true)
	fresh_guest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.button(modes,"开发模式",func(): game.enter_development_session(),true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var identity := F.box(buttons,true)
	identity.add_theme_constant_override("separation",12)
	name_input = LineEdit.new()
	name_input.placeholder_text = "输入名字读取 / 创建存档"
	name_input.max_length = 32
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_input.custom_minimum_size.y = 40
	identity.add_child(name_input)
	name_input.text_submitted.connect(func(_value: String): _load_name())
	F.button(identity,"读取存档",_load_name,true)
	profile_label = F.label(buttons,"","MutedLabel")
	profile_notice = F.label(buttons,"","AmberLabel")
	profile_notice.hide()

	var secondary := HBoxContainer.new()
	secondary.alignment = BoxContainer.ALIGNMENT_CENTER
	secondary.add_theme_constant_override("separation", 10)
	buttons.add_child(secondary)
	F.button(secondary, S.SETTINGS, func(): show_settings(true), true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.button(secondary, S.CONTROLS, func(): show_controls(true), true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not OS.has_feature("web"): F.button(secondary, S.QUIT, func(): get_tree().quit(), true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tests := F.box(root, true)
	tests.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	tests.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tests.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tests.offset_right = -12
	tests.offset_bottom = -12
	developer_button = F.button(tests, S.DEVELOPER, func(): game.start_game("checkpoint", 0, true), true)
	boss_test_button = F.button(tests, S.BOSS_TEST, func(): game.start_game("checkpoint", 0, false, true), true)
	developer_button.text = "LAB / 调参"
	boss_test_button.text = "DEV / BOSS"
	for button in [developer_button,boss_test_button]:
		button.theme_type_variation = "MenuCompact"
		button.custom_minimum_size = Vector2(112,32)
	developer_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boss_test_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(menu, "v0.1", "MutedLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	build_button = level_select.build_button
	wallet_label = level_select.wallet_label
	level_select.hide()
	build_view = preload("res://ui/build_tree.gd").new()
	build_view.game = game
	build_view.back = func(): show_build(false)
	build_view.theme = preload("res://ui/ui_theme.tres")
	panel.add_child(build_view)
	build_view.hide()
	visibility_changed.connect(func():
		if visible:
			show_controls(false)
			start_button.grab_focus()
			if entrance: entrance.kill()
			menu.modulate.a = 0
			entrance = create_tween()
			entrance.tween_property(menu, "modulate:a", 1.0, 0.25))
	start_button.grab_focus()
	root.resized.connect(_position_menu)
	panel.minimum_size_changed.connect(_position_menu)
	_position_menu()

static func build_controls(parent: Node, back: Callable) -> void:
	parent.custom_minimum_size.x = 600
	parent.add_theme_constant_override("separation", 12)
	F.label(parent, S.CONTROLS, "LargeLabel")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",6)
	parent.add_child(grid)
	for heading in ["ACTION", "KEYBOARD", "CONTROLLER"]: F.label(grid,heading,"AmberLabel")
	for row in S.CONTROLS_ROWS:
		var action := str(row[2])
		if action.begins_with("HOLD TO MOVE"): action = "MOVE / RETURN"
		var label := F.label(grid,action,"MutedLabel")
		label.custom_minimum_size = Vector2(208,28)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		for index in range(2):
			var cap := PanelContainer.new()
			cap.custom_minimum_size = Vector2(176,28)
			cap.add_theme_stylebox_override("panel",preload("res://ui/menu_style.gd").frame(Color("111b2a"),Color("44586f"),5))
			grid.add_child(cap)
			F.label(cap,str(row[index]),"MutedLabel")
	F.label(parent,"Hold A / D to adjust position; release to return.","MutedLabel")
	preload("res://ui/menu_style.gd").primary(F.button(parent,S.BACK,back))

func show_controls(value: bool) -> void:
	panel.add_theme_stylebox_override("panel",preload("res://ui/menu_style.gd").frame(Color("0b121cf5"),Color("44586f"),20))
	if is_instance_valid(build_view): build_view.hide()
	if is_instance_valid(developer_button): developer_button.get_parent().show()
	if is_instance_valid(level_select): level_select.hide()
	if is_instance_valid(settings_view): settings_view.hide()
	menu.visible = not value
	_position_menu()
	controls.visible = value
	if value: (controls.get_child(controls.get_child_count() - 1) as Button).grab_focus()
	else: start_button.grab_focus()

func show_settings(value: bool) -> void:
	build_view.hide()
	level_select.hide()
	menu.visible = not value
	_position_menu()
	controls.hide()
	settings_view.visible = value
	if value:
		settings_view.rebuild()
		settings_view.back_button.grab_focus()
	else: start_button.grab_focus()

func show_levels(value: bool) -> void:
	panel.add_theme_stylebox_override("panel",preload("res://ui/menu_style.gd").frame(Color("0b121cf5"),Color("44586f"),20))
	build_view.hide()
	menu.visible = not value
	_position_menu()
	controls.hide()
	settings_view.hide()
	level_select.visible = value
	if value:
		level_select.refresh()
		level_select.first_button.grab_focus()
	else: start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and (controls.visible or settings_view.visible or level_select.visible or build_view.visible):
		if build_view.visible: show_build(false)
		elif level_select.visible: show_levels(false)
		elif settings_view.visible: show_settings(false)
		else: show_controls(false)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not visible or game.state != "start": return
	fresh_guest_button.visible = game.play_profile != "development"
	wallet_label.text = "%d G" % game.progression.coins
	match game.play_profile:
		"guest":
			start_button.text = "继续游客游戏 [ENTER]"
			profile_label.text = "游客 / 本次进度不保存"
		"named":
			start_button.text = "继续游戏 [ENTER]"
			profile_label.text = "存档：" + game.progression.profile_name.left(20)
		_:
			start_button.text = "游客模式 [ENTER]"
			profile_label.text = "开发存档 / 保留当前状态，全部关卡开放"

func show_build(value: bool) -> void:
	if not value:
		show_levels(true)
		developer_button.get_parent().show()
		level_select.build_button.grab_focus()
		return
	panel.add_theme_stylebox_override("panel",preload("res://ui/menu_style.gd").frame(Color("0b121cf5"),Color("44586f"),12 if value else 20))
	menu.visible = not value
	_position_menu()
	controls.hide()
	settings_view.hide()
	level_select.hide()
	build_view.visible = value
	developer_button.get_parent().visible = not value
	if value:
		build_view.refresh()
		build_view.graph.buttons[build_view.selected].grab_focus()
	else: start_button.grab_focus()

func _position_menu() -> void:
	# Keep the title panel 24 logical pixels from the top and right edges.
	# Center the larger subpages as before.
	if menu.visible:
		var minimum := panel.get_combined_minimum_size()
		center.offset_left = maxf(0.0, root.size.x - minimum.x - 48.0)
		center.offset_top = 48.0 + minimum.y - root.size.y
	else:
		center.offset_left = 0
		center.offset_top = 0

func _load_name() -> void:
	if game.enter_named_session(name_input.text):
		profile_notice.hide()
	else:
		profile_notice.text = "请输入名字" if name_input.text.strip_edges().is_empty() else "存档无法读取，原有进度未更改"
		profile_notice.show()
