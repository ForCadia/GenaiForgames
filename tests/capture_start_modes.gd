extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tmp")
	assert(root.get_texture().get_image().save_png("res://tmp/start-screen.png") == OK)
	game.start_game("campaign", 2)
	game.set_process(false)
	game.lab_panel.toggle_panel()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://tmp/start-modes-panel.png") == OK)
	print("START SCREEN / MODE PANEL CAPTURES PASS")
	quit(0)
