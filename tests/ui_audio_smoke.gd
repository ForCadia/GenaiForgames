extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var audio = root.get_node("UIAudio")
	var button := Button.new()
	root.add_child(button)
	assert(button.has_meta("ui_audio_bound"))
	button.pressed.emit()
	assert(audio.player.stream == audio.CLICK and audio.player.bus == "SFX")
	button.disabled = true
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	button.gui_input.emit(click)
	assert(audio.player.stream == audio.ERROR)
	audio.confirm()
	assert(audio.player.stream == audio.ERROR)
	await create_timer(0.4).timeout
	audio.confirm()
	assert(audio.player.stream == audio.CLICK)
	game.settings.set_option("sfx",25)
	assert(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")),linear_to_db(.25)))
	button.queue_free()
	game.queue_free()
	await process_frame
	print("UI BUTTON CLICK / DISABLED ERROR / ERROR PRIORITY / SFX BUS: PASS")
	quit()

