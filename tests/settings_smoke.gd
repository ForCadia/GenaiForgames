extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.music.bus == "Music")
	assert(game.weapon_audio.fire_players[0].bus == "SFX")
	assert(game.world_audio.drone_player.bus == "SFX")
	var sfx_index := AudioServer.get_bus_index("SFX")
	var before_sfx := AudioServer.get_bus_volume_db(sfx_index)
	game.settings.set_option("music", 20)
	assert(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")), linear_to_db(0.2)))
	assert(is_equal_approx(AudioServer.get_bus_volume_db(sfx_index), before_sfx))
	game.settings.set_option("muted", true)
	assert(AudioServer.is_bus_mute(0))
	game.settings.restore_defaults()
	assert(not AudioServer.is_bus_mute(0))
	game.start_screen.show_settings(true)
	assert(game.start_screen.settings_view.visible and not game.start_screen.menu.visible)
	game.start_screen.show_settings(false)
	game.start_game()
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	game.set_ui_paused(true)
	game.overlays._process(0)
	game.overlays.settings_open = true
	game.overlays.rebuild()
	assert(paused and game.overlays.settings_open)
	var elapsed: float = game.run_elapsed
	game._process(10)
	assert(game.run_elapsed == elapsed and game.lab.events.is_empty())
	game.settings.set_option("tutorials", false)
	game.player_hud.sync()
	assert(not game.player_hud.hints_layer.visible)
	game.settings.restore_defaults()
	game.music.stop()
	game.world_audio.stop_all()
	game.weapon_audio.stop_all()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	print("SETTINGS AUDIO ISOLATION / MUTE / NAVIGATION / PAUSED TIME: PASS")
	quit()
