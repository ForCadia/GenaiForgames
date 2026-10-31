extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_game()
	game.lab_panel.blocked = false
	game.lab_panel.release_pending = false
	await process_frame
	assert(InputMap.action_get_events("use_grenade").any(func(e): return e is InputEventKey and e.physical_keycode == KEY_F))
	game.segment_time = 0.7 * GameData.SEGMENT_PACE
	game._update_segment()
	assert(game.pickups.size() == 1)
	game.pickups[0].pos = game._player_center()
	game._update_world(0)
	assert(game.has_grenade and game.pickups.is_empty())
	assert(game.world_audio.voices.get_child_count() > 0)
	game._spawn_enemy("unarmored", 0, false)
	game.turrets[0].position.x = 500
	game._spawn_enemy("heavy", 0, false)
	var outside = game.turrets[1]
	game.threats.append({"pos": Vector2(400, 400), "radius": 4})
	var prior_score: int = game.score
	Input.action_press("use_grenade")
	game._update_player(0)
	Input.action_release("use_grenade")
	assert(not game.has_grenade and game.threats.is_empty() and game.score > prior_score)
	assert(not outside.is_queued_for_deletion())
	game.return_to_start()
	game.start_game("checkpoint", 0, false, true)
	game.lab_panel.blocked = false
	game.has_grenade = true
	game._on_boss_barrage_requested(Vector2(700, 300), 1)
	var health: int = game.boss.hp
	var armor: int = game.boss.armor
	game._grenade()
	assert(game.boss.hp == health - 1 and game.boss.armor == armor)
	assert(game.boss_particles.is_empty() and game.state == "playing")
	game.music.stop()
	game.world_audio.stop_all()
	game.weapon_audio.stop_all()
	await create_timer(0.4).timeout
	game.queue_free()
	await process_frame
	print("GRENADE F / PICKUP SOUND / CLEAR / BOSS CHIP DAMAGE: PASS")
	quit()
