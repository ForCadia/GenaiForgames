extends SceneTree

func _initialize() -> void:
	var names := ["background", "background-moon", "middlelayer", "track"]
	var images: Dictionary = {}
	for name in names:
		var image: Image = load("res://%s.png" % name).get_image()
		images[name] = image
		var opaque := 0
		for y in range(0, image.get_height(), 8):
			for x in range(0, image.get_width(), 8):
				if image.get_pixel(x, y).a > 0.99:
					opaque += 1
		var edge_difference := 0.0
		for y in range(0, image.get_height(), 8):
			edge_difference += _difference(image.get_pixel(0, y), image.get_pixel(image.get_width() - 1, y))
		print(name, " ", image.get_size(), " opaque_samples=", opaque, " edge_difference=", edge_difference)
	var moon: Image = images["background-moon"]
	var background: Image = images["background"]
	var different := 0
	for y in range(0, moon.get_height(), 8):
		for x in range(0, moon.get_width(), 8):
			if _difference(moon.get_pixel(x, y), background.get_pixel(x, y)) > 0.02:
				different += 1
	print("moon changed samples=", different)
	for name in ["middlelayer", "track"]:
		var image: Image = images[name]
		for x in [0, 190, 500, 900, 1671]:
			var first := -1
			for y in range(image.get_height()):
				if image.get_pixel(x, y).a > 0.5:
					first = y
					break
			print(name, " x=", x, " first_opaque_y=", first)
	quit(0)

func _difference(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
