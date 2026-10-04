extends SceneTree

func _initialize() -> void:
	var image: Image = load("res://lazerdrone.png").get_image()
	print("LASER SOURCE: ", image.get_size())
	for row in range(3):
		for column in range(6):
			var x0 := int(floor(float(column) * image.get_width() / 6.0))
			var x1 := int(floor(float(column + 1) * image.get_width() / 6.0))
			var y0 := int(floor(float(row) * image.get_height() / 3.0))
			var y1 := int(floor(float(row + 1) * image.get_height() / 3.0))
			var bounds := Rect2i(x1, y1, 0, 0)
			var left := x1
			var top := y1
			var right := -1
			var bottom := -1
			for y in range(y0, y1):
				for x in range(x0, x1):
					if image.get_pixel(x, y).a > 0.1:
						left = mini(left, x)
						top = mini(top, y)
						right = maxi(right, x)
						bottom = maxi(bottom, y)
			if right >= 0:
				bounds = Rect2i(left - x0, top - y0, right - left + 1, bottom - top + 1)
			print("row ", row, " col ", column, " slice ", Rect2i(x0,y0,x1-x0,y1-y0), " alpha ", bounds)
	quit(0)
