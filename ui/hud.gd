extends CanvasLayer

const F := preload("res://ui/ui_factory.gd")
const P := preload("res://ui/ui_palette.gd")
const S := preload("res://ui/ui_strings.gd")
var game: Node
var root: Control
var score_label: Label
var kills_label: Label
var mode_label: Label
var stage_label: BoxContainer
var stage_styles: Array[StyleBoxFlat] = []
var shield: ProgressBar
var shield_label: Label
var grenade_label: Label
var weapon_label: Label
var ammo_label: Label
var penetration_label: Label
var ammo_bar: ProgressBar
var reload_label: Label
var slots: Array[PanelContainer] = []
var boss_hud: VBoxContainer
var banner_label: Label
var banner_panel: PanelContainer
var tutorial_label: Label
var toast_label: Label
var seen_stages: Array[int] = []
var tutorial_left := 0.0
var score_tween: Tween
var shown_score := 0.0
var target_score := -1
var last_banner := ""
var banner_tween: Tween
var tutorial_panel: PanelContainer
var tutorial_keys: BoxContainer
var intro_panel: PanelContainer
var hints_layer: CanvasLayer
var selected_slot_style := StyleBoxFlat.new()
var inactive_slot_style := StyleBoxEmpty.new()
var ammo_target := 100.0
var displayed_reloading := false
var reload_phase := 0.0

func _ready() -> void:
	layer = P.HUD_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	game = get_parent()
	root = F.root(self)
	selected_slot_style.bg_color = Color(1, 0.65, 0.12, 0.16)
	selected_slot_style.border_width_bottom = 3
	selected_slot_style.border_color = P.AMBER
	var margin := MarginContainer.new()
	root.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := F.box(margin)
	var top := F.box(layout, true)
	var left_panel := PanelContainer.new()
	var compact_panel := root.theme.get_stylebox("panel", "PanelContainer").duplicate()
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: compact_panel.set_content_margin(side, 8)
	left_panel.add_theme_stylebox_override("panel", compact_panel)
	top.add_child(left_panel)
	var left := F.box(left_panel)
	left.add_theme_constant_override("separation", 3)
	left.custom_minimum_size.x = P.SHIELD_WIDTH
	score_label = F.label(left, "000000", "LargeLabel")
	kills_label = F.label(left, "KILLS 00", "AmberLabel")
	mode_label = F.label(left, "LEVEL 01", "MutedLabel")
	stage_label = F.box(left, true)
	stage_label.add_theme_constant_override("separation", 6)
	for index in range(5):
		var block := Panel.new()
		block.custom_minimum_size = Vector2(12, 12)
		var style := StyleBoxFlat.new()
		style.set_border_width_all(1)
		block.add_theme_stylebox_override("panel", style)
		stage_label.add_child(block)
		stage_styles.append(style)
	F.spacer(top)
	boss_hud = preload("res://ui/boss_hud.gd").new()
	top.add_child(boss_hud)
	F.spacer(top)
	var right_panel := PanelContainer.new()
	right_panel.add_theme_stylebox_override("panel", compact_panel)
	top.add_child(right_panel)
	var right := F.box(right_panel)
	var shield_row := F.box(right, true)
	F.icon(shield_row, "shield")
	shield = F.bar(shield_row, 112)
	shield.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	shield_label = F.label(right, "GUARD LOCK", "AmberLabel")
	shield_label.hide()
	grenade_label = F.label(right, "[F] GRENADE ×1", "AmberLabel")
	var messages := F.box(layout)
	var banner_center := CenterContainer.new()
	messages.add_child(banner_center)
	banner_panel = PanelContainer.new()
	banner_panel.custom_minimum_size = Vector2(520, 44)
	banner_center.add_child(banner_panel)
	banner_label = F.label(banner_panel, "", "LargeLabel")
	banner_label.modulate = P.AMBER
	hints_layer = CanvasLayer.new()
	hints_layer.layer = 90
	hints_layer.hide()
	add_child(hints_layer)
	var hints_root := F.root(hints_layer)
	var hints_center := CenterContainer.new()
	hints_root.add_child(hints_center)
	hints_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hints_center.anchor_top = 0.9
	hints_center.anchor_bottom = 1.0
	hints_center.offset_bottom = -6
	var hints := VBoxContainer.new()
	hints_center.add_child(hints)
	hints.custom_minimum_size.x = 560
	hints.add_theme_constant_override("separation", 4)
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.02, 0.035, 0.05, 0.78)
	hint_style.shadow_color = Color(0, 0, 0, 0.55)
	hint_style.shadow_size = 4
	for side in [SIDE_LEFT, SIDE_RIGHT]: hint_style.set_content_margin(side, 8)
	for side in [SIDE_TOP, SIDE_BOTTOM]: hint_style.set_content_margin(side, 3)
	var tutorial_center := CenterContainer.new()
	hints.add_child(tutorial_center)
	tutorial_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutorial_panel = PanelContainer.new()
	tutorial_panel.add_theme_stylebox_override("panel", hint_style)
	tutorial_center.add_child(tutorial_panel)
	var tutorial_row := F.box(tutorial_panel, true)
	tutorial_keys = F.box(tutorial_row, true)
	tutorial_label = F.label(tutorial_row, "", "AmberLabel")
	tutorial_label.add_theme_font_size_override("font_size", 18)
	var intro_center := CenterContainer.new()
	hints.add_child(intro_center)
	intro_panel = PanelContainer.new()
	intro_panel.add_theme_stylebox_override("panel", hint_style)
	intro_center.add_child(intro_panel)
	var intro := F.box(intro_panel, true)
	for key in ["A/D", "SPACE", "LMB", "RMB"]:
		var cap := preload("res://ui/key_cap.tscn").instantiate()
		cap.key_text = key
		cap.font_size = 16
		intro.add_child(cap)
	F.label(intro, "MOVE / JUMP / FIRE / GUARD", "MutedLabel").add_theme_font_size_override("font_size", 16)
	toast_label = F.label(messages, "", "SmallLabel")
	for label in [banner_label, tutorial_label, toast_label]: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	F.spacer(layout)
	var bottom := F.box(layout, true)
	F.spacer(bottom)
	var panel := PanelContainer.new()
	panel.name = "WeaponHUD"
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	bottom.add_child(panel)
	var weapon_layout := F.box(panel, true)
	weapon_layout.add_theme_constant_override("separation", 10)
	var row := F.box(weapon_layout, true)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 3)
	for i in range(3):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(64, 32)
		slot.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(slot)
		var contents := F.box(slot, true)
		contents.add_theme_constant_override("separation", 3)
		F.label(contents, str(i + 1), "MutedLabel")
		var icon := F.icon(contents, ["rifle", "piercer", "grenade"][i])
		icon.custom_minimum_size = Vector2(44, 20) if i < 2 else Vector2(24, 24)
		if i < 2: icon.stretch_mode = TextureRect.STRETCH_SCALE
		slots.append(slot)
	var weapons := F.box(weapon_layout)
	weapons.add_theme_constant_override("separation", 2)
	weapon_label = F.label(weapons, "ASSAULT RIFLE", "AmberLabel")
	var details := F.box(weapons, true)
	ammo_label = F.label(details, "24 / 24", "Label")
	F.spacer(details)
	penetration_label = F.label(details, "PEN ◆", "MutedLabel")
	ammo_bar = F.bar(weapons, 164, "ReloadBar")
	ammo_bar.custom_minimum_size.y = 6
	reload_label = F.label(weapons, "MAGAZINE", "MutedLabel")
	reload_label.hide()
	_ignore_mouse(root)
	_ignore_mouse(hints_root)

