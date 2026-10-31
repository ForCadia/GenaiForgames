extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.state == "start" and paused and game.menu_demo.active)
	assert(game.music.playing and game.music.stream == game.music.normal_music)
	game.menu_demo.set_process(false)
	var wallet: int = game.progression.coins
	var events: int = game.lab.events.size()
	for frame in range(600): game.menu_demo._process(1.0/60.0)
	assert(game.menu_demo.scroll_distance > 1000)
	assert(game.state == "start" and game.progression.coins == wallet and game.lab.events.size() == events)
	assert(game.turrets.is_empty() and game.shots.is_empty() and game.threats.is_empty())
	game.start_level(0)
	assert(not game.menu_demo.active and not game.menu_demo.visible and game.menu_demo.enemies.is_empty())
	game.progression.owned["auto_guard"] = true
	game.guard_energy = 100
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = game.player
	game._update_world(0)
	assert(game.state == "playing" and game.guarding and game.guard_energy == 93)
	assert(game.ground_spikes.is_empty())
	game._reset_player()
	game.guard_energy = 0
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = game.player
	game._update_world(0)
	assert(game.state == "dead")
	game.return_to_start()
	assert(game.menu_demo.active and game.menu_demo.visible and game.music.playing)
	game.start_level(0)
	game.progression.owned.clear()
	game.guarding = true
	game.guard_energy = 100
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = game.player
	game._update_world(0)
	assert(game.state == "playing" and game.ground_spikes.is_empty() and game.guard_energy == 93)
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("MENU DEMO ISOLATION / BGM / SPIKES AUTO AND MANUAL GUARD / NO ENERGY: PASS")
	quit()
