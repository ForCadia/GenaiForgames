extends SceneTree

# background-moon.png is an opaque alternate composite, not a transparent
# moon. Extract only the brighter moon/glow into a separate transparent PNG.
# Both original images remain untouched.
func _initialize() -> void:
	var plain: Image = load("res://background.png").get_image()
	var moon: Image = load("res://background-moon.png").get_image()
	assert(plain.get_size() == moon.get_size())
	var overlay := Image.create_empty(moon.get_width(), moon.get_height(), false, Image.FORMAT_RGBA8)
	var center := Vector2(450, 183)
	for y in range(75, 305):
		for x in range(325, 575):
			var radius := Vector2(x, y).distance_to(center)
			if radius >= 115.0:
				continue
			var source := moon.get_pixel(x, y)
			var base := plain.get_pixel(x, y)
			var brighter := (source.r - base.r) * 0.25 + (source.g - base.g) * 0.5 + (source.b - base.b) * 0.25
			var edge := clampf((115.0 - radius) / 16.0, 0.0, 1.0)
			var alpha := clampf((brighter - 0.018) * 8.0, 0.0, 1.0) * edge
			if alpha > 0.0:
				overlay.set_pixel(x, y, Color(source.r, source.g, source.b, alpha))
	var result := overlay.save_png("res://background_moon_overlay.png")
	print("MOON OVERLAY: ", result)
	quit(0 if result == OK else 1)
