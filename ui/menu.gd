extends CanvasLayer

const F := preload("res://ui/ui_factory.gd")
const S := preload("res://ui/ui_strings.gd")
const TERMINAL_TEXTURE := preload("res://assets/ui_title_terminal.png")
const STANDING_TEXTURE := preload("res://assets/ui_title_terminal_stand.png")
var submenu_terminal: NinePatchRect
var submenu_empty := StyleBoxEmpty.new()
var submenu_padding := 20.0
var layout_busy := false
var terminal: NinePatchRect
var title_empty := StyleBoxEmpty.new()
var title_style_active := false
var game: Node
var start_button: Button
var developer_button: Button
var boss_test_button: Button
var boss_select: VBoxContainer
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
	terminal = NinePatchRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = STANDING_TEXTURE
	atlas.region = Rect2(135,10,1200,780)
	terminal.texture = atlas
	terminal.patch_margin_left = 160
	terminal.patch_margin_right = 180
	terminal.patch_margin_top = 270
	terminal.patch_margin_bottom = 80
	terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(terminal)
	submenu_terminal = NinePatchRect.new()
	var flat := AtlasTexture.new()
	flat.atlas = TERMINAL_TEXTURE
	flat.region = Rect2(0,250,1254,850)
	submenu_terminal.texture = flat
	submenu_terminal.patch_margin_left = 138
	submenu_terminal.patch_margin_right = 138
	submenu_terminal.patch_margin_top = 105
	submenu_terminal.patch_margin_bottom = 115
	submenu_terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(submenu_terminal)
	center = CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = 640
	center.add_child(panel)
	menu = F.box(panel)
	menu.add_theme_constant_override("separation", 10)
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
	var development_entry := F.button(tests,"开发模式",func(): game.enter_development_session(),true)
	developer_button = F.button(tests, S.DEVELOPER, func(): game.start_game("checkpoint", 0, true), true)
	boss_test_button = F.button(tests, S.BOSS_TEST, func(): show_bosses(true), true)
	developer_button.text = "LAB / 调参"
	boss_test_button.text = "DEV / BOSS"
	for button in [development_entry,developer_button,boss_test_button]:
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
	boss_select = F.box(panel)
	boss_select.add_theme_constant_override("separation",16)
	F.label(boss_select,"BOSS TEST / 选择首领","LargeLabel")
	preload("res://ui/menu_style.gd").primary(F.button(boss_select,"眼球 Boss",func(): game.start_game("checkpoint",0,false,true)))
	preload("res://ui/menu_style.gd").primary(F.button(boss_select,"枪刀机甲 Boss",func(): game.start_game("checkpoint",0,false,true,0,false,"mecha")))
	F.button(boss_select,"BACK",func(): show_bosses(false),true)
	boss_select.hide()
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
	panel.item_rect_changed.connect(_position_menu)
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
	if is_instance_valid(boss_select): boss_select.hide()
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
	if is_instance_valid(boss_select): boss_select.hide()
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
	if is_instance_valid(boss_select): boss_select.hide()
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
	if visible and event.is_action_pressed("ui_cancel") and (controls.visible or settings_view.visible or level_select.visible or build_view.visible or boss_select.visible):
		if boss_select.visible: show_bosses(false)
		elif build_view.visible: show_build(false)
		elif level_select.visible: show_levels(false)
		elif settings_view.visible: show_settings(false)
		else: show_controls(false)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not visible or game.state != "start": return
	fresh_guest_button.visible = game.play_profile != "development"
	fresh_guest_button.get_parent().visible = fresh_guest_button.visible
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
	if is_instance_valid(boss_select): boss_select.hide()
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
	if layout_busy: return
	layout_busy = true
	terminal.visible = menu.visible
	submenu_terminal.visible = not menu.visible
	if menu.visible:
		title_style_active = true
		if panel.get_theme_stylebox("panel") != title_empty:
			panel.add_theme_stylebox_override("panel",title_empty)
		panel.custom_minimum_size.x = 448
		var minimum := panel.get_combined_minimum_size()
		var width := 640.0
		var origin := Vector2(root.size.x-width,-96)
		var image_scale := width/1200.0
		var head_height := minimum.y+208
		terminal.position = origin
		terminal.scale = Vector2.ONE*image_scale
		terminal.size = Vector2(1200,head_height/image_scale)
		var content_position := origin+Vector2(92,156)
		center.offset_left = 2*content_position.x+minimum.x-root.size.x
		center.offset_top = 2*content_position.y+minimum.y-root.size.y
	else:
		title_style_active = false
		panel.custom_minimum_size.x = 640
		var current := panel.get_theme_stylebox("panel")
		if current is StyleBoxFlat: submenu_padding = current.get_content_margin(SIDE_LEFT)
		for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: submenu_empty.set_content_margin(side,submenu_padding)
		if current != submenu_empty: panel.add_theme_stylebox_override("panel",submenu_empty)
		center.offset_left = 0
		center.offset_top = 0
		var rect := panel.get_global_rect()
		var content_size := panel.get_combined_minimum_size()-Vector2.ONE*submenu_padding*2
		var image_scale := minf(0.32,maxf(0.08,(root.size.x-8-content_size.x)/276.0))
		var border := Vector2(138,105)*image_scale
		submenu_terminal.position = rect.position+Vector2.ONE*submenu_padding-border
		submenu_terminal.scale = Vector2.ONE*image_scale
		submenu_terminal.size = (content_size+Vector2(276,220)*image_scale)/image_scale
	layout_busy = false

func _load_name() -> void:
	if game.enter_named_session(name_input.text):
		profile_notice.hide()
	else:
		get_node("/root/UIAudio").reject()
		profile_notice.text = "请输入名字" if name_input.text.strip_edges().is_empty() else "存档无法读取，原有进度未更改"
		profile_notice.show()

func show_bosses(value: bool) -> void:
	controls.hide()
	settings_view.hide()
	level_select.hide()
	build_view.hide()
	menu.visible = not value
	boss_select.visible = value
	developer_button.get_parent().visible = not value
	_position_menu()
	if value: (boss_select.get_child(1) as Button).grab_focus()
	else: boss_test_button.grab_focus()
