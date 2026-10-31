extends CanvasLayer

const F := preload("res://ui/ui_factory.gd")
const S := preload("res://ui/ui_strings.gd")
var game: Node
var root: Control
var panel: PanelContainer
var content: BoxContainer
var shown := ""
var controls_open := false
var settings_open := false
var fade: Tween
var best_score := 0
var rank_animation: Tween

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = F.root(self)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.78)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(_background_input)
	var center := CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = 520
	center.add_child(panel)
	panel.gui_input.connect(_background_input)
	var config := ConfigFile.new()
	if config.load("user://ui_record.cfg") == OK: best_score = int(config.get_value("record", "best_score", 0))
	hide()

func _process(_delta: float) -> void:
	var requested: String = "pause" if game.ui_paused else game.state
	if requested == "dead" and not game.death_ui_ready: requested = ""
	if requested not in ["pause", "dead", "victory"]: requested = ""
	if requested == shown: return
	shown = requested
	controls_open = false
	settings_open = false
	visible = shown != ""
	if visible: rebuild()

func rebuild() -> void:
	if is_instance_valid(content):
		panel.remove_child(content)
		content.queue_free()
	content = F.box(panel)
	content.add_theme_constant_override("separation", 16)
	if settings_open:
		var page := preload("res://ui/settings_page.gd").new()
		page.game = game
		page.back = func(): settings_open = false; rebuild()
		content.add_child(page)
		page.back_button.grab_focus()
	elif controls_open:
		preload("res://ui/menu.gd").build_controls(content, func(): controls_open = false; rebuild())
	elif shown == "pause":
		F.label(content, "// SYSTEM STANDBY", "AmberLabel")
		F.label(content, S.PAUSED, "TitleLabel")
		F.button(content, S.RESUME, func(): game.set_ui_paused(false)).grab_focus()
		F.button(content, S.SETTINGS, func(): settings_open = true; rebuild())
		F.button(content, S.CONTROLS, func(): controls_open = true; rebuild())
		F.button(content, S.RETURN_TITLE, func(): game.return_to_start(), true)
	elif shown == "dead":
		var text_panel := PanelContainer.new()
		content.add_child(text_panel)
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color(0.025, 0.04, 0.065, 0.88)
		frame.border_color = UIPalette.PANEL_EDGE_HI
		frame.set_border_width_all(1)
		frame.border_width_top = 3
		frame.shadow_color = Color(0, 0, 0, 0.5)
		frame.shadow_size = 6
		for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: frame.set_content_margin(side, 18)
		text_panel.add_theme_stylebox_override("panel", frame)
		text_panel.gui_input.connect(_background_input)
		var text := F.box(text_panel)
		text.add_theme_constant_override("separation", 12)
		F.label(text, "// SIGNAL LOST", "AmberLabel")
		F.label(text, S.DEATH, "TitleLabel").modulate = UIPalette.RED
		F.label(text, S.death_cause(game.banner), "LargeLabel")
		var destination := "WAVE 01 / NEW ENDLESS RUN" if game.endless_mode else ("BOSS ENCOUNTER" if game.boss_mode and game.restart_mode == "checkpoint" else ("CHECKPOINT %02d / %s" % [game.segment + 1, game.current_stage_name()] if game.restart_mode == "checkpoint" else "CAMPAIGN ENTRY"))
		F.label(text, "RESTART FROM " + destination, "MutedLabel")
		add_stats(text)
		if game.endless_mode:
			F.label(text, "WAVE REACHED  %02d" % game.endless_wave, "AmberLabel")
			var result := record_result()
			F.label(text, "ENDLESS BEST  %06d" % result.best, "MutedLabel")
		F.label(text, "R / SPACE / FIRE TO RETRY", "MutedLabel")
		F.button(content, "RESTART ENDLESS [R]" if game.endless_mode else S.RETRY, func(): game._request_retry("ui_button"))
		F.button(content, S.RETURN_TITLE, func(): game.return_to_start(), true)
	else:
		F.label(content, "// SECTOR SECURED", "AmberLabel")
		F.label(content, S.VICTORY, "LargeLabel")
		F.label(content, game.mode_caption() + " // COMPLETE", "AmberLabel")
		var ranked: bool = not game.developer_mode and not game.boss_test_mode
		var rank := preload("res://ui/rank_calculator.gd").calculate(game.run_deaths)
		var rank_label := F.label(content, "RANK " + rank if ranked else S.TEST_RUN, "TitleLabel" if ranked else "AmberLabel")
		if ranked:
			rank_label.modulate = UIPalette.AMBER
			rank_label.scale = Vector2(1.6, 1.6)
			if rank_animation: rank_animation.kill()
			rank_animation = create_tween()
			rank_animation.tween_property(rank_label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		add_stats()
		if not game.boss_test_mode:
			F.label(content, "LIGHT TURRETS ........ %02d" % game.stats.unarmored, "MutedLabel")
			F.label(content, "HEAVY TURRETS ........ %02d" % game.stats.heavy, "MutedLabel")
		F.label(content, "BOSS DEFEATED ........ YES", "EnergyLabel")
		if ranked:
			var result := record_result()
			F.label(content, ("NEW RECORD!  " if result.new_record else "PERSONAL BEST  ") + "%06d" % result.best, "AmberLabel")
			if game.selected_level < 2:
				F.button(content, "NEXT MISSION", func(): game.next_level())
		F.button(content, S.REDEPLOY, func(): game._new_run(); game._gate_gameplay_input()).grab_focus()
		F.button(content, S.RETURN_TITLE, func(): game.return_to_start(), true)
	if fade: fade.kill()
	panel.modulate.a = 0
	fade = create_tween()
	fade.tween_property(panel, "modulate:a", 1.0, 0.2)

func add_stats(parent: Node = null) -> void:
	var target: Node = parent if parent != null else content
	F.label(target, "KILLS  %d    SHOTS  %d" % [game.run_total_kills, game.run_total_shots], "MutedLabel")
	if game._meta_enabled():
		var bonus := int(game.settlement.get("bonus", 0))
		F.label(target, "COINS  %d PICKED + %d BONUS" % [game.run_coins, bonus], "AmberLabel")
		F.label(target, "WALLET  %d G" % game.progression.coins, "MutedLabel")
	F.label(target, "SCORE  %06d" % game.score, "LargeLabel")
	F.label(target, "TIME  %02d:%02d    DEATHS  %02d" % [int(game.run_elapsed) / 60, int(game.run_elapsed) % 60, game.run_deaths], "MutedLabel")

func record_result() -> Dictionary:
	if not game.run_record.is_empty(): return game.run_record
	var config := ConfigFile.new()
	config.load("user://ui_record.cfg")
	var key: String = game.record_key()
	var previous := int(config.get_value("record", key, 0))
	var best: int = maxi(previous, game.score)
	if not game.ui_preview and not "--lab-test" in OS.get_cmdline_user_args():
		config.set_value("record", key, best)
		if game.endless_mode:
			config.set_value("record", "endless_best_wave", maxi(int(config.get_value("record", "endless_best_wave", 0)), game.endless_wave))
		config.save("user://ui_record.cfg")
	game.run_record = {"best": best, "new_record": game.score > previous}
	return game.run_record

func _background_input(event: InputEvent) -> void:
	if shown == "dead" and event.is_action_pressed("fire"):
		game._request_retry("fire")

func _unhandled_input(event: InputEvent) -> void:
	if visible and shown == "pause" and event.is_action_pressed("ui_cancel"):
		if settings_open:
			settings_open = false
			rebuild()
		elif controls_open:
			controls_open = false
			rebuild()
		else: game.set_ui_paused(false)
		get_viewport().set_input_as_handled()
