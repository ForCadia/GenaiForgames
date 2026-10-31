extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.state == "start" and paused and game.menu_demo.active)
	assert(game.music.playing and game.music.stream == game.music.normal_music)
	var demo = game.menu_demo.session
	assert(demo.scene_file_path == "res://main.tscn" and demo.attract_mode)
	assert(demo.menu_demo == null and not demo.lab.enabled)
	assert(not demo.progression.persistence and demo.progression.preview_only)
	assert(demo.settings == game.settings and not demo.music.playing)
	assert(demo.get_viewport().world_2d != game.get_viewport().world_2d)
	Input.action_press("use_grenade")
	assert(not demo._control_held("use_grenade"))
	Input.action_release("use_grenade")
	var wallet: int = game.progression.coins
	var events: int = game.lab.events.size()
	for frame in range(1200): await process_frame
	assert(demo.run_elapsed > 10 and demo.distance > 1000 and demo.run_total_shots > 0)
	assert(game.state == "start" and paused and game.progression.coins == wallet and game.lab.events.size() == events)
	assert(game.turrets.is_empty() and game.shots.is_empty() and game.threats.is_empty())
	game.start_level(0)
	assert(not game.menu_demo.active and not game.menu_demo.visible and game.menu_demo.session == null)
	game.progression.owned["auto_guard"] = true
	game.guard_energy = 100
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = game.player
	game._update_world(0)
	assert(game.state == "playing" and game.guarding and game.guard_energy == 82)
	assert(game.ground_spikes.is_empty())
	game._reset_player()
	game.guard_energy = 0
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = game.player
	game._update_world(0)
	assert(game.state == "dead")
	game.return_to_start()
	assert(game.menu_demo.active and is_instance_valid(game.menu_demo.session) and game.music.playing)
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("REAL MAIN SCENE / BOT INPUT / SEPARATE WORLD / NO PERSISTENCE / SPIKE GUARD: PASS")
	quit()
