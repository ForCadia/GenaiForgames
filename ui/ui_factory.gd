extends RefCounted

static func root(parent: Node) -> Control:
	var node := Control.new()
	node.theme = frameless_theme()
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

static func frameless_theme() -> Theme:
	var result := preload("res://ui/ui_theme.tres").duplicate() as Theme
	var empty := StyleBoxEmpty.new()
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: empty.set_content_margin(side, 12)
	for type in ["PanelContainer", "Panel", "PopupMenu"]: result.set_stylebox("panel", type, empty)
	for type in ["Button", "OptionButton", "ActiveSlot"]:
		for state in ["normal", "hover", "pressed", "focus", "disabled"]: result.set_stylebox(state, type, empty)
	return result

static func label(parent: Node, text: String, variant := "SmallLabel") -> Label:
	var node := Label.new()
	node.text = text
	node.theme_type_variation = variant
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, action: Callable, secondary := false) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 40
	if secondary: node.theme_type_variation = "SecondaryButton"
	node.pressed.connect(action)
	parent.add_child(node)
	var audio := node.get_node_or_null("/root/UIAudio")
	if audio:
		node.mouse_entered.connect(audio.tick)
		node.focus_entered.connect(audio.tick)
		node.pressed.connect(audio.confirm)
	return node

static func bar(parent: Node, width: float, variant := "ProgressBar") -> ProgressBar:
	var node := ProgressBar.new()
	node.step = 0
	node.show_percentage = false
	node.custom_minimum_size = Vector2(width, 10)
	node.theme_type_variation = variant
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

static func box(parent: Node, horizontal := false) -> BoxContainer:
	var node: BoxContainer = HBoxContainer.new() if horizontal else VBoxContainer.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

static func spacer(parent: Node) -> Control:
	var node := Control.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

static func icon(parent: Node, name: String) -> TextureRect:
	var node := TextureRect.new()
	node.texture = load("res://assets/items/grenade.png" if name == "grenade" else "res://ui/textures/" + name + ".png")
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.custom_minimum_size = Vector2(24, 24)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node
