extends Node2D
# Telegraph geometry shares the actual blade sweep; the oversized sprite is cosmetic.
const DATA := preload("res://mecha_boss_data.gd")
const SHEET := preload("res://assets/vfx/neon_effects_source.png")
var band := PackedVector2Array()
var warning := false
var clock := 0.0
var trail_left := 0.0
var last_state := ""
var slash: Sprite2D

func _ready() -> void:
	slash = Sprite2D.new()
	slash.texture = SHEET
	slash.region_enabled = true
	slash.region_rect = Rect2(27,510,119,111)
	slash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var key := ShaderMaterial.new()
	key.shader = preload("res://assets/vfx/black_key.gdshader")
	slash.material = key
	slash.visible = false
	add_child(slash)

func clear_effects() -> void:
	warning = false
	band.clear()
	trail_left = 0.0
	last_state = ""
	if is_instance_valid(slash): slash.visible = false
	queue_redraw()

func advance_effects(delta: float, boss: Node2D) -> void:
	clock += delta
	if not boss.combat_enabled:
		clear_effects()
		return
	var state: String = boss.state
	warning = state in ["slash_prepare","stab_prepare"]
	band.clear()
	var core: Vector2 = boss.core_position()
	if state == "slash_prepare":
		var area: Rect2 = Rect2(core+Vector2(-128,18),Vector2(142,25))
		var travel: float = minf(DATA.CHARGE_DISTANCE,maxf(0.0,boss.position.x-280.0))
		area = area.merge(Rect2(area.position-Vector2(travel,0),area.size)).grow(6.0)
		band = PackedVector2Array([to_local(area.position),to_local(Vector2(area.end.x,area.position.y)),to_local(area.end),to_local(Vector2(area.position.x,area.end.y))])
	elif state == "stab_prepare":
		var direction: Vector2 = boss.stab_direction
		var goal: Vector2 = boss.position+direction*DATA.STAB_DISTANCE
		goal.x = maxf(130.0,goal.x)
		goal.y = minf(preload("res://game_data.gd").GROUND_Y-4.0,goal.y)
		var end: Vector2 = core+(goal-boss.position)+direction*DATA.STAB_HIT_LENGTH
		var side: Vector2 = direction.orthogonal()*(DATA.STAB_HIT_RADIUS+8.0)
		band = PackedVector2Array([to_local(core-side),to_local(end-side),to_local(end+side),to_local(core+side)])
	if state in ["slash","stab"] and state != last_state:
		trail_left = DATA.MELEE_TRAIL_TIME
	trail_left = maxf(0.0,trail_left-delta)
	slash.visible = trail_left > 0.0
	if slash.visible:
		var direction: Vector2 = boss.stab_direction if state == "stab" else Vector2.LEFT
		slash.position = to_local(core+direction*90.0)
		slash.flip_h = true
		slash.rotation = direction.angle()-PI
		slash.scale = Vector2(2.5,2.4) if state == "slash" else Vector2(2.2,1.65)
		slash.modulate.a = minf(1.0,trail_left/0.07)
	last_state = state
	queue_redraw()

func _draw() -> void:
	if not warning or band.size() < 4: return
	var pulse: float = 0.2+0.08*sin(clock*16.0)
	draw_colored_polygon(band,Color(1.0,0.04,0.06,pulse))
	var outline: PackedVector2Array = band.duplicate()
	outline.append(band[0])
	draw_polyline(outline,Color(1.0,0.18,0.16,0.85),2.0,false)
