extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._spawn_laser_gate()
	var gate: LaserGateEnemy = game.laser_gates[0]
	gate.position = Vector2(430, 450)
	await process_frame
	print("HOVER: ", root.get_texture().get_image().save_png("res://tests/laser_gate_hover.png"))
	gate.take_damage()
	await process_frame
	print("HIT: ", root.get_texture().get_image().save_png("res://tests/laser_gate_hit.png"))
	await create_timer(0.24).timeout
	print("EXPLODE: ", root.get_texture().get_image().save_png("res://tests/laser_gate_explode.png"))
	quit(0)