func _ignore_mouse(node: Node) -> void:
	if node is Control: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): _ignore_mouse(child)

func reset_run() -> void:
	seen_stages.clear()
	last_banner = ""
	tutorial_left = 0

func _process(delta: float) -> void:
	if not is_instance_valid(game) or not "state" in game: return
	sync()
	if game.state != "playing" or game.ui_paused or game.lab_panel.blocked: return
	if displayed_reloading:
		ammo_bar.value = lerpf(ammo_bar.value, ammo_target, 1.0 - exp(-delta * 14.0))
		reload_phase += delta * TAU / 1.2
		ammo_bar.modulate.a = 0.55 + 0.45 * (0.5 + 0.5 * cos(reload_phase))
	tutorial_left = maxf(0, tutorial_left - delta)
	if game.segment not in seen_stages and not game.boss_mode:
		seen_stages.append(game.segment)
		tutorial_left = P.TUTORIAL_TIME
		for child in tutorial_keys.get_children():
			tutorial_keys.remove_child(child)
			child.queue_free()
		for key in game.current_segment().get("keys", S.TUTORIAL_KEYS[game.segment]):
			var cap := preload("res://ui/key_cap.tscn").instantiate()
			cap.key_text = key
			cap.font_size = 16
			tutorial_keys.add_child(cap)
		tutorial_label.text = str(game.current_segment().hint) if game.endless_mode or game.selected_level > 0 else S.TUTORIALS[game.segment]
	tutorial_panel.visible = tutorial_left > 0 and not game.boss_mode
	tutorial_panel.modulate.a = clampf(tutorial_left * 2, 0, 1)

