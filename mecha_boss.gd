class_name MechaBoss
extends Node2D
signal damage_requested
signal projectile_requested(origin: Vector2, direction: Vector2, speed: float, color: Color)
signal sound_requested(cue: String)
signal feedback(origin: Vector2, color: Color, message: String)
const DATA := preload("res://mecha_boss_data.gd")
const GD := preload("res://game_data.gd")
const SHEETS := {
	"ground_fire":preload("res://assets/boss_mecha/ground_fire.png"),
	"slash":preload("res://assets/boss_mecha/slash.png"),
	"lift":preload("res://assets/boss_mecha/lift.png"),
	"air_fire":preload("res://assets/boss_mecha/air_fire.png"),
	"stab":preload("res://assets/boss_mecha/stab.png"),
	"death":preload("res://assets/boss_mecha/death.png")}
@onready var visual: Sprite2D = $Visual
var frames: Dictionary = {}
var images: Dictionary = {}
var state := "inactive"
var elapsed := 0.0
var combat_enabled := false
var action_contact_used := false
var pose_sheet := "slash"
var pose_frame := 0
var pose_meta: Dictionary = {}
var scale_factor := 0.7
var phase_start := Vector2.ZERO
var phase_goal := Vector2.ZERO
var shot_count := 0
var fire_direction := Vector2.LEFT
var death_time := 0.0
var previous_position := Vector2.ZERO

func _ready() -> void:
	frames = preload("res://mecha_boss_frames.gd").FRAMES.duplicate(true)
	for key in SHEETS:
		var image: Image = SHEETS[key].get_image()
		if image.is_compressed(): image.decompress()
		images[key] = image
	set_process(false)
	reset_for_battle(false)

func reset_for_battle(enabled: bool) -> void:
	combat_enabled = enabled
	visible = enabled
	state = "entry" if enabled else "inactive"
	elapsed = 0.0
	visual.modulate = Color.WHITE
	_set_pose("slash",0)

func set_combat_enabled(enabled: bool) -> void:
	combat_enabled = enabled

func _set_pose(sheet: String, frame: int) -> void:
	if frames.is_empty(): return
	pose_sheet = sheet
	pose_frame = clampi(frame,0,frames[sheet].size()-1)
	pose_meta = frames[sheet][pose_frame]
	visual.texture = SHEETS[sheet]
	visual.region_enabled = true
	visual.region_rect = Rect2(pose_meta.x,pose_meta.y,pose_meta.w,pose_meta.h)
	# Keep chest-to-helmet scale consistent rather than resizing low/raised legs.
	var reference: Dictionary = frames[sheet][0]
	var chest_span := maxf(45.0,float(reference.cy)-float(reference.top))
	scale_factor = (DATA.BODY_HEIGHT*0.38)/chest_span
	if sheet == "death": scale_factor = (DATA.BODY_HEIGHT*0.38)/maxf(45.0,float(frames.lift[3].cy)-float(frames.lift[3].top))
	visual.scale = Vector2.ONE*scale_factor
	visual.flip_h = false
	visual.flip_v = false
	visual.rotation = 0.0
	visual.position = -Vector2(float(pose_meta.cx)+20.0,float(pose_meta.bottom))*scale_factor

func _frame(sequence: Array, duration: float) -> int:
	return int(sequence[clampi(int(elapsed/maxf(duration,0.001)*sequence.size()),0,sequence.size()-1)])

func _enter(next: String) -> void:
	state = next
	elapsed = 0.0
	phase_start = position
	action_contact_used = false
	shot_count = 0
	match state:
		"slash": phase_goal = Vector2(maxf(280.0,position.x-DATA.CHARGE_DISTANCE),GD.GROUND_Y)
		"retreat": phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y)
		"takeoff": phase_goal = Vector2(DATA.AIR_X,GD.GROUND_Y-DATA.HOVER_HEIGHT)
		"air_fire": fire_direction = Vector2(-0.84,0.542586).normalized()
		"stab": phase_goal = Vector2(maxf(210.0,position.x-DATA.STAB_DISTANCE),position.y)
		"air_return": phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y-DATA.HOVER_HEIGHT)
		"land": phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y)

