extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	root.size = Vector2i(960, 720)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await create_timer(0.2).timeout
	game.set_process(false)
	game.lab_panel.toggle_panel()
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tmp")
	assert(root.get_texture().get_image().save_png("res://tmp/lab-b-panel.png") == OK)
	game.lab_panel.toggle_panel()
	game._die("CAPTURE CHECK")
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://tmp/lab-b-death.png") == OK)
	print("LAB B CAPTURES PASS")
	quit(0)
