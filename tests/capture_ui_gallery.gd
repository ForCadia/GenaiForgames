extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	root.size = Vector2i(960, 720)
	var gallery = load("res://ui/debug/ui_gallery.tscn").instantiate()
	root.add_child(gallery)
	DirAccess.make_dir_recursive_absolute("res://tmp/ui-gallery")
	for index in range(gallery.pages.size()):
		gallery.show_page(index)
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tmp/ui-gallery/%02d_%s.png" % [index, gallery.pages[index]])
	gallery.game.music.stop()
	gallery.game.world_audio.stop_all()
	gallery.game.weapon_audio.stop_all()
	await create_timer(0.2).timeout
	gallery.queue_free()
	await process_frame
	quit()
