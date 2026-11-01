extends Node2D
signal killed(actor: Node2D)
signal projectile_requested(origin: Vector2, direction: Vector2, speed: float, color: Color)
signal sound_requested(cue: String)
const SHEET := preload("res://assets/enemies/aerial_rifleman_8x6.png")
const SCORE := 180
const ANIMATIONS := ["idle","fly","aim","shoot","boost","die"]
var sprite := AnimatedSprite2D.new()
var state := "enter"
var health := 3
var age := 0.0
var state_left := 0.0
var base_y := 300.0
var hover_x := 750.0
var velocity := Vector2.ZERO
var burst_direction := Vector2.LEFT
var rounds_left := 0
var volleys := 0
var hurt_left := 0.0
var contact_left := 0.0
var boost_target := Vector2.ZERO

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var cell := Vector2(SHEET.get_width()/8.0,SHEET.get_height()/6.0)
	for row in range(ANIMATIONS.size()):
		frames.add_animation(ANIMATIONS[row])
		frames.set_animation_speed(ANIMATIONS[row],14.0 if row == 5 else 12.0)
		frames.set_animation_loop(ANIMATIONS[row],row != 5)
		for column in range(8):
			var atlas := AtlasTexture.new()
			atlas.atlas = SHEET
			atlas.region = Rect2(Vector2(column,row)*cell,cell)
			frames.add_frame(ANIMATIONS[row],atlas)
	sprite.sprite_frames = frames
	sprite.scale = Vector2.ONE*(96.0/maxf(cell.x,cell.y))
	sprite.flip_h = true
	add_child(sprite)
	sprite.play("fly")
	hover_x = 730.0+randf_range(-45,55)

func advance(delta: float, scroll: float, player_center: Vector2) -> void:
	age += delta
	state_left -= delta
	contact_left = maxf(0.0,contact_left-delta)
	hurt_left = maxf(0.0,hurt_left-delta)
	sprite.modulate = Color(1.5,0.7,0.7) if hurt_left > 0 else Color.WHITE
	if state == "dead":
		velocity.y += 500.0*delta
		position += velocity*delta
		return
	var wanted := Vector2.ZERO
	match state:
		"enter":
			wanted = Vector2(-170,(base_y-position.y)*4.0)
			if position.x <= hover_x:
				state = "hover"
				state_left = 0.35
		"hover":
			wanted = Vector2((hover_x-position.x)*4.0,(base_y+sin(age*2.5)*12-position.y)*5.0)
			if state_left <= 0:
				state = "aim"
				state_left = 0.6
		"aim":
			wanted = Vector2((hover_x-position.x)*3.0,(base_y-position.y)*4.0)
			if state_left <= 0:
				burst_direction = (player_center-(global_position+Vector2(-25,4))).normalized()
				state = "shoot"
				state_left = 0.0
				rounds_left = 3
		"shoot":
			if state_left <= 0:
				projectile_requested.emit(global_position+Vector2(-25,4),burst_direction,320.0,Color("ff9638"))
				sound_requested.emit("light_turret_fire")
				rounds_left -= 1
				state_left = 0.18
				if rounds_left <= 0:
					volleys += 1
					state = "boost"
					state_left = 0.75
					boost_target = Vector2(clampf(position.x+(45.0 if volleys % 2 == 1 else -60.0),620.0,860.0),clampf(base_y+(48.0 if volleys % 2 == 1 else -48.0),250.0,390.0))
		"boost":
			wanted = (boost_target-position)*4.5
			if state_left <= 0:
				base_y = boost_target.y
				hover_x = boost_target.x
				state = "retreat" if volleys >= 2 else "hover"
				state_left = 0.45
		"retreat": wanted = Vector2(-maxf(160.0,scroll*0.7),sin(age*3.0)*12)
	velocity = velocity.lerp(wanted,1.0-exp(-7.0*delta))
	position += velocity*delta
	var pose: String = "fly" if state in ["enter","retreat"] else ("idle" if state == "hover" else state)
	if sprite.animation != StringName(pose): sprite.play(pose)

func body_rect() -> Rect2:
	return Rect2(global_position-Vector2(18,30),Vector2(36,60))

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if state == "dead": return false
	var rect := body_rect()
	if rect.has_point(from) or rect.has_point(to): return true
	var corners := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(from,to,corners[index],corners[(index+1)%4]) != null: return true
	return false

func take_damage(penetration: int) -> void:
	if state == "dead": return
	health -= 2 if penetration >= 3 else 1
	hurt_left = 0.15
	if health <= 0: force_kill()

func force_kill() -> void:
	if state == "dead": return
	state = "dead"
	state_left = 8.0/14.0
	velocity = Vector2(-35,50)
	sprite.play("die")
	killed.emit(self)
	sound_requested.emit("enemy_explode")

func is_finished() -> bool:
	return (state == "dead" and state_left <= 0) or position.x < -120 or position.y > 820 or age > 16.0
