extends PanelContainer

@export var key_text := "SPACE"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxEmpty.new()
	for side in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(side, 6)
	for side in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(side, 3)
	add_theme_stylebox_override("panel", style)
	preload("res://ui/ui_factory.gd").label(self, key_text, "SmallLabel")
