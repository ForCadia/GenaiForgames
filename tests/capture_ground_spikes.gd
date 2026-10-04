extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._spawn_ground_spikes()
	game.ground_spikes[0].position = Vector2(450, GameData.GROUND_Y)
	await process_frame
	print("GROUND SPIKES CAPTURE: ", root.get_texture().get_image().save_png("res://tests/ground_spikes_capture.png"))
	quit(0)
