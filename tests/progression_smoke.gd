extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.progression.owned.clear()
	game.progression.coins = 2000
	assert(not game.progression.buy("auto_guard"))
	game.start_level(0)
	assert(game.guard_regen() == 12.5)
	game._award_enemy_kill("heavy", game.player)
	assert(game.run_total_kills == 1 and game.coin_drops.size() == 1)
	game._update_coins(0)
	assert(game.run_coins == 7 and game.progression.coins == 2007)
	game._fire()
	assert(game.run_total_shots == 1)
	game._settle_run(true)
	var wallet: int = game.progression.coins
	game._settle_run(true)
	assert(game.progression.coins == wallet)
	for id in preload("res://build_data.gd").NODES:
		assert(game.progression.buy(id))
	assert(not game.progression.buy("cell"))
	assert(game.guard_regen() == 50 and game.guard_capacity() == 150)
	game._spawn_enemy("heavy", 0, false)
	var turret = game.turrets.back()
	turret.position.x = 600
	game.aim = turret.body_rect().get_center()
	game._auto_select_weapon()
	assert(game.weapon_index == 1)
	turret.state = TurretBase.TurretState.EXPOSED
	game._auto_select_weapon()
	assert(game.weapon_index == 0)
	assert(turret.laser_length == 1400)
	game.guard_energy = 100
	game._receive(false, "AUTO GUARD")
	assert(game.state == "playing" and game.guarding and game.guard_energy == 93)
	Input.action_press("guard")
	game._update_player(0.01)
	assert(game.guarding and game.auto_guard_left == 0)
	Input.action_release("guard")
	game.guarding = false
	game.guard_energy = 0
	game._receive(false, "NO ENERGY")
	assert(game.state == "dead")
	game.return_to_start()
	game.start_screen.show_build(true)
	assert(game.start_screen.build_view.visible)
	game.start_game("checkpoint",0,true)
	assert(game.guard_regen() == 50 and game.guard_capacity() == 100)
	assert(not game._upgrade("auto_guard"))
	game.return_to_start()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("PROGRESSION SMOKE PASS")
	quit()
