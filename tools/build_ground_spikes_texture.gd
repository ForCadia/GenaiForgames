extends SceneTree

# One-time, reproducible nearest-neighbor conversion of the supplied large
# transparent source. The original groundstab.png is never modified.
func _initialize() -> void:
	var source: Image = load("res://groundstab.png").get_image()
	if source == null or source.is_empty():
		push_error("Could not load groundstab.png")
		quit(1)
		return
	if source.get_size() != Vector2i(1330, 1182):
		push_error("Unexpected groundstab.png size: %s" % source.get_size())
		quit(1)
		return
	var visible := source.get_region(Rect2i(178, 474, 974, 493))
	visible.resize(214, 108, Image.INTERPOLATE_NEAREST)
	var canvas := Image.create_empty(256, 256, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	canvas.blit_rect(visible, Rect2i(0, 0, 214, 108), Vector2i(21, 130))
	var error := canvas.save_png("res://ground_spikes_game.png")
	if error != OK:
		push_error("Could not save ground_spikes_game.png: %s" % error)
		quit(1)
		return
	print("Generated ground_spikes_game.png (256x256, visible x=21..234 y=130..237)")
	quit()