func sync() -> void:
	if not is_instance_valid(score_label): return
	visible = game.state != "start"
	hints_layer.visible = game.state == "playing" and not game.ui_paused and not game.boss_mode and bool(game.settings.options.tutorials)
	root.modulate.a = 0.35 if game.state in ["dead", "victory"] or game.ui_paused else 1.0
	if target_score != game.score:
		target_score = game.score
		if score_tween: score_tween.kill()
		score_tween = create_tween()
		score_tween.tween_property(self, "shown_score", float(target_score), 0.3)
		score_tween.parallel().tween_property(score_label, "scale", Vector2(1.15, 1.15), 0.1)
		score_tween.tween_property(score_label, "scale", Vector2.ONE, 0.12)
	score_label.text = "%06d" % roundi(shown_score)
	kills_label.text = "KILLS %02d   G %d" % [game.run_total_kills, game.progression.coins] if game._meta_enabled() else "KILLS %02d" % game.run_total_kills
	mode_label.text = game.mode_caption()
	var reached: int = 4 if game.boss_mode or game.state == "victory" else game.segment
	for index in range(5):
		var color := P.RED if index == 4 else P.CYAN
		stage_styles[index].border_color = color if index <= reached or index == 4 else P.TEXT_DIM
		stage_styles[index].bg_color = color if index <= reached else Color(0, 0, 0, 0)
	shield.max_value = game.guard_capacity()
	shield.value = game.guard_energy
	shield.modulate = P.RED if game.guard_lock > 0 else (P.AMBER if game.guard_energy < 25 else Color.WHITE)
	shield_label.visible = game.guard_lock > 0
	grenade_label.visible = game.has_grenade
	grenade_label.text = "[F] GRENADE ×%d" % game.grenade_count
	boss_hud.visible = game.boss_mode
	if game.boss_mode and not game.boss.is_empty(): boss_hud.apply_state(game.boss.hp, game.GD.BOSS.health, game.boss.armor, game.boss.phase)
	for i in range(3):
		slots[i].add_theme_stylebox_override("panel", selected_slot_style if game.selected_slot == i else inactive_slot_style)
		slots[i].modulate = P.AMBER if game.selected_slot == i else P.TEXT_DIM
		slots[i].modulate.a = 0.35 if i == 2 and not game.has_grenade else 1.0
	if game.selected_slot == 2:
		weapon_label.text = S.WEAPONS[2]
		ammo_label.text = "× %02d" % game.grenade_count
		penetration_label.text = "BLAST"
		ammo_bar.value = 100 if game.has_grenade else 0
	if game.banner != last_banner and game.banner_time > 0 and game.state == "playing":
		last_banner = game.banner
		banner_label.text = game.banner
		if banner_tween: banner_tween.kill()
		banner_panel.modulate.a = 0
		banner_tween = create_tween()
		banner_tween.tween_property(banner_panel, "modulate:a", 1.0, 0.35)
		banner_tween.tween_interval(1.8)
		banner_tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4)
	banner_panel.visible = game.state == "playing" and game.banner_time > 0
	toast_label.visible = game.state in ["playing", "intermission"] and game.notice_time > 0
	toast_label.text = game.notice
	tutorial_label.visible = game.state == "playing"
	if game.state != "playing": tutorial_panel.hide()
	intro_panel.visible = game.state == "playing" and not game.boss_mode and game.run_elapsed < 6
	intro_panel.modulate.a = clampf(6 - game.run_elapsed, 0, 1)

func refresh(_health: int, _max_health: int, _weapon_name: String, penetration: int,
		current_ammo: int, capacity: int, reload_remaining: float, reload_duration: float) -> void:
	if not is_instance_valid(ammo_label): return
	weapon_label.text = S.WEAPONS[game.weapon_index]
	if reload_remaining > 0: weapon_label.text = S.RELOADING
	ammo_label.text = "%02d / %02d" % [current_ammo, capacity]
	ammo_label.modulate = P.RED if current_ammo <= 0 else (P.AMBER if current_ammo <= capacity * 0.25 else P.TEXT)
	penetration_label.text = "PEN " + "◆".repeat(penetration)
	var reloading := reload_remaining > 0
	ammo_target = (1.0 - reload_remaining / maxf(reload_duration, 0.001)) * 100 if reloading else float(current_ammo) / maxi(capacity, 1) * 100
	if reloading and not displayed_reloading:
		ammo_bar.value = 0
		reload_phase = 0
	if not reloading:
		ammo_bar.value = ammo_target
		ammo_bar.modulate.a = 1.0
	displayed_reloading = reloading
	reload_label.text = "RELOADING" if reload_remaining > 0 else "MAGAZINE"

func follow_hitbox(_hitbox: Rect2) -> void:
	pass
