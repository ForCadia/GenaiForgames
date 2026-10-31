extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func key_input(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _run() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	key_input(KEY_D, true)
	game._process(0.2)
	assert(game.player.x == GameData.PLAYER_X)
	game.start_game()
	game.lab_panel._process(0.01)
	game._process(0.2)
	assert(game.lab_panel.blocked and game.player.x == GameData.PLAYER_X)
	key_input(KEY_D, false)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	assert(not game.lab_panel.blocked)

	for is_boss in [false, true]:
		if is_boss: game._start_boss()
		var start_hitbox: Rect2 = game._player_hitbox()
		key_input(KEY_D, true)
		game._update_player(0.2)
		assert(game.player.x > GameData.PLAYER_X)
		assert(game.player_visual.position == game.player)
		assert(is_equal_approx(game._player_hitbox().position.x - start_hitbox.position.x, game.player.x - GameData.PLAYER_X))
		game._update_player(2.0)
		assert(game.player.x == GameData.PLAYER_X + GameData.PLAYER.horizontal_range)
		key_input(KEY_D, false)
		game._update_player(0.1)
		assert(game.player.x > GameData.PLAYER_X and game.player.x < GameData.PLAYER_X + GameData.PLAYER.horizontal_range)
		game._update_player(1.0)
		assert(game.player.x == GameData.PLAYER_X)
		key_input(KEY_A, true)
		game._update_player(2.0)
		assert(game.player.x == GameData.PLAYER_X - GameData.PLAYER.horizontal_range)
		key_input(KEY_D, true)
		game._update_player(1.0)
		assert(game.player.x == GameData.PLAYER_X)
		key_input(KEY_A, false)
		game.player.y = GameData.GROUND_Y - 100.0
		game.velocity_y = -100.0
		game._update_player(0.1)
		assert(game.player.x > GameData.PLAYER_X and game.player.y < GameData.GROUND_Y)
		key_input(KEY_D, false)
		game._die("HORIZONTAL_MOVEMENT_CHECK")
		var death_x: float = game.player.x
		key_input(KEY_A, true)
		game._process(0.1)
		assert(game.player.x == death_x)
		key_input(KEY_A, false)
		game._request_retry("smoke")
		game._process(0.36)
		assert(game.state == "playing" and game.player.x == GameData.PLAYER_X)
		assert(game.boss_mode == is_boss)

	game.return_to_start()
	game.music.stop()
	await create_timer(0.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("A/D HOLD / LIMITS / RELEASE / AIRBORNE / HITBOX / INPUT GATE / RETRY: PASS")
	quit(0)
