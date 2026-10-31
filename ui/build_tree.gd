extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
const P := preload("res://ui/ui_palette.gd")
const DATA := preload("res://build_data.gd")
var game: Node
var back: Callable
var graph: Control
var balance: Label
var name_label: Label
var status_label: Label
var effect_label: Label
var prereq_label: Label
var buy_button: Button
var selected := "cell"

func _ready() -> void:
	custom_minimum_size.x = 920
	add_theme_constant_override("separation", 10)
	var heading := F.box(self, true)
	heading.add_theme_constant_override("separation", 14)
	F.label(heading, "BUILD TREE / 构筑树", "LargeLabel")
	var legend := F.box(heading, true)
	legend.add_theme_constant_override("separation", 12)
	legend.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for spec in [["owned", "已购买"], ["can_buy", "可购买"], ["poor", "金币不足"], ["blocked", "前置未满足"]]:
		var item := F.box(legend, true)
		item.add_theme_constant_override("separation", 5)
		var swatch := Panel.new()
		swatch.custom_minimum_size = Vector2(10, 10)
		swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var swatch_style := StyleBoxFlat.new()
		match spec[0]:
			"owned":
				swatch_style.bg_color = Color(0.35, 0.75, 0.85, 1)
			"can_buy":
				swatch_style.bg_color = Color(0.05, 0.08, 0.11, 1)
				swatch_style.border_color = P.CYAN
				swatch_style.set_border_width_all(2)
			"poor":
				swatch_style.bg_color = Color(0.04, 0.055, 0.075, 1)
				swatch_style.border_color = Color(P.AMBER.r, P.AMBER.g, P.AMBER.b, 0.6)
				swatch_style.set_border_width_all(1)
			"blocked":
				swatch_style.bg_color = Color(0.03, 0.04, 0.055, 1)
				swatch_style.border_color = P.PANEL_EDGE
				swatch_style.set_border_width_all(1)
		swatch.add_theme_stylebox_override("panel", swatch_style)
		item.add_child(swatch)
		F.label(item, spec[1], "MutedLabel")
	F.spacer(heading)
	var wallet := F.box(heading, true)
	wallet.add_theme_constant_override("separation", 6)
	var coin := TextureRect.new()
	coin.texture = load("res://assets/items/credit_coin.png")
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.custom_minimum_size = Vector2(20, 20)
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wallet.add_child(coin)
	balance = F.label(wallet, "", "AmberLabel")
	balance.add_theme_font_size_override("font_size", 20)
	graph = preload("res://ui/build_tree_graph.gd").new()
	graph.profile = game.progression
	graph.node_selected.connect(func(id: String): selected = id; refresh())
	add_child(graph)
	var bottom := F.box(self, true)
	bottom.add_theme_constant_override("separation", 16)
	var info := F.box(bottom)
	info.add_theme_constant_override("separation", 3)
	info.custom_minimum_size.x = 560
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_row := F.box(info, true)
	title_row.add_theme_constant_override("separation", 10)
	name_label = F.label(title_row, "", "LargeLabel")
	name_label.add_theme_font_size_override("font_size", 20)
	status_label = F.label(title_row, "", "AmberLabel")
	status_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	effect_label = F.label(info, "", "SmallLabel")
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prereq_label = F.label(info, "", "MutedLabel")
	var side := F.box(bottom, true)
	side.add_theme_constant_override("separation", 10)
	side.size_flags_vertical = Control.SIZE_SHRINK_END
	buy_button = F.button(side, "购买", func():
		if game.state == "start" and game.progression.buy(selected): refresh())
	buy_button.custom_minimum_size.x = 170
	F.button(side, "返回", back, true).custom_minimum_size.x = 100
	refresh()

func refresh() -> void:
	if not is_instance_valid(balance): return
	balance.text = "%d G" % game.progression.coins
	var node: Dictionary = DATA.NODES[selected]
	var parents: Array[String] = []
	var locked: Array[String] = []
	for parent in node.parents:
		if parent == "core": continue
		parents.append(DATA.NODES[parent].name)
		if not game.progression.has_upgrade(parent): locked.append(DATA.NODES[parent].name)
	name_label.text = str(node.name)
	name_label.modulate = graph.branch_color(node.branch)
	effect_label.text = "效果：" + str(node.text)
	prereq_label.text = "前置：" + " + ".join(parents) if not parents.is_empty() else "从核心直接解锁"
	var shortage: int = int(node.cost) - game.progression.coins
	if game.progression.has_upgrade(selected):
		status_label.text = "● 已购买"
		status_label.modulate = P.CYAN
		buy_button.disabled = true
		buy_button.text = "已购买"
	elif not locked.is_empty():
		status_label.text = "● 前置未满足：" + " + ".join(locked)
		status_label.modulate = P.RED
		buy_button.disabled = true
		buy_button.text = "未解锁"
	elif shortage > 0:
		status_label.text = "● 金币不足（还差 %d G）" % shortage
		status_label.modulate = P.AMBER
		buy_button.disabled = true
		buy_button.text = "金币不足"
	else:
		status_label.text = "● 可购买"
		status_label.modulate = P.TEXT
		buy_button.disabled = false
		buy_button.text = "购买  %d G" % node.cost
	graph.selected = selected
	graph.refresh()