func advance(delta: float) -> void:
	if state == "dead":
		death_time += delta
		_set_pose("death",mini(7,int(death_time*9.0)))
		return
	if not combat_enabled: return
	previous_position = position
	elapsed += delta
	match state:
		"entry":
			_set_pose("slash",0)
			position = position.move_toward(Vector2(DATA.HOME_X,GD.GROUND_Y),DATA.ENTRY_SPEED*delta)
			if position.distance_to(Vector2(DATA.HOME_X,GD.GROUND_Y)) < 1: _enter("ground_prepare")
		"ground_prepare":
			_set_pose("slash",0)
			if elapsed >= DATA.PREPARE: _enter("ground_fire")
		"ground_fire":
			_set_pose("ground_fire",_frame(DATA.GROUND_FIRE_FRAMES,DATA.GROUND_FIRE_TIME))
			_fire_burst(delta,false)
			if elapsed >= DATA.GROUND_FIRE_TIME: _enter("ground_recover")
		"ground_recover":
			_set_pose("slash",0)
			if elapsed >= DATA.RECOVERY: _enter("slash_prepare")
		"slash_prepare":
			_set_pose("slash",_frame(DATA.SLASH_READY,DATA.SLASH_PREPARE))
			if elapsed >= DATA.SLASH_PREPARE: _enter("slash")
		"slash":
			_set_pose("slash",_frame(DATA.SLASH_ACTIVE,DATA.SLASH_TIME))
			position = position.move_toward(phase_goal,DATA.CHARGE_SPEED*delta)
			if elapsed >= DATA.SLASH_TIME: _enter("slash_recover")
		"slash_recover":
			_set_pose("slash",_frame(DATA.SLASH_RECOVER,DATA.RECOVERY))
			if elapsed >= DATA.RECOVERY: _enter("retreat")
		"retreat":
			_set_pose("slash",0)
			position = position.move_toward(phase_goal,DATA.RETREAT_SPEED*delta)
			if position.distance_to(phase_goal) < 1: _enter("takeoff_wait")
		"takeoff_wait":
			_set_pose("slash",0)
			if elapsed >= DATA.RECOVERY: _enter("takeoff")
		"takeoff":
			var index := mini(3,int(elapsed/DATA.TAKEOFF_TIME*4.0))
			if index == 0: _set_pose("slash",0)
			else: _set_pose("lift",index)
			position = phase_start.lerp(phase_goal,smoothstep(0.0,1.0,minf(1.0,elapsed/DATA.TAKEOFF_TIME)))
			if elapsed >= DATA.TAKEOFF_TIME: _enter("air_prepare")
		"air_prepare":
			_set_pose("lift",3)
			if elapsed >= DATA.AIR_PREPARE: _enter("air_fire")
		"air_fire":
			_set_pose("air_fire",mini(7,int(elapsed/DATA.AIR_FIRE_TIME*8.0)))
			_fire_burst(delta,true)
			if elapsed >= DATA.AIR_FIRE_TIME: _enter("air_recover")
		"air_recover":
			_set_pose("lift",3)
			if elapsed >= DATA.RECOVERY: _enter("stab_prepare")
		"stab_prepare":
			_set_pose("stab",_frame(DATA.STAB_READY,DATA.STAB_PREPARE))
			if elapsed >= DATA.STAB_PREPARE: _enter("stab")
		"stab":
			_set_pose("stab",_frame(DATA.STAB_ACTIVE,DATA.STAB_TIME))
			position = position.move_toward(phase_goal,DATA.STAB_SPEED*delta)
			if elapsed >= DATA.STAB_TIME: _enter("stab_recover")
		"stab_recover":
			_set_pose("stab",_frame(DATA.STAB_RECOVER,DATA.STAB_RECOVERY))
			if elapsed >= DATA.STAB_RECOVERY: _enter("air_return")
		"air_return":
			_set_pose("lift",3)
			position = position.move_toward(phase_goal,DATA.RETREAT_SPEED*delta)
			if position.distance_to(phase_goal) < 1: _enter("land")
		"land":
			var index := mini(3,int(elapsed/DATA.LAND_TIME*4.0))
			if index == 3: _set_pose("slash",0)
			else: _set_pose("lift",4+index)
			position = phase_start.lerp(phase_goal,smoothstep(0.0,1.0,minf(1.0,elapsed/DATA.LAND_TIME)))
			if elapsed >= DATA.LAND_TIME: _enter("land_recover")
		"land_recover":
			_set_pose("slash",0)
			if elapsed >= DATA.LAND_RECOVERY: _enter("ground_prepare")

func _muzzle(air: bool) -> Vector2:
	# Source-space barrel tip; no flame included, same transformed pose as artwork.
	var source := Vector2(float(pose_meta.cx)-168.0,float(pose_meta.cy)-3.0)
	if air: source = Vector2(float(pose_meta.cx)-151.0,float(pose_meta.cy)+89.0)
	return visual.to_global(source)

