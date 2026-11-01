extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
var title: Label
var armor: Label
var armor_bar: ProgressBar
var health: ProgressBar
var trail: ProgressBar
var damage_tween: Tween
var last_hp := -1
var last_plates := -1
var armor_tween: Tween

func _ready() -> void:
	custom_minimum_size.x = 440
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := F.box(self, true)
	title = F.label(header, "SENTINEL", "AmberLabel")
	F.spacer(header)
	armor = F.label(header, "ARMOR ◆ ◆")
	armor_bar = F.bar(self,440,"ProgressBar")
	armor_bar.custom_minimum_size.y = 8
	var fill := StyleBoxFlat.new()
	fill.bg_color = UIPalette.CYAN
	armor_bar.add_theme_stylebox_override("fill",fill)
	var track := Control.new()
	track.custom_minimum_size.y = 12
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	trail = F.bar(track, 0, "TrailBar")
	trail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	health = F.bar(track, 0, "BossBar")
	health.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func apply_state(hp: int, maximum: int, plates: int, phase: int, armor_points := -1, armor_maximum := 36) -> void:
	armor.show()
	armor_bar.show()
	var remaining := plates * 18 if armor_points < 0 else armor_points
	armor_bar.max_value = armor_maximum
	armor_bar.value = remaining
	armor_bar.modulate = Color.WHITE if remaining > 0 else Color(0.3,0.4,0.5,0.5)
	title.text = "SENTINEL / PHASE %02d" % phase
	armor.text = "ARMOR %d / %d // AP" % [remaining,armor_maximum] if plates > 0 else "WEAK POINT EXPOSED"
	if plates != last_plates: armor.modulate = Color.WHITE if plates > 0 else UIPalette.AMBER
	if plates < last_plates:
		if armor_tween: armor_tween.kill()
		armor_tween = create_tween().set_loops(3)
		armor_tween.tween_property(armor, "modulate:a", 0.15, 0.08)
		armor_tween.tween_property(armor, "modulate:a", 1.0, 0.08)
	last_plates = plates
	health.max_value = maximum
	trail.max_value = maximum
	health.value = hp
	if hp != last_hp:
		if damage_tween: damage_tween.kill()
		if last_hp < 0 or hp > last_hp: trail.value = hp
		else:
			damage_tween = create_tween()
			damage_tween.tween_interval(0.3)
			damage_tween.tween_property(trail, "value", float(hp), 0.4)
		last_hp = hp

func apply_mecha_state(hp: int, maximum: int) -> void:
	# Reuse shared health animation, then suppress all destructible-armor UI.
	apply_state(hp,maximum,0,1,0,1)
	title.text = "GUNBLADE / 枪刀机甲"
	armor.hide()
	armor_bar.hide()

func apply_iron_state(hp: int, maximum: int, _cannon_hp: int, _launcher_hp: int, _plate_hp: int) -> void:
	apply_state(hp,maximum,0,1,0,1)
	title.text = "IRON BASTION"
	armor.show()
	armor_bar.hide()
	armor.text = "SHARED HULL / CANNON HP // CORE EXPOSED"
