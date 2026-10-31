extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
var title: Label
var armor: Label
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
	var track := Control.new()
	track.custom_minimum_size.y = 12
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	trail = F.bar(track, 0, "TrailBar")
	trail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	health = F.bar(track, 0, "BossBar")
	health.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func apply_state(hp: int, maximum: int, plates: int, phase: int) -> void:
	title.text = "SENTINEL / PHASE %02d" % phase
	armor.text = "ARMOR " + "◆ ".repeat(plates) if plates > 0 else "WEAK POINT EXPOSED"
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