func _fire_burst(_delta: float, air: bool) -> void:
	var phases: Array = DATA.AIR_SHOT_PHASES if air else DATA.GROUND_SHOT_PHASES
	var duration: float = DATA.AIR_FIRE_TIME if air else DATA.GROUND_FIRE_TIME
	if shot_count >= phases.size() or elapsed < float(phases[shot_count])*duration: return
	# Emission and visible muzzle flash share the same source frame.
	if air: _set_pose("air_fire",1 if shot_count == 0 else 4)
	else: _set_pose("ground_fire",1)
	shot_count += 1
	projectile_requested.emit(_muzzle(air),fire_direction if air else Vector2.LEFT,DATA.AIR_BULLET_SPEED if air else DATA.GROUND_BULLET_SPEED,Color("ff9638"))
	sound_requested.emit("light_turret_fire")

func core_position() -> Vector2:
	if pose_meta.is_empty(): return global_position+Vector2(-10,-90)
	return visual.to_global(Vector2(pose_meta.cx,pose_meta.cy))

func _core_hit(from: Vector2, to: Vector2) -> bool:
	var radius := maxf(7.0,13.0*scale_factor)
	return Geometry2D.get_closest_point_to_segment(core_position(),from,to).distance_to(core_position()) <= radius

func _body_pixel(local: Vector2) -> bool:
	var x := int(local.x)
	var y := int(local.y)
	if x < 0 or y < 0 or x >= int(pose_meta.w) or y >= int(pose_meta.h): return false
	# Exclude the gun/sword beyond the actual torso/limbs envelope.
	if x < float(pose_meta.cx)-65.0 and y < float(pose_meta.cy)+48.0: return false
	if x > float(pose_meta.cx)+175.0 or y < float(pose_meta.top): return false
	var pixel: Color = images[pose_sheet].get_pixel(int(pose_meta.x)+x,int(pose_meta.y)+y)
	if pixel.a < 0.85: return false
	# Red blade/energy glow and orange gun flash never count as body armor.
	if pixel.r > 0.4 and pixel.r > pixel.g*1.7 and pixel.r > pixel.b*1.7: return false
	if pixel.r > 0.8 and pixel.g > 0.8 and pixel.b > 0.8:
		for offset in [-4,-2,2,4]:
			var sample_y: int = int(pose_meta.y)+y+int(offset)
			if sample_y < 0 or sample_y >= images[pose_sheet].get_height(): continue
			var neighbor: Color = images[pose_sheet].get_pixel(int(pose_meta.x)+x,sample_y)
			if neighbor.a > 0.5 and neighbor.r > 0.6 and neighbor.g < 0.3 and neighbor.b < 0.3: return false
	return true

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if not combat_enabled or state in ["entry","dead","inactive"]: return false
	if _core_hit(from,to): return true
	var a := visual.to_local(from)
	var b := visual.to_local(to)
	var steps := maxi(1,int(ceil(a.distance_to(b))))
	for index in range(steps+1):
		if _body_pixel(a.lerp(b,float(index)/float(steps))): return true
	return false

func receive_shot_segment(penetration: int, from: Vector2, to: Vector2) -> void:
	if not shot_hits(from,to): return
	var required: int = DATA.CORE_PENETRATION if _core_hit(from,to) else DATA.BODY_PENETRATION
	if penetration < required:
		sound_requested.emit("armor_ricochet")
		feedback.emit(to,Color.WHITE,"RICOCHET")
		return
	damage_requested.emit()

func required_penetration(from: Vector2, to: Vector2) -> int:
	return DATA.CORE_PENETRATION if _core_hit(from,to) else DATA.BODY_PENETRATION

func _blade_rect() -> Rect2:
	var core := core_position()
	# Ground sweep is below a normal jump; aerial thrust is fixed above a
	# grounded player's head. Body overlap is never a second damage source.
	if state == "slash": return Rect2(core+Vector2(-128,18),Vector2(142,25))
	return Rect2(core+Vector2(-140,-10),Vector2(150,20))

func try_melee(player_rect: Rect2, guard_rect: Rect2) -> bool:
	if not combat_enabled or action_contact_used: return false
	var active: bool = (state == "slash" and pose_frame in [7,8,10,9]) or (state == "stab" and pose_frame == 4)
	if not active: return false
	var area := _blade_rect()
	# Include swept travel so fast lunges cannot skip player contact.
	var movement := global_position-previous_position
	area = area.merge(Rect2(area.position-movement,area.size))
	if area.intersects(player_rect) or (guard_rect.has_area() and area.intersects(guard_rect)):
		action_contact_used = true
		return true
	return false

func start_death() -> void:
	combat_enabled = false
	state = "dead"
	death_time = 0.0
	position.y = GD.GROUND_Y
	_set_pose("death",0)
	set_process(true)

func _process(delta: float) -> void:
	if state == "dead": advance(delta)
