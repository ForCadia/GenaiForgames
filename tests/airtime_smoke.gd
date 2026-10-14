extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func measure(game: Node, gravity: float, step: float) -> Dictionary:
	game._reset_player()
	game.lab_panel.values.gravity = gravity
	Input.action_press("jump")
	game._update_player(step)
	Input.action_release("jump")
	var elapsed := step
	var height: float = GameData.GROUND_Y - game.player.y
	while not game._grounded() and elapsed < 3.0:
		game._update_player(step)
		elapsed += step
		height = maxf(height, GameData.GROUND_Y - game.player.y)
	assert(game._grounded())
	return {"airtime_seconds": elapsed, "height_px": height}

func _run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_game("checkpoint", 0)
	await process_frame
	assert(GameData.PLAYER.jump_speed == 720.0)
	assert(is_equal_approx(GameData.PLAYER.gravity, 1250.0 / 1.1))
	var results := []
	for step in [1.0 / 60.0, 1.0 / 120.0]:
		var before := measure(game, 1250.0, step)
		var after := measure(game, GameData.PLAYER.gravity, step)
		var ratio: float = after.airtime_seconds / before.airtime_seconds
		print("step=", step, " before=", before, " after=", after, " ratio=", ratio)
		assert(absf(ratio - 1.1) < 0.015)
		results.append({"step_seconds": step, "historical_gravity": 1250.0,
			"new_gravity": GameData.PLAYER.gravity, "before": before,
			"after": after, "airtime_ratio": ratio})
	game.lab_panel.apply_preset(0, false)
	assert(is_equal_approx(game.lab_panel.values.gravity, GameData.PLAYER.gravity))
	assert(absf(game.lab_panel.controls.gravity.value - GameData.PLAYER.gravity) <= 0.01)
	for preset in range(3):
		assert(is_equal_approx(game.lab_panel.preset_values(preset).gravity, GameData.PLAYER.gravity))
	DirAccess.make_dir_recursive_absolute("res://tmp")
	var file := FileAccess.open("res://tmp/airtime-measurement.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"type": "engineering_simulation", "results": results}, "\t"))
	print("AIRTIME ACTUAL PLAYER INTEGRATION / PANEL DEFAULTS / ALL MODES: PASS")
	print(JSON.stringify(results))
	quit()
