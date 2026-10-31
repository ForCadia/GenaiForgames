extends CanvasLayer
const F := preload("res://ui/ui_factory.gd")
const S := preload("res://ui/ui_strings.gd")
const STYLE := preload("res://ui/menu_style.gd")
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
	root.theme = STYLE.theme()
	var shade := ColorRect.new()
	shade.color = Color(0.02,0.03,0.05,0.72)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(_background_input)
	var center := CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	center.add_child(panel)
	panel.gui_input.connect(_background_input)
	hide()

func _process(_delta: float) -> void:
	var requested: String = "pause" if game.ui_paused else game.state
	if requested == "dead" and not game.death_ui_ready: requested = ""
	if requested not in ["pause","dead","victory"]: requested = ""
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
	panel.custom_minimum_size.x = 640 if settings_open or controls_open or shown == "victory" else 520
	content = F.box(panel)
	content.add_theme_constant_override("separation",12)
	if settings_open:
		var page := preload("res://ui/settings_page.gd").new()
		page.game = game
		page.back = func(): settings_open = false; rebuild()
		content.add_child(page)
		page.back_button.grab_focus()
	elif controls_open:
		preload("res://ui/menu.gd").build_controls(content,func(): controls_open = false; rebuild())
	elif shown == "pause":
		F.label(content,"// SYSTEM STANDBY","AmberLabel")
		F.label(content,S.PAUSED,"TitleLabel")
		STYLE.primary(F.button(content,S.RESUME,func(): game.set_ui_paused(false))).grab_focus()
		F.button(content,S.SETTINGS,func(): settings_open = true; rebuild()).custom_minimum_size.y = 44
		F.button(content,S.CONTROLS,func(): controls_open = true; rebuild()).custom_minimum_size.y = 44
		F.button(content,S.RETURN_TITLE,func(): game.return_to_start(),true).theme_type_variation = "MenuDanger"
	elif shown == "dead": build_death()
	else: build_victory()
	if fade: fade.kill()
	panel.modulate.a = 0
	fade = create_tween()
	fade.tween_property(panel,"modulate:a",1.0,0.2)

func framed(parent: Node, danger := false) -> VBoxContainer:
	var card := PanelContainer.new()
	var style := STYLE.frame(Color("0b121c"),STYLE.EDGE,16)
	style.border_width_top = 3
	if danger: style.border_color = Color("7a2a34")
	card.add_theme_stylebox_override("panel",style)
	parent.add_child(card)
	card.gui_input.connect(_background_input)
	var box := F.box(card)
	box.add_theme_constant_override("separation",12)
	return box

func build_death() -> void:
	var text := framed(content,true)
	F.label(text,"// SIGNAL LOST","AmberLabel")
	F.label(text,S.DEATH,"TitleLabel").modulate = STYLE.RED
	F.label(text,S.death_cause(game.banner),"SmallLabel")
	var destination := "WAVE 01 / NEW ENDLESS RUN" if game.endless_mode else ("BOSS ENCOUNTER" if game.boss_mode and game.restart_mode == "checkpoint" else ("CHECKPOINT %02d / %s" % [game.segment+1,game.current_stage_name()] if game.restart_mode == "checkpoint" else "CAMPAIGN ENTRY"))
	var restart := F.label(text,"RESTART / " + destination,"EnergyLabel")
	restart.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if game.boss_mode: F.label(text,"SENTINEL / PHASE %d" % int(game.boss.get("phase",1)),"AmberLabel")
	text.add_child(HSeparator.new())
	var metrics := F.box(text,true)
	metrics.add_theme_constant_override("separation",16)
	metric(metrics,"SCORE","%06d" % game.score)
	metric(metrics,"KILLS / SHOTS","%d / %d" % [game.run_total_kills,game.run_total_shots])
	metric(metrics,"TIME / DEATHS","%02d:%02d / %d" % [int(game.run_elapsed)/60,int(game.run_elapsed)%60,game.run_deaths])
	if game._meta_enabled():
		text.add_child(HSeparator.new())
		var bonus := int(game.settlement.get("bonus",0))
		stat_row(text,"COINS THIS RUN","+%d G" % (game.run_coins+bonus),"AmberLabel")
		stat_row(text,"WALLET","%d G" % game.progression.coins,"AmberLabel")
	if game.endless_mode:
		stat_row(text,"WAVE REACHED / BEST SCORE","%02d / %06d" % [game.endless_wave,record_result().best])
	STYLE.primary(F.button(content,"RESTART ENDLESS [R]" if game.endless_mode else S.RETRY,func(): game._request_retry("ui_button"))).grab_focus()
	F.button(content,S.RETURN_TITLE,func(): game.return_to_start(),true)

