extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_level(0)
	assert(is_equal_approx(game._guard_drain(),100.005))
	assert(game.guard_regen() == 6.25 and game._guard_hit_cost() == 18 and game._guard_delay() == 1.25)
	game.progression.owned["auto_guard"] = true
	game.guard_energy = 18
	assert(game._receive(false,"LAST BLOCK"))
	assert(game.guard_energy == 0 and not game.guarding and game.guard_lock > 0)
	game._receive(false,"SECOND HIT")
	assert(game.state == "dead")
	game.return_to_start()
	game.start_level(0)
	game._start_boss()
	game._update_boss(2)
	var before: int = game.boss_actor.armor_points()
	game.grenade_count = 1
	game._grenade()
	assert(game.boss.hp == GameData.BOSS.health-1 and game.boss_actor.armor_points() == before)
	game.player_hud.sync()
	assert(game.player_hud.boss_hud.armor_bar.value == 36)
	game.boss_actor.receive_shot(3,game.boss_actor.position)
	game.player_hud.sync()
	assert(game.player_hud.boss_hud.armor_bar.value == 33)
	game.return_to_start()
	game.start_game("checkpoint",0,true)
	assert(game._guard_hit_cost() == 7 and game.guard_regen() == 50 and game._guard_drain() == GameData.GUARD.drain_per_second)
	game._start_boss()
	assert(game.boss_actor.armor_per_layer == 3)
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("BOSS ARMOR HUD / GRENADE / GUARD NERF / BREAK LOCK / LAB BASELINE: PASS")
	quit()
