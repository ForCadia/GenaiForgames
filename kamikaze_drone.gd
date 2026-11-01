extends Node2D
# Real gameplay enemy; atlas rows: idle/fly/detect/charge/hurt/explode.
signal killed(drone: Node2D)
signal exploded(drone: Node2D)
const SHEET := preload("res://assets/enemies/kamikaze_drone_8x6.png")
const SCORE := 150
const ANIMATIONS := ["idle","fly","detect","charge","hurt","explode"]
const COUNTS := [6,8,6,8,4,8]
const FPS := [10.0,12.0,14.0,18.0,20.0,20.0]
const CHARGE_SPEED := 500.0
const WARNING_TIME := 0.42
const BLAST_RADIUS := 48.0
var sprite := AnimatedSprite2D.new()
var state := "idle"
var health := 2
var age := 0.0
var state_left := 0.35
var hurt_left := 0.0
var target := Vector2.ZERO
var charge_direction := Vector2.LEFT
var damage_done := false
var base_y := 460.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var cell := Vector2(SHEET.get_width()/8.0,SHEET.get_height()/6.0)
	for row in range(ANIMATIONS.size()):
		var animation: String = ANIMATIONS[row]
		frames.add_animation(animation)
		frames.set_animation_speed(animation,FPS[row])
		frames.set_animation_loop(animation,animation not in ["hurt","explode"])
		for column in range(COUNTS[row]):
			var atlas := AtlasTexture.new()
			atlas.atlas = SHEET
			atlas.region = Rect2(Vector2(column,row)*cell,cell)
			frames.add_frame(animation,atlas)
	sprite.sprite_frames = frames
	sprite.scale = Vector2(84.0/cell.x,84.0/cell.y)
	add_child(sprite)
	play_pose("idle")

func play_pose(animation: String) -> void:
	sprite.flip_h = animation in ["fly","charge"]
	# Charge art places the robot ahead of its flame trail; keep the body
	# attached to the gameplay hitbox after horizontal mirroring.
	sprite.position = Vector2(18 if animation == "charge" else (4 if animation == "fly" else 0),0)
	if sprite.animation != animation or not sprite.is_playing(): sprite.play(animation)

func advance(delta: float, scroll: float, player_center: Vector2) -> void:
	age += delta
	state_left -= delta
	hurt_left = maxf(0,hurt_left-delta)
	if state == "explode": return
	match state:
		"idle":
			position.x -= scroll*delta
			if state_left <= 0: state = "fly"
		"fly":
			position.x -= (scroll+100.0)*delta
			position.y = base_y+sin(age*3.2)*12
			if position.x < 760:
				state = "detect"
				state_left = WARNING_TIME
		"detect":
			position.x -= scroll*0.25*delta
			if state_left <= 0:
				target = player_center
				charge_direction = (target-position).normalized()
				state = "charge"
		"charge":
			position += charge_direction*CHARGE_SPEED*delta
			if position.distance_to(target)<24 or position.x < target.x-65: explode(false,false)
	if state != "explode" and hurt_left <= 0: play_pose(state)

func body_rect() -> Rect2:
	return Rect2(global_position-Vector2(21,17),Vector2(42,34))

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if state == "explode": return false
	var rect := body_rect()
	if rect.has_point(from) or rect.has_point(to): return true
	var points := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(from,to,points[index],points[(index+1)%4]) != null: return true
	return false

func take_damage(penetration: int) -> void:
	if state == "explode": return
	health -= 2 if penetration >= 3 else 1
	if health <= 0: explode(true,false)
	else:
		hurt_left = 0.2
		play_pose("hurt")

func force_kill() -> void:
	if state == "explode": damage_done = true; return
	explode(true,true)

func explode(defeated: bool, harmless: bool) -> void:
	if state == "explode": return
	state = "explode"
	state_left = 0.4
	damage_done = harmless
	play_pose("explode")
	if defeated: killed.emit(self)
	exploded.emit(self)

func try_damage(rect: Rect2) -> bool:
	if state != "explode" and body_rect().intersects(rect): explode(false,false)
	if state != "explode" or damage_done or state_left < 0.24: return false
	var closest := Vector2(clampf(global_position.x,rect.position.x,rect.end.x),clampf(global_position.y,rect.position.y,rect.end.y))
	if global_position.distance_to(closest) <= BLAST_RADIUS:
		damage_done = true
		return true
	return false

func is_finished() -> bool:
	return (state == "explode" and state_left <= 0) or position.x < -150 or position.y < -120 or position.y > 850 or age > 8
