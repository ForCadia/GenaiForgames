extends SceneTree

const CAMPAIGNS := preload("res://campaign_data.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	for level in range(3):
		var segments: Array = CAMPAIGNS.segments(level)
		assert(segments.size() == 4)
		for data in segments:
			var previous := -1.0
			for event in data.events:
				assert(event.at >= previous and event.at < data.duration)
				assert(event.kind in ["enemy", "grenade", "high_barrage", "low_obstacle"])
				previous = event.at
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.enter_development_session()
	assert(game.state == "start" and game.start_screen.level_select.visible and paused)
	for level in range(3):
		game.start_level(level)
		game.lab_panel.blocked = false
		game.lab_panel.release_pending = false
		assert(game.selected_level == level and not game.endless_mode and not game.lab.enabled)
		assert(game.current_segment().title == CAMPAIGNS.segments(level)[0].title)
		game._start_segment(2)
		game.score = 300
		game._die("LEVEL RETRY CHECK")
		game._retry()
		assert(game.selected_level == level and game.segment == 2)
		game._start_boss()
		assert(game.boss_mode and game.boss.hp == GameData.BOSS.health)
		game.return_to_start()
	game.start_endless()
	assert(game.endless_mode and game.endless_wave == 1)
	game.score = 500
	game.grenade_count = 2
	for wave in range(2, 6):
		game._advance_endless()
		assert(game.endless_wave == wave and game.score == 500 and game.grenade_count == 2)
	assert(game.boss_mode)
	game.boss.hp = 1
	game._boss_damage()
	assert(game.state == "intermission")
	game.lab_panel.blocked = false
	game.lab_panel.release_pending = false
	game._process(1.1)
	assert(game.endless_wave == 6 and game.state == "playing" and not game.boss_mode)
	game._die("ENDLESS RETRY CHECK")
	game._retry()
	assert(game.endless_wave == 1 and game.score == 0 and game.grenade_count == 0)
	assert(game.lab.events.is_empty())
	game.return_to_start()
	game.start_game("checkpoint", 0, true)
	assert(game.selected_level == 0 and not game.endless_mode and game.lab.enabled)
	game.music.stop()
	game.world_audio.stop_all()
	game.weapon_audio.stop_all()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	print("THREE MISSIONS / SELECTOR / CHECKPOINTS / ENDLESS / DEV ISOLATION: PASS")
	quit()
