extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL: " + message)

func release_gate(game: Node) -> void:
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)

func request_retry(game: Node) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_R
	event.keycode = KEY_R
	event.pressed = true
	game._unhandled_input(event)

func check_clean(game: Node) -> void:
	check(game.segment_time == 0 and game.next_event == 0, "timeline reset")
	check(game.enemies.is_empty() and game.turrets.is_empty() and game.laser_gates.is_empty() and game.ground_spikes.is_empty(), "enemies reset")
	check(game.shots.is_empty() and game.threats.is_empty() and game.boss_bombs.is_empty() and game.boss_particles.is_empty(), "projectiles reset")
	check(game.reload_left == 0 and game.shot_left == 0 and game.slide_time_left == 0 and game.guard_lock == 0, "player timers reset")
	check(game.guard_energy == GameData.GUARD.maximum and not game.has_grenade, "guard/grenade reset")

func _run() -> void:
	if not "--lab-test" in OS.get_cmdline_user_args(): quit(1); return
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var ui = game.lab_panel
	check(game.state == "start" and paused and not game.lab.active, "starts in paused menu")
	check(game.restart_mode == "checkpoint" and ui.parameter_mode == "原版", "default A + original")
	game._process(2.0)
	await create_timer(0.03).timeout
	check(game.lab.run_number == 0 and game.lab.duration == 0 and game.segment_time == 0, "menu creates no runs or simulation time")
	var expected := {"jump_speed": GameData.PLAYER.jump_speed, "gravity": GameData.PLAYER.gravity,
		"stomp_speed": GameData.PLAYER.stomp_speed, "slide_time": 0.7,
		"guard_drain": GameData.GUARD.drain_per_second, "guard_regen": GameData.GUARD.regen_per_second,
		"guard_delay": GameData.GUARD.regen_delay, "guard_lock": GameData.GUARD.break_lockout,
		"rifle_cadence": GameData.WEAPONS[0].cadence, "piercer_cadence": GameData.WEAPONS[1].cadence,
		"scroll_multiplier": GameData.SCROLL_MULTIPLIER, "laser_gate_speed": 315.0,
		"reload_multiplier": 1.0, "particles_enabled": true}
	check(ui.baseline == expected, "original matches pre-experiment defaults and game constants")
	for preset in [1, 2]:
		var changed: Array[String] = []
		var values: Dictionary = ui.preset_values(preset)
		for key in expected:
			if values[key] != expected[key]: changed.append(key)
		check(changed == (["scroll_multiplier"] if preset == 1 else ["reload_multiplier"]), "exactly one independent number differs")
	check(is_equal_approx(ui.preset_values(1).scroll_multiplier, 1.275), "slow -15%")
	check(is_equal_approx(ui.preset_values(2).reload_multiplier, 0.8), "reload -20%")
	for mode_index in range(2):
		for preset in range(3):
			game.start_screen.restart_selector.select(mode_index)
			game.start_screen.parameter_selector.select(preset)
			var starts_before: int = game.lab.run_number
			Input.action_press("fire")
			game.start_screen.start_button.pressed.emit()
			game._process(0.02)
			check(game.shots.is_empty() and game.ammo[0] == 24 and game.lab.duration == 0, "start click/held fire blocked")
			Input.action_release("fire")
			release_gate(game)
			check(game.lab.run_number == starts_before + 1, "one start for each of six combinations")
			check(game.lab.snapshot == ui.preset_values(preset), "full start snapshot")
			check(game.lab.restart_mode == ("checkpoint" if mode_index == 0 else "campaign"), "selected restart mode")
			check(game.lab.parameter_mode == ui.PRESET_NAMES[preset], "consistent mode name")
			check(game.score == 0 and game.segment == 0 and not game.boss_mode, "clean campaign start")
			check_clean(game)
			if preset == 2:
				for weapon in range(2):
					game.weapon_index = weapon
					game.ammo[weapon] = 0
					game.reload_left = 0
					game._reload()
					check(is_equal_approx(game.reload_left, GameData.WEAPONS[weapon].reload * 0.8), "reload multiplier affects actual weapons")
			game.return_to_start()
			check(paused and game.state == "start" and not game.lab.active, "return pauses run")
			check(game.start_screen.restart_selector.selected == mode_index and game.start_screen.parameter_selector.selected == preset, "return preserves choices")
	check(game.lab.variant_statistics().A.failures == 0 and game.lab.variant_statistics().B.retries == 0, "six administrative starts pollute no outcomes")
	game.start_game("checkpoint", 0)
	release_gate(game)
	# A restores the ordinary segment's entry state, not the death state.
	game.score = 400
	game.stats.unarmored = 4
	game.ammo = [17, 4]
	game.weapon_index = 1
	game.distance = 5000.0
	game._start_segment(2)
	game.score = 700
	game.ammo = [0, 0]
	game.weapon_index = 0
	game._spawn_laser_gate()
	game._die("CHECK_A_SEGMENT")
	request_retry(game)
	var pressed_at: int = game.lab.retry_pressed_at
	await create_timer(0.03).timeout
	game._process(0.36)
	check(game.state == "playing" and game.segment == 2 and not game.boss_mode, "A ordinary checkpoint")
	check(game.score == 400 and game.stats.unarmored == 4 and game.ammo == [17, 4] and game.weapon_index == 1 and game.distance == 5000.0, "A restores checkpoint score/ammo/weapon/distance")
	check_clean(game)
	var retry_events: Array = game.lab.events.filter(func(e): return e.event == "retry")
	check(retry_events.back().retry_input_monotonic_ms == pressed_at, "first keypress timestamp retained")
	check(retry_events.back().input_to_restart_seconds >= 0.02 and retry_events.back().failure_to_restart_seconds < 2.0, "animation wait separately measured; fast restart")
	# A restarts the entire boss fight, with full armor and health.
	game.score = 900
	game.ammo = [12, 3]
	game.distance = 9000.0
	game._start_boss()
	game.boss.hp = 1
	game.boss_actor.form = EyeballBoss.BossForm.WEAK_POINT
	game._on_boss_bomb_requested(440.0)
	game._die("CHECK_A_BOSS")
	request_retry(game)
	game._process(0.36)
	check(game.boss_mode and game.boss.hp == GameData.BOSS.health and game.boss.armor == GameData.BOSS.armor_per_cycle, "A complete boss reset")
	check(game.score == 900 and game.ammo == [12, 3], "A boss entry resources")
	check_clean(game)
	# B returns to the original campaign state for both types of death.
	game.set_restart_mode("campaign")
	release_gate(game)
	for is_boss in [false, true]:
		game.score = 600
		game.ammo = [2, 1]
		game.weapon_index = 1
		game._start_segment(3)
		if is_boss: game._start_boss()
		game._die("CHECK_B")
		request_retry(game)
		game._process(0.36)
		check(game.segment == 0 and not game.boss_mode and game.score == 0, "B campaign reset including boss death")
		check(game.ammo == [24, 5] and game.weapon_index == 0 and game.distance == 0, "B initial resources")
		check(game.restart_mode == "campaign" and ui.parameter_mode == "原版", "retry retains combination")
		check_clean(game)
	var counts: Dictionary = game.lab.variant_statistics()
	check(counts.A.failures == 2 and counts.A.retries == 2 and counts.B.failures == 2 and counts.B.retries == 2, "per-variant actual failure denominators")
	var before: int = game.lab.events.size()
	ui.apply_preset(1)
	var added: Array = game.lab.events.slice(before)
	check(added.filter(func(e): return e.event == "run_end" and e.cause == "administrative_parameter_change").size() == 1, "preset produces exactly one administrative end")
	check(added.filter(func(e): return e.event == "run_start").size() == 1, "preset produces exactly one start")
	check(game.restart_mode == "campaign", "parameter mode does not alter A/B")
	ui.controls.gravity.value += 25.0
	check(ui.parameter_mode == "自定义" and game.lab.parameter_mode == "自定义", "manual edit is custom")
	ui.apply_preset(0)
	check(ui.values == expected, "original restores all values from custom")
	release_gate(game)
	game._select_slot(1)
	check(game.weapon_index == 1, "weapon slot 2 remains")
	game._select_slot(0)
	game.has_grenade = true
	game._select_slot(2)
	check(game.selected_slot == 2, "weapon slot 3 remains")
	game._die("ABANDONED_FAILURE")
	var retries_before: int = game.lab.variant_statistics().B.retries
	game.set_restart_mode("checkpoint")
	check(game.lab.variant_statistics().B.retries == retries_before, "switch after death is not retry")
	check(game.lab.variant_statistics().B.failures == 3, "abandoned actual death remains denominator")
	var data: Dictionary = JSON.parse_string(JSON.stringify(game.lab.document()))
	for event in data.events:
		for field in ["variant", "restart_mode", "parameter_mode", "experiment_preset", "segment", "checkpoint", "parameters", "session_id", "run_id", "timestamp"]:
			check(event.has(field), "JSON required field: " + field)
		if event.event == "retry":
			check(event.has("failure_to_input_seconds") and event.has("failure_to_restart_seconds"), "JSON retry delays")
	check(game.lab.export_json(), "JSON export serializes")
	var session: String = game.lab.session_id
	ui.new_tester()
	check(game.state == "start" and game.lab.session_id != session and game.lab.run_number == 0, "new tester begins at menu in new session")
	check(game.lab.variant_statistics().A.retry_rate == null and game.lab.summary().contains("N/A"), "empty session rates are N/A")
	DirAccess.make_dir_recursive_absolute("res://tmp")
	var file := FileAccess.open("res://tmp/automated-start-modes.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	print("START / SIX COMBINATIONS / BASELINE / A-B RESETS / INPUT TIMING / ADMIN FILTER / JSON: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
