extends VBoxContainer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
const CAMPAIGNS := preload("res://campaign_data.gd")
var game: Node
var back: Callable
var first_button: Button

func _ready() -> void:
	custom_minimum_size.x = 600
	add_theme_constant_override("separation",12)
	F.label(self,"SELECT MISSION","LargeLabel")
	F.label(self,"THREE FRONTS / ONE ENDLESS CHALLENGE","AmberLabel")
	for index in range(CAMPAIGNS.LEVELS.size()):
		var data: Dictionary = CAMPAIGNS.LEVELS[index]
		var descriptions := ["前线突围 · 四阶段 + Boss", "突破信号封锁 · 四阶段 + Boss", "攻入钢铁堡垒 · 四阶段 + Boss"]
		var button := mission_row("%02d" % (index+1),str(data.name),descriptions[index],func(): game.start_level(index))
		if index == 0: first_button = button
	add_child(HSeparator.new())
	mission_row("∞","ENDLESS / 无尽模式","每五波迎战 Boss · 死亡从首波重新开始",func(): game.start_endless())
	var center := CenterContainer.new()
	add_child(center)
	STYLE.primary(F.button(center,"BACK",back)).custom_minimum_size.x = 200

func mission_row(number: String, title: String, description: String, action: Callable) -> Button:
	var button := F.button(self,"",action)
	button.custom_minimum_size = Vector2(600,76)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,16)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,10)
	var row := F.box(margin,true)
	row.add_theme_constant_override("separation",20)
	var index_label := F.label(row,number,"LargeLabel")
	index_label.modulate = STYLE.AMBER
	index_label.custom_minimum_size.x = 40
	index_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var copy := F.box(row)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(copy,title,"SmallLabel")
	F.label(copy,description,"MutedLabel")
	return button
