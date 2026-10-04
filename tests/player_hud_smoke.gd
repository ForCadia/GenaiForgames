extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var hud_scene: PackedScene = load("res://PlayerHUD.tscn")
	var preview: PlayerHUD = hud_scene.instantiate()
	root.add_child(preview)
	await process_frame
	assert(preview.health_label.text == "HP1/1")
	assert(preview.weapon_label.text == "ASSAULT RIFLE")
	assert(not preview.has_node("Root/StatusPanel/Margin/VBox/ReloadLabel"))
	preview.queue_free()

	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var hud: PlayerHUD = game.player_hud
	assert(game.get_children().filter(func(child: Node) -> bool: return child is PlayerHUD).size() == 1)
	assert(hud.health_label.text == "HP1/1" and hud.health_bar.value == 1)
	assert(hud.ammo_bar.value == 1)
	assert(hud.penetration_label.text == "PEN 1")
	assert(hud.health_bar.size.x >= 38 and hud.health_bar.size.x <= 54)
	assert(hud.ammo_bar.size.x >= 38 and hud.ammo_bar.size.x <= 54)
	assert(absf(hud.status_panel.get_global_rect().get_center().x - game._player_hitbox().get_center().x) <= 1)
	assert(hud.status_panel.get_global_rect().end.y <= game._player_hitbox().position.y - 23)
	Input.action_press("crouch")
	game._process(0.0)
	Input.action_release("crouch")
	assert(game.crouching)
	assert(absf(hud.status_panel.get_global_rect().get_center().x - game._player_hitbox().get_center().x) <= 1)
	assert(hud.status_panel.get_global_rect().end.y <= game._player_hitbox().position.y - 23)
	game.crouching = false
	game.slide_time_left = 0.0
	game.player_visual.set_collision_pose(false)
	game.player.y = 500
	game._process(0.0)
	assert(absf(hud.status_panel.get_global_rect().get_center().x - game._player_hitbox().get_center().x) <= 1)
	assert(hud.status_panel.get_global_rect().end.y <= game._player_hitbox().position.y - 23)
	game.player.y = GameData.GROUND_Y
	game._process(0.0)

	var shot_count: int = game.shots.size()
	game._fire()
	assert(game.shots.size() == shot_count + 1 and game.ammo[0] == 23)
	assert(not hud.has_node("Root/StatusPanel/Margin/VBox/ReloadLabel"))
	assert(is_equal_approx(hud.ammo_bar.value, 23.0 / 24.0))
	game._fire() # Cooldown blocks both the shot and UI decrement.
	assert(game.shots.size() == shot_count + 1 and game.ammo[0] == 23)
	game._switch_weapon()
	assert(game.weapon_index == 1 and game.ammo[0] == 23)
	assert(hud.weapon_label.text == "PIERCER")
	assert(hud.penetration_label.text == "PEN 3")
	assert(hud.ammo_bar.value == 1)
	game.shot_left = 0.0
	game._fire()
	assert(game.ammo[1] == 4 and is_equal_approx(hud.ammo_bar.value, 0.8))
	game._reload()
	assert(is_equal_approx(game.reload_left, 1.8))
	assert(hud.ammo_bar.value == 0)
	assert(hud.ammo_bar.get_theme_stylebox("fill") == hud.reload_fill_style)
	game._switch_weapon() # Existing rule: switch is blocked during reload.
	assert(game.weapon_index == 1)
	game._fire()
	assert(game.ammo[1] == 4)
	game._update_player(0.9)
	assert(is_equal_approx(hud.ammo_bar.value, 0.5))
	game._update_player(0.9)
	assert(game.ammo[1] == 5 and hud.ammo_bar.value == 1)
	assert(hud.ammo_bar.get_theme_stylebox("fill") == hud.normal_fill_style)
	game._switch_weapon()
	assert(hud.weapon_label.text == "ASSAULT RIFLE" and is_equal_approx(hud.ammo_bar.value, 23.0 / 24.0))
	game.ammo[0] = 0
	game.shot_left = 0.0
	game._refresh_player_ui()
	shot_count = game.shots.size()
	game._fire()
	assert(game.shots.size() == shot_count and game.ammo[0] == 0)
	assert(hud.ammo_bar.value == 0)
	game._die("TEST")
	assert(hud.health_label.text == "HP0/1" and hud.health_bar.value == 0)
	game._retry()
	assert(hud.health_label.text == "HP1/1" and hud.health_bar.value == 1)
	assert(hud.ammo_bar.value == 1)
	print("PLAYER HUD / FIRE / RELOAD / SWITCH / RETRY: PASS")
	quit(0)
