extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game.set_process(false)
	var hud: PlayerHUD = game.player_hud
	assert(game.get_children().filter(func(child: Node) -> bool: return child is PlayerHUD).size() == 1)
	assert(hud.ammo_bar.value == 100)
	assert(hud.penetration_label.text == "PEN ◆")
	var hud_origin: Vector2 = hud.ammo_label.global_position
	game.player.y = 500
	game._process(0.0)
	assert(hud.ammo_label.global_position == hud_origin)
	game.player.y = GameData.GROUND_Y
	var shot_count: int = game.shots.size()
	game._fire()
	assert(game.shots.size() == shot_count + 1 and game.ammo[0] == 23)
	assert(hud.reload_label.text == "MAGAZINE")
	assert(is_equal_approx(hud.ammo_bar.value, 23.0 / 24.0 * 100))
	game._fire() # Cooldown blocks both the shot and UI decrement.
	assert(game.shots.size() == shot_count + 1 and game.ammo[0] == 23)
	game._switch_weapon()
	assert(game.weapon_index == 1 and game.ammo[0] == 23)
	assert(hud.weapon_label.text == "PIERCER")
	assert(hud.penetration_label.text == "PEN ◆◆◆")
	assert(hud.ammo_bar.value == 100)
	game.shot_left = 0.0
	game._fire()
	assert(game.ammo[1] == 4 and is_equal_approx(hud.ammo_bar.value, 80))
	game._reload()
	assert(is_equal_approx(game.reload_left, 1.8))
	assert(hud.ammo_bar.value == 0)
	assert(hud.reload_label.text == "RELOADING")
	game._switch_weapon() # Existing rule: switch is blocked during reload.
	assert(game.weapon_index == 1)
	game._fire()
	assert(game.ammo[1] == 4)
	game._update_player(0.9)
	hud._process(0.1)
	assert(hud.ammo_bar.value > 0 and hud.ammo_bar.value < 50)
	assert(hud.ammo_bar.modulate.a < 1.0)
	game._update_player(0.9)
	assert(game.ammo[1] == 5 and hud.ammo_bar.value == 100)
	assert(hud.reload_label.text == "MAGAZINE")
	game._switch_weapon()
	assert(hud.weapon_label.text == "ASSAULT RIFLE" and is_equal_approx(hud.ammo_bar.value, 23.0 / 24.0 * 100))
	game.ammo[0] = 0
	game.shot_left = 0.0
	game._refresh_player_ui()
	shot_count = game.shots.size()
	game._fire()
	assert(game.shots.size() == shot_count and game.ammo[0] == 0)
	assert(hud.ammo_bar.value == 0)
	game._die("TEST")
	hud.sync()
	assert(hud.visible and not hud.tutorial_label.visible)
	game._retry()
	assert(game.state == "playing")
	assert(hud.ammo_bar.value == 100)
	print("PLAYER HUD / FIRE / RELOAD / SWITCH / RETRY: PASS")
	game.music.stop()
	game.world_audio.stop_all()
	game.weapon_audio.stop_all()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	quit(0)
