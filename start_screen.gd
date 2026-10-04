extends CanvasLayer

var game: Node
var restart_selector: OptionButton
var parameter_selector: OptionButton
var start_button: Button

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
	_add_label(box, "重启模式", 16, Color("e4f8ff"))
	restart_selector = OptionButton.new()
	restart_selector.add_item("A · 检查点重启 / Checkpoint")
	restart_selector.add_item("B · 整局重启 / Campaign")
	box.add_child(restart_selector)
	_add_label(box, "参数模式", 16, Color("e4f8ff"))
	parameter_selector = OptionButton.new()
	for title in ["原版", "慢速", "快速换弹"]: parameter_selector.add_item(title)
	box.add_child(parameter_selector)
	start_button = Button.new()
	start_button.text = "开始游戏 / START"
	start_button.custom_minimum_size.y = 48
	start_button.pressed.connect(func():
		game.start_game("checkpoint" if restart_selector.selected == 0 else "campaign", parameter_selector.selected))
	box.add_child(start_button)
	_add_label(box, "SPACE/W 跳跃 · S/CTRL 滑铲 · 鼠标瞄准\n左键射击 · 右键防御 · 1/2/3 武器 · R 换弹\n死亡后 R / SPACE / 左键重试\nF1 调参 · F2 版本 A · F3 版本 B · T 导出 JSON", 14, Color("a5bed0"))
	_add_label(box, "点击开始才计时；每次开始均从整局开头运行。\n开始会应用所选完整参数组合，不继承自定义调参。", 13, Color("a5bed0"))

func _add_label(parent: Node, text: String, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func show_selection(mode: String, parameter_index: int) -> void:
	restart_selector.select(0 if mode == "checkpoint" else 1)
	parameter_selector.select(parameter_index)
	show()
