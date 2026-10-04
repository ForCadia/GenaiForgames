extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	for distance in [0, 1671, 1672, 3343, 3344, 6000]:
		game.distance = distance
		game._update_parallax()
		await process_frame
		var image := root.get_texture().get_image()
		print("PARALLAX %d: " % distance, image.save_png("res://tests/parallax_%04d.png" % distance))
	quit(0)
