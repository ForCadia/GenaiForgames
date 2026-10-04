extends SceneTree

func _initialize() -> void:
	var image := Image.load_from_file("res://body(2).png")
	print("SIZE ", image.get_size())
	for row in range(5):
		for column in range(8):
			var left := 256
			var top := 256
			var right := -1
			var bottom := -1
			var upper_left := 256
			var upper_right := -1
			for y in range(256):
				for x in range(256):
					if image.get_pixel(column * 256 + x, row * 256 + y).a > 0.1:
						left = mini(left, x)
						top = mini(top, y)
						right = maxi(right, x)
						bottom = maxi(bottom, y)
			for y in range(top, mini(256, top + 72)):
				for x in range(256):
					if image.get_pixel(column * 256 + x, row * 256 + y).a > 0.1:
						upper_left = mini(upper_left, x)
						upper_right = maxi(upper_right, x)
			print("%d,%d: %d,%d..%d,%d upper=%d..%d" % [row, column, left, top, right, bottom, upper_left, upper_right])
	quit(0)
