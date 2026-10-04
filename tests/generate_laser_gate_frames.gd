extends SceneTree

const CELL := 296

func _initialize() -> void:
	var sheet: Texture2D = load("res://laser_gate_atlas.png")
	var frames := SpriteFrames.new()
	for name in [&"Hover", &"Hit", &"Explode"]:
		frames.add_animation(name)
		frames.set_animation_speed(name, 8.0 if name == &"Hover" else (12.0 if name == &"Hit" else 11.0))
		frames.set_animation_loop(name, name == &"Hover")
	for row in range(3):
		var name: StringName = [&"Hover", &"Hit", &"Explode"][row]
		var count := 2 if row == 1 else 6
		for column in range(count):
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = Rect2(column * CELL, row * CELL, CELL, CELL)
			frames.add_frame(name, frame)
	var result := ResourceSaver.save(frames, "res://laser_gate_frames.tres")
	print("LASER GATE FRAMES: ", result)
	quit(0 if result == OK else 1)
