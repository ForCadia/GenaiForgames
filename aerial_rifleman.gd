extends Node2D
signal killed(actor: Node2D)
signal projectile_requested(origin: Vector2, direction: Vector2, speed: float, color: Color)
signal sound_requested(cue: String)
const SHEET := preload("res://assets/enemies/aerial_rifleman_8x6.png")
const SCORE := 180
const GD := preload("res://game_data.gd")
const ORBIT_RADIUS := Vector2(104,64)
const BULLET_SPEED := 480.0
const FIRE_DIRECTION := Vector2(-0.70710678,0.70710678)
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
var orbit_center := Vector2.ZERO
var orbit_phase := 0.0
var landed := false
var fall_time := 0.0
var landing_time := 0.0

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
	sprite.scale = Vector2.ONE*(128.0/maxf(cell.x,cell.y))
	sprite.flip_h = true
	add_child(sprite)
	sprite.play("fly")
	hover_x = 790.0

func advance(delta: float, scroll: float, _player_center: Vector2) -> void:
	age += delta
	state_left -= delta
	contact_left = maxf(0.0,contact_left-delta)
	hurt_left = maxf(0.0,hurt_left-delta)
	sprite.modulate = Color(1.5,0.7,0.7) if hurt_left > 0 else Color.WHITE
	if state == "dead":
		_advance_fall(delta,scroll)
		return
	var wanted := Vector2.ZERO
	if state == "enter":
		wanted = Vector2(-230,(base_y-position.y)*4.0)
		if position.x <= hover_x:
			orbit_center = Vector2(650,base_y)
			orbit_phase = 0.0
			state = "orbit"
			state_left = 2.6
	elif state == "retreat":
		wanted = Vector2(-maxf(160.0,scroll*0.7),sin(age*3.0)*12)
	else:
		# Same ellipse/tangent steering as the kamikaze, without any dive.
		var phase_speed := TAU/2.6*(0.45 if state in ["aim","shoot"] else 1.0)
		orbit_phase += phase_speed*delta
		var path := orbit_center+Vector2(cos(orbit_phase)*ORBIT_RADIUS.x,sin(orbit_phase)*ORBIT_RADIUS.y)
		var tangent := Vector2(-sin(orbit_phase)*ORBIT_RADIUS.x,cos(orbit_phase)*ORBIT_RADIUS.y)*phase_speed
		wanted = tangent+(path-position)*4.0
		match state:
			"orbit":
				if state_left <= 0:
					state = "aim"
					state_left = 0.6
			"aim":
				if state_left <= 0:
					burst_direction = FIRE_DIRECTION
					state = "shoot"
					state_left = 0.0
					rounds_left = 3
			"shoot":
				if state_left <= 0:
					projectile_requested.emit(_muzzle_position(),burst_direction,BULLET_SPEED,Color("ff9638"))
					sound_requested.emit("light_turret_fire")
					rounds_left -= 1
					state_left = 0.18
					if rounds_left <= 0:
						volleys += 1
						state = "retreat" if volleys >= 2 else "orbit"
						state_left = 2.6
	velocity = velocity.lerp(wanted,1.0-exp(-7.0*delta))
	position += velocity*delta
	var attacking: bool = state in ["aim","shoot"]
	var desired_rotation := deg_to_rad(-30.0) if attacking else clampf(velocity.y/700.0,-0.15,0.15)
	sprite.rotation = lerp_angle(sprite.rotation,desired_rotation,1.0-exp(-14.0*delta))
	var pose: String = state if attacking else "fly"
	if sprite.animation != StringName(pose): sprite.play(pose)

func _muzzle_position() -> Vector2:
	return global_position+Vector2(-36,10).rotated(sprite.rotation)

func _advance_fall(delta: float, scroll: float) -> void:
	var floor_y: float = get_parent().to_global(Vector2(0,GD.GROUND_Y)).y-38.0
	sprite.rotation = lerp_angle(sprite.rotation,0.0,1.0-exp(-10.0*delta))
	if not landed:
		fall_time += delta
		velocity.y += 700.0*delta
		position += Vector2(-35.0-scroll*0.35,velocity.y)*delta
		sprite.frame = mini(2,int(fall_time*14.0))
		if global_position.y >= floor_y:
			global_position.y = floor_y
			landed = true
			landing_time = 0.0
			sprite.frame = 3
			sound_requested.emit("enemy_explode")
	else:
		landing_time += delta
		position.x -= scroll*delta
		sprite.frame = mini(7,3+int(landing_time*14.0))

func body_rect() -> Rect2:
	return Rect2(global_position-Vector2(24,40),Vector2(48,80))

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
	landed = false
	fall_time = 0.0
	landing_time = 0.0
	velocity = Vector2(-35,50)
	sprite.animation = &"die"
	sprite.stop()
	sprite.frame = 0
	killed.emit(self)

func is_finished() -> bool:
	if state == "dead": return (landed and landing_time >= 5.0/14.0) or position.x < -150
	return position.x < -120 or position.y > 820 or age > 18.0
