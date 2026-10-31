extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_level(0)
	game.ammo[0] = 0
	game._update_player(0)
	assert(game.reload_left == 0)
	game.progression.owned["auto_weapon"] = true
	game._update_player(0)
	assert(game.reload_left == game._reload_duration() and game.ammo[0] == 0)
	game._update_player(game.reload_left)
	assert(game.ammo[0] == game._weapon().magazine and game.reload_left == 0)
	game._select_slot(1)
	game.ammo[1] = 0
	game._update_player(0)
	assert(game.reload_left > 0)
	game._update_player(game.reload_left)
	assert(game.ammo[1] == game._weapon().magazine)
	game.grenade_count = 1
	game._select_slot(2)
	game.ammo[1] = 0
	game._update_player(0)
	assert(game.reload_left == 0 and game.selected_slot == 2)
	game.return_to_start()
	game.start_game("checkpoint",0,true)
	game.ammo[0] = 0
	game._update_player(0)
	assert(game.reload_left == 0)
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("SMART WEAPON AUTO RELOAD / BOTH GUNS / TIMING / GRENADE / LAB: PASS")
	quit()
