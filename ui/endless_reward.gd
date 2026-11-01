extends CanvasLayer
const F := preload("res://ui/ui_factory.gd")
const STYLE := preload("res://ui/menu_style.gd")
const TALENTS := preload("res://endless_talents.gd")
const SCREEN := preload("res://assets/ui_title_terminal.png")
const SUPPORT := preload("res://assets/ui_title_terminal_pedestal_v2.png")
const ICON := preload("res://assets/items/endless_upgrade_chip.png")
var game: Node
var choices: Array[String] = []
var cards: Array[Button] = []
var motion: Tween
var ready_to_choose := false

func _ready() -> void:
	layer = 80
	var root := F.root(self)
	root.theme = STYLE.theme()
	var width := get_viewport().get_visible_rect().size.x
	var side := minf(280.0,(width-64.0)/3.0-12.0)
	var gap := 16.0
	var left := (width-side*3.0-gap*2.0)*0.5
	for index in range(choices.size()):
		var id: String = choices[index]
		var data: Dictionary = TALENTS.POOL[id]
		var button := F.button(root,"",func():
			if ready_to_choose:
				ready_to_choose = false
				game.choose_endless_talent(id))
		button.size = Vector2(side,side)
		button.position = Vector2(left+float(index)*(side+gap),-side-40.0)
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		for state in ["normal","hover","pressed","disabled"]:
			button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
		cards.append(button)
		# Reuse the mechanical leg at uniform scale, inverted as an overhead mount.
		var support := TextureRect.new()
		var support_atlas := AtlasTexture.new()
		support_atlas.atlas = SUPPORT
		support_atlas.region = Rect2(285,135,400,540)
		support.texture = support_atlas
		support.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		support.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		support.size = Vector2(80,108)
		support.position = Vector2(side*0.5-40,-102)
		support.pivot_offset = support.size*0.5
		support.rotation = PI
		support.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(support)
		var monitor := NinePatchRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = SCREEN
		atlas.region = Rect2(0,250,1254,850)
		monitor.texture = atlas
		monitor.patch_margin_left = 138
		monitor.patch_margin_right = 138
		monitor.patch_margin_top = 105
		monitor.patch_margin_bottom = 115
		monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(monitor)
		monitor.size = Vector2(1254,1254)
		monitor.scale = Vector2.ONE*(side/1254.0)
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(content)
		content.position = Vector2(30,28)
		content.size = Vector2(side-60,side-56)
		content.add_theme_constant_override("separation",7)
		var icon := TextureRect.new()
		icon.texture = ICON
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(44,44)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)
		var title := F.label(content,str(data.name),"SmallLabel")
		title.modulate = STYLE.AMBER
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size",22)
		var rank := int(game.endless_talent_ranks.get(id,0))
		var rank_label := F.label(content,"补给" if data.get("repeatable",false) and data.effects.is_empty() else "Lv.%d → %d" % [rank,rank+1],"MutedLabel")
		rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rank_label.add_theme_font_size_override("font_size",15)
		var description := F.label(content,TALENTS.description(id,rank),"SmallLabel")
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size",18)
		button.mouse_entered.connect(func(): monitor.modulate = Color(1.15,1.15,1.15))
		button.mouse_exited.connect(func(): monitor.modulate = Color(1.15,1.15,1.15) if button.has_focus() else Color.WHITE)
		button.focus_entered.connect(func(): monitor.modulate = Color(1.15,1.15,1.15))
		button.focus_exited.connect(func(): monitor.modulate = Color.WHITE)
	motion = create_tween().set_parallel(true)
	for index in range(cards.size()):
		motion.tween_property(cards[index],"position:y",68.0,0.65).set_delay(float(index)*0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	motion.chain().tween_callback(func():
		ready_to_choose = true
		cards[0].grab_focus())

func retract(done: Callable) -> void:
	ready_to_choose = false
	if motion: motion.kill()
	motion = create_tween().set_parallel(true)
	for index in range(cards.size()):
		cards[index].disabled = true
		motion.tween_property(cards[index],"position:y",-cards[index].size.y-40.0,0.55).set_delay(float(index)*0.07).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	motion.chain().tween_callback(done)
