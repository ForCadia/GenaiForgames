extends Node2D
# Telegraph geometry shares the actual blade sweep; the oversized sprite is cosmetic.
const DATA := preload("res://mecha_boss_data.gd")
const SCREEN_SLASH := preload("res://assets/vfx/mecha_screen_slash_flipbook_v2.png")
const GD := preload("res://game_data.gd")
const SHEET := preload("res://assets/vfx/neon_effects_source.png")
var band := PackedVector2Array()
var warning := false
var clock := 0.0
var trail_left := 0.0
var last_state := ""
var effect_kind := ""
var effect_direction := Vector2.LEFT
var screen_slash: AnimatedSprite2D
var slash: Sprite2D
var cross_visible := false
var cross_position := Vector2.ZERO
var cross_progress := 0.0
var line_start := Vector2.ZERO
var line_end := Vector2.ZERO
const HAND_OFFSETS := [Vector2(56,20),Vector2(83,-4),Vector2(80,-4),Vector2(67,0),Vector2(18,-1)]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	screen_slash = AnimatedSprite2D.new()
	var flipbook := SpriteFrames.new()
	flipbook.set_animation_loop("default",false)
	flipbook.set_animation_speed("default",8.0/DATA.SLASH_TIME)
	for index in range(8):
		var frame := AtlasTexture.new()
		frame.atlas = SCREEN_SLASH
		# Individually aligned row centers, with empty gutters around the pixel blade.
		frame.region = Rect2((index%4)*384,218 if index < 4 else 694,384,100)
		frame.filter_clip = true
		flipbook.add_frame("default",frame)
	screen_slash.sprite_frames = flipbook
	screen_slash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	screen_slash.visible = false
	add_child(screen_slash)
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
	cross_visible = false
	band.clear()
	trail_left = 0.0
	last_state = ""
	if is_instance_valid(slash): slash.visible = false
	if is_instance_valid(screen_slash): screen_slash.visible = false
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
	cross_visible = state == "slash_prepare"
	if cross_visible:
		cross_progress = clampf(float(boss.elapsed)/boss.wait_time(DATA.SLASH_PREPARE),0.0,1.0)
		var hand_offset: Vector2 = HAND_OFFSETS[clampi(int(boss.pose_frame),0,4)]
		var hand_source := Vector2(float(boss.pose_meta.cx),float(boss.pose_meta.cy))+hand_offset
		cross_position = to_local(boss.visual.to_global(hand_source))
	if state == "slash_prepare":
		var area: Rect2 = Rect2(core+Vector2(-128,18),Vector2(142,25))
		var travel: float = minf(DATA.CHARGE_DISTANCE,maxf(0.0,boss.position.x-280.0))
		area = area.merge(Rect2(area.position-Vector2(travel,0),area.size)).grow(24.0)
		band = PackedVector2Array([to_local(area.position),to_local(Vector2(area.end.x,area.position.y)),to_local(area.end),to_local(Vector2(area.position.x,area.end.y))])
	elif state == "stab_prepare":
		var direction: Vector2 = boss.stab_direction
		var goal: Vector2 = boss.position+direction*DATA.STAB_DISTANCE
		goal.x = maxf(130.0,goal.x)
		goal.y = minf(preload("res://game_data.gd").GROUND_Y-4.0,goal.y)
		var end: Vector2 = core+(goal-boss.position)+direction*DATA.STAB_HIT_LENGTH
		var side: Vector2 = direction.orthogonal()*(DATA.STAB_HIT_RADIUS+30.0)
		band = PackedVector2Array([to_local(core-side),to_local(end-side),to_local(end+side),to_local(core+side)])
	if state in ["slash","stab"] and state != last_state:
		if state == "slash":
			var core_offset: Vector2 = core-boss.position
			line_start = Vector2(-120.0,boss.phase_start.y+core_offset.y+30.5)
			line_end = Vector2(GD.VIEW_SIZE.x+120.0,line_start.y)
		effect_kind = state
		effect_direction = boss.stab_direction if state == "stab" else Vector2.LEFT
		trail_left = DATA.SLASH_TIME if state == "slash" else DATA.MELEE_TRAIL_TIME
	trail_left = maxf(0.0,trail_left-delta)
	slash.visible = trail_left > 0.0 and effect_kind == "stab"
	if slash.visible:
		# Aerial thrust retains a straight directional trail.
		slash.region_rect = Rect2(27,422,340,64)
		slash.position = to_local(core+effect_direction*20.0)
		slash.flip_h = false
		slash.rotation = effect_direction.angle()-PI
		slash.scale = Vector2(0.85,1.1)
		slash.modulate.a = minf(1.0,trail_left/0.07)
	screen_slash.visible = effect_kind == "slash" and trail_left > 0.0
	if screen_slash.visible:
		var progress: float = clampf(1.0-trail_left/DATA.SLASH_TIME,0.0,1.0)
		screen_slash.frame = clampi(int(progress*8.0),0,7)
		screen_slash.position = to_local((line_start+line_end)*0.5)
		screen_slash.scale = Vector2((GD.VIEW_SIZE.x+240.0)/384.0,1.4)
	last_state = state
	queue_redraw()

func _draw() -> void:
	if warning and band.size() >= 4:
		var pulse: float = 0.24+0.06*sin(clock*16.0)
		draw_colored_polygon(band,Color(1.0,0.04,0.06,pulse))
	if cross_visible:
		var radius: float = 14.0+18.0*cross_progress
		var p: Vector2 = cross_position.round()
		draw_line(p-Vector2(radius,0),p+Vector2(radius,0),Color(1.0,0.04,0.08,0.75),5.0)
		draw_line(p-Vector2(0,radius),p+Vector2(0,radius),Color(1.0,0.04,0.08,0.75),5.0)
		draw_line(p-Vector2(radius*0.8,0),p+Vector2(radius*0.8,0),Color("ffe8dd"),2.0)
		draw_line(p-Vector2(0,radius*0.8),p+Vector2(0,radius*0.8),Color("ffe8dd"),2.0)
