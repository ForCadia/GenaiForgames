extends SceneTree

const RUN_FRAME_ORDER := [0, 1, 2, 7, 5, 6, 2, 1, 0, 3]

func _initialize() -> void:
	var source: Texture2D = load("res://body(2).png")
	var frames := SpriteFrames.new()
	for name in ["idle", "run", "jump", "slide", "death"]:
		frames.add_animation(name)
		frames.set_animation_speed(name, 14.0 if name == "run" else 12.0)
		frames.set_animation_loop(name, name == "run")
	for row in range(5):
		var name: String = ["idle", "run", "jump", "slide", "death"][row]
		var columns: Array = RUN_FRAME_ORDER if name == "run" else range(8)
		for column in columns:
			var frame := AtlasTexture.new()
			frame.atlas = source
			frame.region = Rect2(column * 256, row * 256, 256, 256)
			frames.add_frame(name, frame)
	var result := ResourceSaver.save(frames, "res://player_frames.tres")
	print("PLAYER FRAMES: ", result)
	quit(0 if result == OK else 1)
