extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.progression.coins == 600)
	game.progression.owned.clear()
	game.progression.coins = 2000
	assert(not game.progression.buy("auto_guard"))
	game.start_level(0)
	assert(game.guard_regen() == 6.25)
	game._award_enemy_kill("heavy", game.player)
	assert(game.run_total_kills == 1 and game.coin_drops.size() == 5)
	var drop_value := 0
	for coin in game.coin_drops:
		drop_value += int(coin.value)
		assert(not coin.landed and coin.vy < 0)
	assert(drop_value == 7)
	for coin in game.coin_drops:
		coin.pos = game.player - Vector2(0,10)
		coin.landed = true
	game._update_coins(0)
	assert(game.run_coins == 7 and game.progression.coins == 2007)
	# Landed coins return even without upgrades, including from behind and
	# while the player is airborne. Airborne drops do not home early.
	game.player.y -= 150
	game.player_visual.position = game.player
	game.coin_drops.append({"pos":Vector2(50,GameData.GROUND_Y-10),"vx":0.0,"vy":0.0,"value":3,"landed":true,"bounced":true})
	game.coin_drops.append({"pos":Vector2(800,350),"vx":0.0,"vy":0.0,"value":1,"landed":false,"bounced":false})
	game._update_coins(0.05)
	assert(game.coin_drops[0].pos.x > 50 and game.coin_drops[0].pos.y < GameData.GROUND_Y-10)
	assert(game.coin_drops[1].pos.y > 350)
	game.coin_drops.remove_at(1)
	for frame in range(60): game._update_coins(1.0/60.0)
	assert(game.coin_drops.is_empty() and game.run_coins == 10)
	game.player.y = GameData.GROUND_Y
	game.player_visual.position = game.player
	game._fire()
	assert(game.run_total_shots == 1)
	game._settle_run(true)
	var wallet: int = game.progression.coins
	game._settle_run(true)
	assert(game.progression.coins == wallet)
	for id in preload("res://build_data.gd").NODES:
		assert(game.progression.buy(id))
	assert(not game.progression.buy("cell"))
	assert(game.guard_regen() == 25 and game.guard_capacity() == 150)
	game.guard_energy = 50
	game._register_kill("light",Vector2(800,500))
	assert(game.guard_energy == 55)
	game.guard_energy = 149
	game._register_kill("light",Vector2(800,500))
	assert(game.guard_energy == 150)
	game._spawn_enemy("heavy", 0, false)
	var turret = game.turrets.back()
	turret.position.x = 600
	game.aim = turret.body_rect().get_center()
	game._auto_select_weapon()
	assert(game.weapon_index == 1)
	turret.state = TurretBase.TurretState.EXPOSED
	game._auto_select_weapon()
	assert(game.weapon_index == 0)
	game._select_slot(1)
	game.aim = Vector2(900, 100)
	game._auto_select_weapon()
	assert(game.weapon_index == 0)
	assert(game._best_weapon_for_armor(3) == 1)
	assert(game._best_weapon_for_armor(0) == 0)
	assert(turret.laser_length == 1400)
	game.guard_energy = 100
	game._receive(false, "AUTO GUARD")
	assert(game.state == "playing" and game.guarding and game.guard_energy == 82)
	Input.action_press("guard")
	game._update_player(0.01)
	assert(game.guarding and game.auto_guard_left == 0)
	Input.action_release("guard")
	game.guarding = false
	game.guard_energy = 0
	game._receive(false, "NO ENERGY")
	assert(game.state == "dead")
	game.return_to_start()
	game.start_level(0)
	game._start_boss()
	assert(game.boss_entering and game.boss_actor.position.x > 960)
	assert(not game.boss_actor.combat_enabled)
	game._update_boss(0.4)
	assert(game.boss_entering and game.boss_actor.position.x < 1180)
	game._update_boss(2)
	assert(not game.boss_entering and game.boss_actor.combat_enabled)
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
