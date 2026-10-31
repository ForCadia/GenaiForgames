extends VBoxContainer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
const CAMPAIGNS := preload("res://campaign_data.gd")
var game: Node
var back: Callable
var first_button: Button
var mission_buttons: Array[Button] = []
var mode_label: Label
const DESCRIPTIONS := ["前线突围 · 四阶段 + Boss", "突破信号封锁 · 四阶段 + Boss", "攻入钢铁堡垒 · 四阶段 + Boss", "每五波迎战 Boss · 死亡从首波重新开始"]

func _ready() -> void:
	custom_minimum_size.x = 600
	add_theme_constant_override("separation",12)
	F.label(self,"SELECT MISSION","LargeLabel")
	mode_label = F.label(self,"THREE FRONTS / ONE ENDLESS CHALLENGE","AmberLabel")
	for index in range(CAMPAIGNS.LEVELS.size()):
		var data: Dictionary = CAMPAIGNS.LEVELS[index]
		var button := mission_row("%02d" % (index+1),str(data.name),DESCRIPTIONS[index],func(): game.start_level(index))
		mission_buttons.append(button)
		if index == 0: first_button = button
	add_child(HSeparator.new())
	mission_buttons.append(mission_row("∞","ENDLESS / 无尽模式",DESCRIPTIONS[3],func(): game.start_endless()))
	var center := CenterContainer.new()
	add_child(center)
	STYLE.primary(F.button(center,"BACK",back)).custom_minimum_size.x = 200
	refresh()

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
	button.set_meta("description_label",F.label(copy,description,"MutedLabel"))
	return button

func refresh() -> void:
	mode_label.text = "开发模式 / 全部关卡开放" if game.play_profile == "development" else ("游客 / 每次重新进入从零开始" if game.play_profile == "guest" else "存档：" + game.progression.profile_name.left(20))
	for index in range(mission_buttons.size()):
		var button := mission_buttons[index]
		button.disabled = not game.mission_unlocked(index)
		button.modulate = Color(0.5,0.56,0.64) if button.disabled else Color.WHITE
		var label: Label = button.get_meta("description_label")
		label.text = ("未解锁 / 通关第 %d 关后开放" % index) if button.disabled else DESCRIPTIONS[index]
