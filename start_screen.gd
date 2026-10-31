extends CanvasLayer

var game: Node
var start_button: Button
var developer_button: Button
var boss_test_button: Button

func _ready() -> void:
	layer = 40
	var root := Control.new()
	root.theme = Theme.new()
	root.theme.default_font = preload("res://assets/fonts/NotoSansSC.ttf")
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.03, 0.07, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 500
	center.add_child(card)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	_add_label(box, "EVERFRONT", 36, Color("63e6f2"))
	_add_label(box, "THE FRONT NEVER STOPS", 16, Color("e4f8ff"))
	start_button = Button.new()
	start_button.text = "开始游戏"
	start_button.custom_minimum_size.y = 48
	start_button.pressed.connect(func(): game.start_game())
	box.add_child(start_button)
	developer_button = Button.new()
	developer_button.text = "开发模式"
	developer_button.custom_minimum_size.y = 40
	developer_button.pressed.connect(func(): game.start_game("checkpoint", 0, true))
	box.add_child(developer_button)
	boss_test_button = Button.new()
	boss_test_button.text = "Boss 战测试"
	boss_test_button.custom_minimum_size.y = 40
	boss_test_button.pressed.connect(func(): game.start_game("checkpoint", 0, false, true))
	box.add_child(boss_test_button)
	_add_label(box, "SPACE/W Jump   S/CTRL Slide   Mouse Aim\n按住 A/D 前后微调，松开自动回位\nLeft click Fire   Right click Guard   1/2/3 Weapons\nR Reload   R / SPACE / Left click Retry after death\nESC 返回开始界面   M 静音 / 恢复声音", 14, Color("a5bed0"))
	_add_label(box, "开发模式：调参、A/B 切换与测试数据记录。", 13, Color("a5bed0"))

func _add_label(parent: Node, text: String, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
