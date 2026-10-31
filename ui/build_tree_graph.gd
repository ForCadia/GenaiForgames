extends Control
signal node_selected(id: String)
const DATA := preload("res://build_data.gd")
const P := preload("res://ui/ui_palette.gd")
const NODE_SIZE := Vector2(128,40)
const ROOT_SIZE := Vector2(110,38)
const CAPSTONE_SIZE := Vector2(148,46)
const CAPSTONES := ["fast_regen","auto_guard","auto_weapon"]
var profile: Node
var buttons: Dictionary = {}
var selected := "cell"
func _ready() -> void:
	custom_minimum_size = Vector2(896,540)
	var root_button := Button.new()
	root_button.text = "核心 / CORE"
	root_button.position = DATA.ROOT_POSITION - ROOT_SIZE*0.5
	root_button.size = ROOT_SIZE
	root_button.disabled = true
	add_child(root_button)
	for id in DATA.NODES:
		var button := Button.new()
		button.add_theme_font_size_override("font_size",13)
		button.tooltip_text = DATA.NODES[id].text
		button.pressed.connect(func(): selected = id; refresh(); node_selected.emit(id))
		add_child(button)
		buttons[id] = button
	refresh()
func node_size(id: String) -> Vector2: return CAPSTONE_SIZE if id in CAPSTONES else NODE_SIZE
func branch_color(branch: String) -> Color: return P.CYAN if branch == "regen" else (P.AMBER if branch == "defense" else P.RED)
func node_state(id: String) -> String:
	if profile.has_upgrade(id): return "owned"
	for parent in DATA.NODES[id].parents:
		if parent != "core" and not profile.has_upgrade(parent): return "blocked"
	return "can_buy" if profile.can_buy(id) else "poor"
func refresh() -> void:
	for id in buttons:
		var node: Dictionary = DATA.NODES[id]
		var color := branch_color(node.branch)
		var state := node_state(id)
		var style := StyleBoxFlat.new()
		var font_color := P.TEXT
		match state:
			"owned":
				style.bg_color = Color(color.r,color.g,color.b,0.30)
				style.border_color = color
				style.set_border_width_all(2)
			"can_buy":
				style.bg_color = Color(0.05,0.08,0.11,0.97)
				style.border_color = color
				style.set_border_width_all(2)
			"poor":
				style.bg_color = Color(0.04,0.055,0.075,0.97)
				style.border_color = Color(color.r,color.g,color.b,0.55)
				style.set_border_width_all(1)
				font_color = P.AMBER
			"blocked":
				style.bg_color = Color(0.03,0.04,0.055,0.97)
				style.border_color = P.PANEL_EDGE
				style.set_border_width_all(1)
				font_color = P.TEXT_DIM
		if id == selected:
			style.border_color = P.TEXT
			style.set_border_width_all(2)
			style.shadow_color = Color(color.r,color.g,color.b,0.5)
			style.shadow_size = 6
		for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: style.set_content_margin(side,3)
		for box_state in ["normal","hover","focus","pressed"]: buttons[id].add_theme_stylebox_override(box_state,style)
		buttons[id].add_theme_color_override("font_color",font_color)
		buttons[id].add_theme_color_override("font_hover_color",Color.WHITE)
		buttons[id].size = node_size(id)
		buttons[id].position = node.pos - buttons[id].size*0.5
		buttons[id].modulate = Color.WHITE if state != "blocked" or id == selected else Color(0.62,0.66,0.72)
		buttons[id].text = str(node.name)+"\n"+("已购买" if state == "owned" else str(node.cost)+" G")
	queue_redraw()
func edge_points(from_id: String, to_id: String) -> Array:
	var origin: Vector2 = DATA.ROOT_POSITION if from_id == "core" else DATA.NODES[from_id].pos
	var target: Vector2 = DATA.NODES[to_id].pos
	var origin_size: Vector2 = ROOT_SIZE if from_id == "core" else node_size(from_id)
	var target_size: Vector2 = node_size(to_id)
	var delta: Vector2 = target-origin
	var start: Vector2
	if absf(delta.x) >= absf(delta.y): start = origin+Vector2(signf(delta.x)*origin_size.x*0.5,0)
	else: start = origin+Vector2(0,signf(delta.y)*origin_size.y*0.5)
	var corner := Vector2(target.x,start.y)
	var end: Vector2 = target+Vector2(0,-signf(delta.y)*target_size.y*0.5)
	return [start,corner,end]
func _draw() -> void:
	for id in DATA.NODES:
		var node: Dictionary = DATA.NODES[id]
		for parent in node.parents:
			var color := branch_color(node.branch) if profile.has_upgrade(parent) or profile.has_upgrade(id) else P.PANEL_EDGE
			draw_polyline(edge_points(parent,id),Color(color,0.75),2)
	for id in CAPSTONES:
		var node: Dictionary = DATA.NODES[id]
		var color := branch_color(node.branch)
		var rect := Rect2(node.pos-node_size(id)*0.5-Vector2(4,4),node_size(id)+Vector2(8,8))
		var alpha := 0.85 if profile.has_upgrade(id) or profile.can_buy(id) else 0.35
		draw_rect(rect,Color(color.r,color.g,color.b,alpha),false,1)