func metric(parent: Node, label: String, value: String) -> void:
	var box := F.box(parent)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(box,label,"MutedLabel")
	F.label(box,value,"SmallLabel")

func build_victory() -> void:
	var text := framed(content)
	F.label(text,"// SECTOR SECURED","AmberLabel")
	var header := F.box(text,true)
	var title := F.box(header)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(title,S.VICTORY,"LargeLabel")
	F.label(title,game.mode_caption()+" // COMPLETE","AmberLabel")
	var ranked: bool = not game.developer_mode and not game.boss_test_mode
	if ranked:
		var badge := PanelContainer.new()
		badge.custom_minimum_size = Vector2(80,80)
		badge.add_theme_stylebox_override("panel",STYLE.frame(Color("332609"),STYLE.AMBER,8))
		header.add_child(badge)
		var rank_label := F.label(badge,preload("res://ui/rank_calculator.gd").calculate(game.run_deaths),"TitleLabel")
		rank_label.modulate = STYLE.AMBER
		rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else: F.label(header,S.TEST_RUN,"MutedLabel")
	text.add_child(HSeparator.new())
	var columns := F.box(text,true)
	columns.add_theme_constant_override("separation",24)
	var performance := F.box(columns)
	performance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	performance.add_theme_constant_override("separation",10)
	F.label(performance,"PERFORMANCE","AmberLabel")
	stat_row(performance,"SCORE","%06d" % game.score,"LargeLabel")
	stat_row(performance,"KILLS / SHOTS","%d / %d" % [game.run_total_kills,game.run_total_shots])
	stat_row(performance,"TIME / DEATHS","%02d:%02d / %d" % [int(game.run_elapsed)/60,int(game.run_elapsed)%60,game.run_deaths])
	if not game.boss_test_mode:
		stat_row(performance,"LIGHT TURRETS","%02d" % game.stats.unarmored)
		stat_row(performance,"HEAVY TURRETS","%02d" % game.stats.heavy)
	stat_row(performance,"BOSS","DEFEATED","EnergyLabel")
	if game._meta_enabled():
		var reward := F.box(columns)
		reward.custom_minimum_size.x = 192
		reward.add_theme_constant_override("separation",10)
		F.label(reward,"REWARD","AmberLabel")
		var bonus := int(game.settlement.get("bonus",0))
		stat_row(reward,"PICKED","%d G" % game.run_coins)
		stat_row(reward,"BONUS","%d G" % bonus)
		F.label(reward,"EARNED  +%d G" % (game.run_coins+bonus),"SmallLabel").modulate = STYLE.AMBER
		F.label(reward,"WALLET","MutedLabel")
		F.label(reward,"%d G" % game.progression.coins,"LargeLabel").modulate = STYLE.AMBER
	if ranked:
		var result := record_result()
		F.label(text,("NEW BEST  " if result.new_record else "PERSONAL BEST  ")+"%06d" % result.best,"AmberLabel")
	var primary: Button
	if ranked and game.selected_level < 2:
		primary = STYLE.primary(F.button(content,"NEXT MISSION",func(): game.next_level()))
	var actions := F.box(content,true)
	actions.add_theme_constant_override("separation",12)
	var redeploy := F.button(actions,S.REDEPLOY,func(): game._new_run(); game._gate_gameplay_input())
	redeploy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.button(actions,S.RETURN_TITLE,func(): game.return_to_start(),true).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_instance_valid(primary): primary.grab_focus()
	else: STYLE.primary(redeploy).grab_focus()

func stat_row(parent: Node, name: String, value: String, variant := "SmallLabel") -> void:
	var row := F.box(parent,true)
	row.add_theme_constant_override("separation",12)
	F.label(row,name,"MutedLabel")
	F.spacer(row)
	F.label(row,value,variant)

func record_result() -> Dictionary:
	if not game.run_record.is_empty(): return game.run_record
	var config := ConfigFile.new()
	if not game.attract_mode and game.play_profile == "development": config.load("user://ui_record.cfg")
	var key: String = game.record_key()
	var previous := int(game.progression.records.get(key,0)) if game.play_profile != "development" else int(config.get_value("record", key, 0))
	var best: int = maxi(previous, game.score)
	if game.play_profile != "development":
		game.progression.records[key] = best
		game.progression.save()
	if game.play_profile == "development" and not game.attract_mode and not game.ui_preview and not "--lab-test" in OS.get_cmdline_user_args():
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
