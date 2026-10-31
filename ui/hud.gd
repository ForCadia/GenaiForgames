extends CanvasLayer

const F := preload("res://ui/ui_factory.gd")
const P := preload("res://ui/ui_palette.gd")
const S := preload("res://ui/ui_strings.gd")
var game: Node
var root: Control
var score_label: Label
var kills_label: Label
var stage_label: Label
var shield: ProgressBar
var shield_label: Label
var grenade_label: Label
var sound_button: Button
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

func _ready() -> void:
	layer = P.HUD_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	game = get_parent()
	root = F.root(self)
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
	stage_label = F.label(left, "■ □ □ □", "MutedLabel")
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
	sound_button = F.button(shield_row, "", func(): AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0)), true)
	sound_button.custom_minimum_size = Vector2(24, 24)
	sound_button.icon = preload("res://ui/textures/speaker.png")
	sound_button.tooltip_text = "Mute / unmute [M]"
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := root.theme.get_stylebox(state, "Button").duplicate()
		for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(side, 2)
		sound_button.add_theme_stylebox_override(state, style)
	sound_button.focus_mode = Control.FOCUS_NONE
	sound_button.button_down.connect(func(): game._gate_gameplay_input())
	var messages := F.box(layout)
	var banner_center := CenterContainer.new()
	messages.add_child(banner_center)
	banner_panel = PanelContainer.new()
	banner_panel.custom_minimum_size = Vector2(520, 44)
	banner_center.add_child(banner_panel)
	banner_label = F.label(banner_panel, "", "LargeLabel")
	banner_label.modulate = P.AMBER
	var tutorial_center := CenterContainer.new()
	messages.add_child(tutorial_center)
	tutorial_panel = PanelContainer.new()
	tutorial_center.add_child(tutorial_panel)
	var tutorial_row := F.box(tutorial_panel, true)
	tutorial_keys = F.box(tutorial_row, true)
	tutorial_label = F.label(tutorial_row, "", "AmberLabel")
	var intro_center := CenterContainer.new()
	messages.add_child(intro_center)
	intro_panel = PanelContainer.new()
	intro_center.add_child(intro_panel)
	var intro := F.box(intro_panel, true)
	for key in ["A/D", "SPACE", "LMB", "RMB"]:
		var cap := preload("res://ui/key_cap.tscn").instantiate()
		cap.key_text = key
		intro.add_child(cap)
	F.label(intro, "MOVE / JUMP / FIRE / GUARD", "MutedLabel")
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
	weapon_layout.add_theme_constant_override("separation", 24)
	var row := F.box(weapon_layout, true)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in range(3):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(52, 24)
		slot.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(slot)
		var contents := F.box(slot, true)
		F.label(contents, str(i + 1), "MutedLabel")
		F.icon(contents, ["rifle", "piercer", "grenade"][i]).custom_minimum_size = Vector2(20, 20)
		slots.append(slot)
	var weapons := F.box(weapon_layout)
	weapons.add_theme_constant_override("separation", 2)
	weapon_label = F.label(weapons, "ASSAULT RIFLE", "AmberLabel")
	var details := F.box(weapons, true)
	ammo_label = F.label(details, "24 / 24", "Label")
	F.spacer(details)
	penetration_label = F.label(details, "PEN ◆", "MutedLabel")
	ammo_bar = F.bar(weapons, 252, "ReloadBar")
	ammo_bar.custom_minimum_size.y = 6
	reload_label = F.label(weapons, "MAGAZINE", "MutedLabel")
	reload_label.hide()
	_ignore_mouse(root)
	sound_button.mouse_filter = Control.MOUSE_FILTER_STOP

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
	tutorial_left = maxf(0, tutorial_left - delta)
	if game.segment not in seen_stages and not game.boss_mode:
		seen_stages.append(game.segment)
		tutorial_left = P.TUTORIAL_TIME
		for child in tutorial_keys.get_children():
			tutorial_keys.remove_child(child)
			child.queue_free()
		for key in S.TUTORIAL_KEYS[game.segment]:
			var cap := preload("res://ui/key_cap.tscn").instantiate()
			cap.key_text = key
			tutorial_keys.add_child(cap)
		tutorial_label.text = S.TUTORIALS[game.segment]
	tutorial_panel.visible = tutorial_left > 0 and not game.boss_mode
	tutorial_panel.modulate.a = clampf(tutorial_left * 2, 0, 1)

func sync() -> void:
	if not is_instance_valid(score_label): return
	visible = game.state != "start"
	root.modulate.a = 0.35 if game.state in ["dead", "victory"] or game.ui_paused else 1.0
	if target_score != game.score:
		target_score = game.score
		if score_tween: score_tween.kill()
		score_tween = create_tween()
		score_tween.tween_property(self, "shown_score", float(target_score), 0.3)
		score_tween.parallel().tween_property(score_label, "scale", Vector2(1.15, 1.15), 0.1)
		score_tween.tween_property(score_label, "scale", Vector2.ONE, 0.12)
	score_label.text = "%06d" % roundi(shown_score)
	kills_label.text = "KILLS %02d" % (game.stats.unarmored + game.stats.light + game.stats.heavy + game.stats.flyer)
	stage_label.text = "BOSS  " + "■".repeat(game.boss.get("phase", 1)) if game.boss_mode else " ".join(range(4).map(func(i): return "■" if i <= game.segment else "□"))
	stage_label.modulate = P.CYAN
	shield.value = game.guard_energy
	shield.modulate = P.RED if game.guard_lock > 0 else (P.AMBER if game.guard_energy < 25 else Color.WHITE)
	shield_label.visible = game.guard_lock > 0
	grenade_label.visible = game.has_grenade
	sound_button.icon = preload("res://ui/textures/muted.png") if AudioServer.is_bus_mute(0) else preload("res://ui/textures/speaker.png")
	boss_hud.visible = game.boss_mode
	if game.boss_mode and not game.boss.is_empty(): boss_hud.apply_state(game.boss.hp, game.GD.BOSS.health, game.boss.armor, game.boss.phase)
	for i in range(3):
		slots[i].modulate = P.AMBER if game.selected_slot == i else P.TEXT_DIM
		slots[i].modulate.a = 0.35 if i == 2 and not game.has_grenade else 1.0
	if game.selected_slot == 2:
		weapon_label.text = S.WEAPONS[2]
		ammo_label.text = "1 / 1" if game.has_grenade else "0 / 1"
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
	toast_label.visible = game.state == "playing" and game.notice_time > 0
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
	ammo_bar.value = (1.0 - reload_remaining / maxf(reload_duration, 0.001)) * 100 if reload_remaining > 0 else float(current_ammo) / maxi(capacity, 1) * 100
	reload_label.text = "RELOADING" if reload_remaining > 0 else "MAGAZINE"

func follow_hitbox(_hitbox: Rect2) -> void:
	pass
