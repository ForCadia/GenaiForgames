extends SceneTree

# Repack the supplied 1774x887 sheet without scaling or overwriting it.
# Its rows are not evenly aligned and the unused hit cells contain spill.
const CELL := 296

func _initialize() -> void:
	var source: Image = load("res://lazerdrone.png").get_image()
	assert(source.get_size() == Vector2i(1774, 887))
	var atlas := Image.create_empty(CELL * 6, CELL * 3, false, Image.FORMAT_RGBA8)
	for column in range(6):
		var x0 := int(floor(float(column) * source.get_width() / 6.0))
		var x1 := int(floor(float(column + 1) * source.get_width() / 6.0))
		var width := x1 - x0
		var dest_x := column * CELL + (CELL - width) / 2
		atlas.blit_rect(source, Rect2i(x0, 30, width, CELL), Vector2i(dest_x, 0))
		if column < 2:
			atlas.blit_rect(source, Rect2i(x0, 326, width, CELL), Vector2i(dest_x, CELL))
		atlas.blit_rect(source, Rect2i(x0, 615, width, 272), Vector2i(dest_x, CELL * 2 + 12))
	var result := atlas.save_png("res://laser_gate_atlas.png")
	print("LASER GATE ATLAS: ", result)
	quit(0 if result == OK else 1)
