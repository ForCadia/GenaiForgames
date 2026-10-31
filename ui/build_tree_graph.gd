extends Control

signal node_selected(id: String)
const DATA := preload("res://build_data.gd")
const P := preload("res://ui/ui_palette.gd")
var profile: Node
var buttons: Dictionary = {}
var selected := "cell"

func _ready() -> void:
	custom_minimum_size = Vector2(860,490)
	var root_button := Button.new()
	root_button.text = "核心 / CORE"
	root_button.position = DATA.ROOT_POSITION - Vector2(55,19)
	root_button.size = Vector2(110,38)
	root_button.disabled = true
	add_child(root_button)
	for id in DATA.NODES:
		var button := Button.new()
		button.text = str(DATA.NODES[id].name) + "\n" + str(DATA.NODES[id].cost) + " G"
		button.add_theme_font_size_override("font_size", 12)
		button.position = DATA.NODES[id].pos - Vector2(58,19)
		button.size = Vector2(116,38)
		button.tooltip_text = DATA.NODES[id].text
		button.pressed.connect(func(): selected = id; refresh(); node_selected.emit(id))
		add_child(button)
		buttons[id] = button
	refresh()

func branch_color(branch: String) -> Color:
	return P.CYAN if branch == "regen" else (P.AMBER if branch == "defense" else P.RED)

func refresh() -> void:
	for id in buttons:
		var node: Dictionary = DATA.NODES[id]
		var color := branch_color(node.branch)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.035,0.055,0.08,0.97)
		style.border_color = Color.WHITE if id == selected else (color if profile.has_upgrade(id) or profile.can_buy(id) else P.PANEL_EDGE)
		style.set_border_width_all(2 if id == selected or profile.has_upgrade(id) else 1)
		for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: style.set_content_margin(side, 3)
		for state in ["normal","hover","focus","pressed"]: buttons[id].add_theme_stylebox_override(state, style)
		buttons[id].size = Vector2(116,38)
		buttons[id].position = node.pos - buttons[id].size * 0.5
		buttons[id].modulate = Color.WHITE if profile.has_upgrade(id) or profile.can_buy(id) or id == selected else Color(0.6,0.65,0.7)
		buttons[id].text = str(node.name) + "\n" + ("已购买" if profile.has_upgrade(id) else str(node.cost) + " G")
	queue_redraw()

func _draw() -> void:
	for id in DATA.NODES:
		var node: Dictionary = DATA.NODES[id]
		for parent in node.parents:
			var origin: Vector2 = DATA.ROOT_POSITION if parent == "core" else DATA.NODES[parent].pos
			var color := branch_color(node.branch) if profile.has_upgrade(parent) else P.PANEL_EDGE
			draw_line(origin, node.pos, Color(color,0.7), 2)
