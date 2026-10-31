extends Control
signal node_selected(id: String)
const DATA := preload("res://build_data.gd")
const P := preload("res://ui/ui_palette.gd")
const STYLE := preload("res://ui/menu_style.gd")
const NODE_SIZE := Vector2(128,40)
const ROOT_SIZE := Vector2(112,36)
const CAPSTONE_SIZE := Vector2(156,44)
const CORE := Vector2(448,280)
var profile: Node
var buttons: Dictionary = {}
var captions: Dictionary = {}
var prices: Dictionary = {}
var positions: Dictionary = {}
var capstones: Array[String] = []
var selected := "cell"

func _ready() -> void:
	custom_minimum_size = Vector2(896,512)
	layout_nodes()
	var core := Button.new()
	core.text = "核心 / CORE"
	core.add_theme_font_size_override("font_size",12)
	core.add_theme_stylebox_override("disabled",STYLE.frame(Color("111b2a"),STYLE.EDGE,0))
	core.position = CORE - ROOT_SIZE * 0.5
	core.size = ROOT_SIZE
	core.disabled = true
	add_child(core)
	for id in DATA.NODES:
		var button := Button.new()
		button.tooltip_text = DATA.NODES[id].text
		button.pressed.connect(func(): select_node(id))
		button.focus_entered.connect(func(): select_node(id))
		add_child(button)
		buttons[id] = button
		var copy := VBoxContainer.new()
		copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		copy.add_theme_constant_override("separation",0)
		button.add_child(copy)
		copy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		copy.offset_top = 3
		copy.offset_bottom = -3
		captions[id] = preload("res://ui/ui_factory.gd").label(copy,str(DATA.NODES[id].name),"SmallLabel")
		captions[id].add_theme_font_size_override("font_size",12)
		captions[id].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prices[id] = preload("res://ui/ui_factory.gd").label(copy,"","MutedLabel")
		prices[id].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	refresh()

func layout_nodes() -> void:
	# Derive each seven-node arm from its real prerequisite topology.
	for id in DATA.NODES:
		if DATA.NODES[id].parents != ["core"]: continue
		var branch: String = DATA.NODES[id].branch
		positions[id] = Vector2(448,228) if branch == "regen" else Vector2(308 if branch == "defense" else 588,280)
		var chains: Array = []
		for child in DATA.NODES:
			if DATA.NODES[child].parents == [id]: chains.append(child)
		for index in range(chains.size()):
			var first: String = chains[index]
			var x := (368 if index == 0 else 528) if branch == "regen" else ((128 if index == 0 else 308) if branch == "defense" else (768 if index == 0 else 588))
			positions[first] = Vector2(x,178 if branch == "regen" else 330)
			for second in DATA.NODES:
				if DATA.NODES[second].parents == [first]: positions[second] = Vector2(x,128 if branch == "regen" else 380)
		for merge in DATA.NODES:
			if DATA.NODES[merge].branch != branch or DATA.NODES[merge].parents.size() != 2: continue
			positions[merge] = Vector2(448,78) if branch == "regen" else Vector2(218 if branch == "defense" else 678,430)
			for cap in DATA.NODES:
				if DATA.NODES[cap].parents == [merge]:
					positions[cap] = Vector2(448,24) if branch == "regen" else Vector2(218 if branch == "defense" else 678,484)
					capstones.append(cap)

func select_node(id: String) -> void:
	selected = id
	refresh()
	node_selected.emit(id)

func node_size(id: String) -> Vector2: return CAPSTONE_SIZE if id in capstones else NODE_SIZE
func branch_color(branch: String) -> Color:
	return STYLE.CYAN if branch == "regen" else (STYLE.AMBER if branch == "defense" else Color("b78cad"))

func node_state(id: String) -> String:
	if profile.has_upgrade(id): return "owned"
	for parent in DATA.NODES[id].parents:
		if not profile.has_upgrade(parent): return "blocked"
	return "can_buy" if profile.can_buy(id) else "poor"

func refresh() -> void:
	for id in buttons:
		var node: Dictionary = DATA.NODES[id]
		var state := node_state(id)
		var fill := Color("0f2230") if node.branch == "regen" else (Color("241c0e") if node.branch == "defense" else Color("26131a"))
		var edge := STYLE.EDGE
		if state == "owned": fill = Color("154954"); edge = STYLE.CYAN
		elif state == "can_buy": edge = STYLE.CYAN
		elif state == "poor": edge = STYLE.AMBER
		else: fill = Color("0d1520"); edge = Color("2a3a4f")
		var box := STYLE.frame(fill,edge,0)
		box.set_border_width_all(2 if state in ["owned","can_buy","poor"] else 1)
		for key in ["normal","hover","pressed"]: buttons[id].add_theme_stylebox_override(key,box)
		buttons[id].add_theme_stylebox_override("focus",STYLE.frame(Color(0,0,0,0),STYLE.AMBER,0))
		buttons[id].size = node_size(id)
		buttons[id].position = positions[id] - node_size(id) * 0.5
		captions[id].modulate = STYLE.MUTED if state == "blocked" else STYLE.TEXT
		prices[id].text = "已购买" if state == "owned" else ("锁定 · %d G" % node.cost if state == "blocked" else "%d G" % node.cost)
		prices[id].modulate = STYLE.CYAN if state == "owned" else (STYLE.AMBER if state == "poor" else STYLE.MUTED)
	queue_redraw()

func ancestors(id: String, result: Dictionary) -> void:
	if result.has(id): return
	result[id] = true
	if id != "core":
		for parent in DATA.NODES[id].parents: ancestors(parent,result)

func _draw() -> void:
	var path := {}
	ancestors(selected,path)
	for id in DATA.NODES:
		for parent in DATA.NODES[id].parents:
			var from: Vector2 = CORE if parent == "core" else positions[parent]
			var to: Vector2 = positions[id]
			var upward := to.y < from.y
			var from_size: Vector2 = ROOT_SIZE if parent == "core" else node_size(parent)
			var start := from + Vector2(0,(-1 if upward else 1)*from_size.y*0.5)
			var end := to + Vector2(0,(1 if upward else -1)*node_size(id).y*0.5)
			if is_equal_approx(from.y,to.y):
				start = from + Vector2(signf(to.x-from.x)*from_size.x*0.5,0)
				end = to - Vector2(signf(to.x-from.x)*node_size(id).x*0.5,0)
			var mid := roundf((start.y+end.y)*0.25)*2
			var color := Color("2c3d52")
			if profile.has_upgrade(parent): color = STYLE.CYAN
			if path.has(id) and path.has(parent): color = Color("bff6ff")
			draw_polyline(PackedVector2Array([start,Vector2(start.x,mid),Vector2(end.x,mid),end]),color,2)
	for id in capstones:
		var rect := Rect2(positions[id]-node_size(id)*0.5-Vector2(3,3),node_size(id)+Vector2(6,6))
		draw_rect(rect,STYLE.CYAN if profile.has_upgrade(id) else STYLE.EDGE,false,1)
	if positions.has(selected):
		var rect := Rect2(positions[selected]-node_size(selected)*0.5-Vector2(4,4),node_size(selected)+Vector2(8,8))
		draw_rect(rect,Color.WHITE,false,2)
