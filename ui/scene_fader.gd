extends CanvasLayer

var shade: ColorRect
var fade: Tween

func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	shade = ColorRect.new()
	shade.color = Color.BLACK
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.modulate.a = 0

func reveal() -> void:
	# Cosmetic only: never delays run start or the recorded retry timestamp.
	if fade: fade.kill()
	shade.modulate.a = 1
	fade = create_tween()
	fade.tween_property(shade, "modulate:a", 0.0, 0.2)
