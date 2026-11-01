extends VBoxContainer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
const CAMPAIGNS := preload("res://campaign_data.gd")
var game: Node
var back: Callable
var build_button: Button
var wallet_label: Label
var upgrade_hint: Label
var first_button: Button
var mission_buttons: Array[Button] = []
var mode_label: Label
var difficulty_buttons: Dictionary = {}
const DESCRIPTIONS := ["前线突围 · 四阶段 + Boss", "突破信号封锁 · 四阶段 + Boss", "攻入钢铁堡垒 · 四阶段 + Boss", "每五波迎战 Boss · 死亡从首波重新开始"]

func _ready() -> void:
	custom_minimum_size.x = 600
	add_theme_constant_override("separation",12)
	F.label(self,"SELECT MISSION","LargeLabel")
	mode_label = F.label(self,"THREE FRONTS / ONE ENDLESS CHALLENGE","AmberLabel")
	build_button = STYLE.primary(F.button(self,"",func(): game.start_screen.show_build(true)))
	build_button.custom_minimum_size.y = 80
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,16)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,12)
	var row := F.box(margin,true)
	row.add_theme_constant_override("separation",16)
	var text := F.box(row)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F.label(text,"构筑升级 / BUILD TREE","LargeLabel").modulate = STYLE.AMBER
	upgrade_hint = F.label(text,"强化护盾与武器，再出击","MutedLabel")
	var coin := TextureRect.new()
	coin.texture = preload("res://assets/items/credit_coin.png")
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.custom_minimum_size = Vector2(24,24)
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(coin)
	wallet_label = F.label(row,"","AmberLabel")
	wallet_label.add_theme_font_size_override("font_size",18)
	wallet_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	for index in range(CAMPAIGNS.LEVELS.size()):
		var data: Dictionary = CAMPAIGNS.LEVELS[index]
		var button := mission_row("%02d" % (index+1),str(data.name),DESCRIPTIONS[index],func(): game.start_level(index))
		mission_buttons.append(button)
		if index == 0: first_button = button
	add_child(HSeparator.new())
	mission_buttons.append(mission_row("∞","ENDLESS / 无尽模式",DESCRIPTIONS[3],func(): game.start_endless()))
	var difficulty_row := F.box(self,true)
	difficulty_row.add_theme_constant_override("separation",12)
	F.label(difficulty_row,"无尽难度","MutedLabel").size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var group := ButtonGroup.new()
	for spec in [["easy","简单 / EASY"],["normal","普通 / NORMAL"],["hard","困难 / HARD"]]:
		var id: String = spec[0]
		var button := F.button(difficulty_row,spec[1],func(): game.endless_difficulty = id; refresh(),true)
		button.theme_type_variation = "MenuCompact"
		button.custom_minimum_size = Vector2(148,32)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.button_group = group
		difficulty_buttons[id] = button

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
	for id in difficulty_buttons:
		var button: Button = difficulty_buttons[id]
		button.disabled = not game.mission_unlocked(3)
		button.set_pressed_no_signal(id == game.endless_difficulty)
		button.modulate = STYLE.AMBER if id == game.endless_difficulty else Color.WHITE
	wallet_label.text = "%d G" % game.progression.coins
	var available := 0
	for id in preload("res://build_data.gd").NODES:
		if game.progression.can_buy(id): available += 1
	upgrade_hint.text = "%d 项升级可购买 / 强化后再出击" % available if available > 0 else "花费金币，强化护盾与武器"
	mode_label.text = "开发模式 / 全部关卡开放" if game.play_profile == "development" else ("游客 / 每次重新进入从零开始" if game.play_profile == "guest" else "存档：" + game.progression.profile_name.left(20))
	for index in range(mission_buttons.size()):
		var button := mission_buttons[index]
		button.disabled = not game.mission_unlocked(index)
		button.modulate = Color(0.5,0.56,0.64) if button.disabled else Color.WHITE
		var label: Label = button.get_meta("description_label")
		label.text = ("未解锁 / 通关第 %d 关后开放" % index) if button.disabled else DESCRIPTIONS[index]
		if index == 3 and not button.disabled:
			var names := {"easy":"简单","normal":"普通","hard":"困难"}
			label.text = "%s / 每五波 Boss · 死亡从首波重开" % names[game.endless_difficulty]
