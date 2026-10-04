extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	await process_frame
	print("HUD NORMAL: ", root.get_texture().get_image().save_png("res://tests/player_hud_normal.png"))
	game._fire()
	game._reload()
	game._update_player(0.6)
	await process_frame
	print("HUD RELOAD: ", root.get_texture().get_image().save_png("res://tests/player_hud_reload.png"))
	quit(0)
