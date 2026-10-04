extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.aim = Vector2(850, 540)
	await create_timer(0.25).timeout
	var captured := root.get_texture().get_image()
	if captured == null:
		push_error("Viewport capture unavailable")
		quit(1)
		return
	var result := captured.save_png("res://tests/player_capture.png")
	print("CAPTURE: ", result)
	game.set_process(false)
	var visual: PlayerVisual = game.get_node("Player")
	visual.position = Vector2(430, 610)
	visual.scale = Vector2(1.8, 1.8)
	await process_frame
	var closeup := root.get_texture().get_image()
	if closeup != null:
		print("CLOSEUP: ", closeup.save_png("res://tests/player_closeup.png"))
	visual.set_process(false)
	visual.set_motion(true, false, 0, Vector2(850, 250), false, true)
	await process_frame
	print("AIM UP: ", root.get_texture().get_image().save_png("res://tests/player_head_aim_up.png"))
	visual.set_motion(true, false, 0, Vector2(850, 540), true, true)
	await process_frame
	print("GUARD: ", root.get_texture().get_image().save_png("res://tests/player_guard.png"))
	visual.set_motion(true, false, 0, Vector2(850, 540), false, true)
	for frame in [0, 3, 9]:
		visual.body_state = "run"
		visual.body_time = (float(frame) + 0.1) / 14.0
		visual._apply_frames()
		await process_frame
		print("RUN %d: " % frame, root.get_texture().get_image().save_png("res://tests/player_run_%02d.png" % frame))
	visual.play_reload(1.2)
	for frame in [0, 2, 4, 6]:
		visual.arm_time = (float(frame) + 0.1) / 8.0 * 1.2
		visual._apply_frames()
		await process_frame
		print("RELOAD %d: " % frame, root.get_texture().get_image().save_png("res://tests/player_reload_%02d.png" % frame))
	visual.arm_action = ""
	visual.set_primary_weapon(1)
	visual.play_fire()
	visual.arm_time = 0.11
	visual._apply_frames()
	await process_frame
	print("HIGH FIRE: ", root.get_texture().get_image().save_png("res://tests/player_high_fire.png"))
	visual.arm_action = ""
	visual.set_primary_weapon(0)
	for pose in ["jump", "slide"]:
		visual.body_state = pose
		visual.body_time = 3.0 / 12.0
		visual._apply_frames()
		await process_frame
		print("POSE %s: " % pose, root.get_texture().get_image().save_png("res://tests/player_%s.png" % pose))
	visual.play_death()
	for frame in [0, 3, 7]:
		visual.body_time = (float(frame) + 0.1) / 12.0
		visual._apply_frames()
		await process_frame
		print("DEATH %d: " % frame, root.get_texture().get_image().save_png("res://tests/player_death_%02d.png" % frame))
	quit(0)
