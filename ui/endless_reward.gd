extends CanvasLayer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
const TALENTS := preload("res://endless_talents.gd")
var game: Node
var choices: Array[String] = []

func _ready() -> void:
	layer = 100
	var root := Control.new()
	root.theme = STYLE.theme()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.015,0.025,0.045,0.88)
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 680
	center.add_child(panel)
	var column := F.box(panel)
	column.add_theme_constant_override("separation",16)
	F.label(column,"WAVE %02d CLEARED" % game.endless_wave,"LargeLabel")
	F.label(column,"选择一项强化 / 仅本轮有效，死亡重开清空","SmallLabel")
	for id in choices:
		var data: Dictionary = TALENTS.POOL[id]
		var rank := int(game.endless_talent_ranks.get(id,0))
		var title: String = data.name + ("  Lv.%d → %d" % [rank,rank+1] if not data.get("repeatable",false) else "")
		var button := STYLE.primary(F.button(column,title+"\n"+str(data.text),func(): game.choose_endless_talent(id)))
		button.custom_minimum_size.y = 100
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if id == choices[0]: button.grab_focus()
	F.label(column,"选择后进入下一波 · Esc 返回标题","MutedLabel")
