extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args(), "Use -- --lab-test; never write test data into playtest logs")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game.set_process(false)
	var ui = game.lab_panel
	assert(ui.SPECS.size() == 13)
	assert(game.lab.run_number == 1 and game.lab.active)
	# Live controls change the exact values used by the simulation, restart
	# cleanly, and preserve the previous parameter snapshot.
	for key in ui.SPECS:
		var previous: float = float(ui.values[key])
		ui.controls[key].value = previous + float(ui.SPECS[key][4])
		assert(float(ui.values[key]) != previous)
		assert(game.lab.snapshot[key] == ui.values[key])
	assert(game.lab.events.filter(func(e): return e.event == "retry").is_empty())
	ui.reset_defaults()
	assert(is_equal_approx(game._scroll(), 220.0 * 1.5))
	ui.controls.scroll_multiplier.value = 2.0
	assert(is_equal_approx(game._scroll(), 440.0))
	ui.reset_defaults()
	Input.action_press("jump")
	ui.values.jump_speed = 800.0
	game._update_player(0.01)
	assert(is_equal_approx(game.velocity_y, -800.0))
	Input.action_release("jump")
	game._reset_player()
	Input.action_press("crouch")
	ui.values.slide_time = 1.0
	game._update_player(0.1)
	assert(is_equal_approx(game.slide_time_left, 0.9))
	Input.action_release("crouch")
	game._reset_player()
	game.guard_energy = 50.0
	game.guard_idle = 0.0
	ui.values.guard_delay = 0.2
	ui.values.guard_regen = 80.0
	game._update_player(0.1)
	assert(is_equal_approx(game.guard_energy, 50.0))
	game._update_player(0.1)
	assert(is_equal_approx(game.guard_energy, 58.0))
	game.guard_energy = 1.0
	ui.values.guard_lock = 1.2
	Input.action_press("guard")
	game._update_player(0.1)
	assert(is_equal_approx(game.guard_lock, 1.2))
	Input.action_release("guard")
	game._reset_player()
	game.weapon_index = 1
	ui.values.piercer_cadence = 0.7
	game._fire()
	assert(is_equal_approx(game.shot_left, 0.7))
	game._spawn_laser_gate()
	ui.values.laser_gate_speed = 400.0
	var gate = game.laser_gates.back()
	var original_x: float = gate.position.x
	game._update_world(0.1)
	assert(is_equal_approx(gate.position.x, original_x - 40.0))
	ui.reset_defaults()
	# Gravity and guard values change actual state immediately.
	game.player.y -= 100
	game.velocity_y = 0.0
	ui.values.gravity = 1800.0
	game._update_player(0.01)
	assert(is_equal_approx(game.velocity_y, 18.0))
	game._reset_player()
	Input.action_press("guard")
	ui.values.guard_drain = 100.0
	game._update_player(0.1)
	assert(is_equal_approx(game.guard_energy, 90.0))
	Input.action_release("guard")
	game.weapon_index = 0
	ui.values.rifle_cadence = 0.2
	game._fire()
	assert(is_equal_approx(game.shot_left, 0.2))
	ui.reset_defaults()
	game.particles.clear()
	ui.values.particles_enabled = false
	game._emit(Vector2.ZERO, Color.WHITE, 10, 100)
	assert(game.particles.is_empty())
	# Panel clicks/held fire cannot advance the loop, fire or cause a retry.
	ui.toggle_panel()
	var elapsed: float = game.lab.duration
	var runs: int = game.lab.run_number
	Input.action_press("fire")
	game._process(1.0)
	assert(game.lab.duration == elapsed and game.shots.is_empty())
	ui.toggle_panel()
	ui._process(0.01)
	assert(ui.blocked)
	Input.action_release("fire")
	ui._process(0.01)
	assert(not ui.blocked and not paused)
	assert(game.lab.run_number == runs)
	# Real death and one press within the animation lock: buffer the press,
	# then return to play without needing another press.
	game._die("SMOKE_FAILURE")
	assert(game.state == "dead")
	Input.action_press("restart")
	game._process(0.01)
	Input.action_release("restart")
	assert(game.retry_requested)
	game._process(0.36)
	assert(game.state == "playing" and not game.retry_requested)
	var retries: Array = game.lab.events.filter(func(e): return e.event == "retry")
	assert(retries.size() == 1 and retries[0].failure_to_restart_seconds < 2)
	var failed: Array = game.lab.events.filter(func(e): return e.event == "run_end" and e.failure)
	assert(failed.size() == 1 and failed[0].cause == "SMOKE_FAILURE")
	assert(failed[0].failure_position.x == GameData.PLAYER_X)
	var data: Dictionary = JSON.parse_string(JSON.stringify(game.lab.document()))
	for event in data.events:
		for field in ["event", "session_id", "run_id", "timestamp", "version", "variant", "parameters"]:
			assert(event.has(field))
		if event.event == "run_end":
			for field in ["duration", "score", "cause", "x", "y", "failure_position"]:
				assert(event.has(field))
	assert(game.lab.export_json())
	game.lab.storage = "res://tmp/telemetry-persistence-check"
	game.lab.persistence = true
	assert(game.lab.persist())
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(game.lab.storage.path_join(game.lab.session_id + ".json")))
	assert(saved.events.size() == game.lab.events.size())
	game.lab.persistence = false
	var old_session: String = game.lab.session_id
	ui.new_tester()
	assert(game.lab.session_id != old_session and game.lab.run_number == 0)
	assert(game.lab.events.filter(func(e): return e.event == "retry").is_empty())
	assert(game.lab.summary().contains("rate N/A"))
	DirAccess.make_dir_recursive_absolute("res://tmp")
	var file := FileAccess.open("res://tmp/automated-lab-b-validation.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	print("LAB B: 13 controls / live effects / panel isolation / buffered retry / JSON / session separation PASS")
	quit(0)
