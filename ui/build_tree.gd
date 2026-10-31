extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
const DATA := preload("res://build_data.gd")
var game: Node
var back: Callable
var graph: Control
var balance: Label
var detail: Label
var buy_button: Button
var selected := "cell"

func _ready() -> void:
	custom_minimum_size.x = 860
	var heading := F.box(self,true)
	F.label(heading,"BUILD TREE / 构筑树","LargeLabel")
	F.spacer(heading)
	balance = F.label(heading,"","AmberLabel")
	graph = preload("res://ui/build_tree_graph.gd").new()
	graph.profile = game.progression
	graph.node_selected.connect(func(id: String): selected = id; refresh())
	add_child(graph)
	var row := F.box(self,true)
	detail = F.label(row,"","SmallLabel")
	detail.custom_minimum_size.x = 560
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_button = F.button(row,"购买",func():
		if game.state == "start" and game.progression.buy(selected): refresh())
	buy_button.custom_minimum_size.x = 130
	F.button(row,"返回",back,true).custom_minimum_size.x = 100
	refresh()

func refresh() -> void:
	if not is_instance_valid(balance): return
	balance.text = "金币 %d G" % game.progression.coins
	var node: Dictionary = DATA.NODES[selected]
	var parents: Array[String] = []
	for parent in node.parents:
		if parent != "core": parents.append(DATA.NODES[parent].name)
	detail.text = str(node.name) + "：" + str(node.text) + ("\n前置：" + " + ".join(parents) if not parents.is_empty() else "\n从核心解锁")
	buy_button.disabled = not game.progression.can_buy(selected)
	buy_button.text = "已购买" if game.progression.has_upgrade(selected) else "购买 %d G" % node.cost
	graph.selected = selected
	graph.refresh()
