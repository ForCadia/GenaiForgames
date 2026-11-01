class_name MechaBoss
extends Node2D
signal damage_requested(origin: Vector2)
signal projectile_requested(origin: Vector2, direction: Vector2, speed: float, color: Color)
signal sound_requested(cue: String)
signal feedback(origin: Vector2, color: Color, message: String)
const DATA := preload("res://mecha_boss_data.gd")
const GD := preload("res://game_data.gd")
const EFFECTS := preload("res://mecha_boss_effects.gd")
const MELEE_EFFECTS := preload("res://mecha_melee_effects.gd")
const SHEETS := {
	"ground_fire":preload("res://assets/boss_mecha/ground_fire_spaced.png"),
	"slash":preload("res://assets/boss_mecha/slash_spaced.png"),
	"lift":preload("res://assets/boss_mecha/lift_spaced.png"),
	"air_fire":preload("res://assets/boss_mecha/air_fire_spaced.png"),
	"stab":preload("res://assets/boss_mecha/stab_spaced.png"),
	"death":preload("res://assets/boss_mecha/death_spaced.png")}
const ORIGINAL_BODY_HEIGHT := {"ground_fire":275.0,"air_fire":335.0,"lift":285.0,"stab":286.0,"slash":214.0,"death":335.0}
@onready var visual: Sprite2D = $Visual
var frames: Dictionary = {}
var images: Dictionary = {}
var frame_textures: Dictionary = {}
var state := "inactive"
var elapsed := 0.0
var combat_enabled := false
var action_contact_used := false
var pose_sheet := "slash"
var pose_frame := 0
var pose_meta: Dictionary = {}
var scale_factor := 0.7
var source_unit := 1.0
var phase_start := Vector2.ZERO
var phase_goal := Vector2.ZERO
var shot_count := 0
var fire_direction := Vector2.LEFT
var death_time := 0.0
var previous_position := Vector2.ZERO
var player_target := Vector2(GD.PLAYER_X,GD.GROUND_Y-46)
var stab_direction := Vector2.LEFT
var attack_wait_multiplier := 1.0
var effects: EFFECTS
var melee_effects: MELEE_EFFECTS

func _ready() -> void:
	frames = preload("res://mecha_boss_frames.gd").FRAMES.duplicate(true)
	for key in SHEETS:
		var image: Image = SHEETS[key].get_image()
		if image.is_compressed(): image.decompress()
		images[key] = image
		var textures: Array[Texture2D] = []
		for metadata in frames[key]:
			var atlas := AtlasTexture.new()
			atlas.atlas = SHEETS[key]
			# Crop grid-border contamination and retain the same local coordinates.
			atlas.region = Rect2(float(metadata.x)+DATA.ATLAS_INSET,float(metadata.y)+DATA.ATLAS_INSET,float(metadata.w)-DATA.ATLAS_INSET*2,float(metadata.h)-DATA.ATLAS_INSET*2)
			atlas.margin = Rect2(Vector2.ONE*DATA.ATLAS_INSET,Vector2.ONE*DATA.ATLAS_INSET*2)
			atlas.filter_clip = true
			textures.append(atlas)
		frame_textures[key] = textures
	effects = EFFECTS.new()
	effects.z_index = -1
	add_child(effects)
	melee_effects = MELEE_EFFECTS.new()
	melee_effects.z_index = 1
	add_child(melee_effects)
	set_process(false)
	reset_for_battle(false)

func set_difficulty(difficulty: String, growth_wait: float = 1.0) -> void:
	attack_wait_multiplier = float(DATA.ATTACK_WAIT_MULTIPLIER.get(difficulty,1.0))*growth_wait

func wait_time(duration: float) -> float:
	return maxf(0.5 if duration >= 0.8 else 0.12,duration*attack_wait_multiplier)

func reset_for_battle(enabled: bool) -> void:
	combat_enabled = enabled
	visible = enabled
	state = "entry" if enabled else "inactive"
	elapsed = 0.0
	visual.modulate = Color.WHITE
	effects.clear_effects()
	melee_effects.clear_effects()
	if enabled:
		position = Vector2(DATA.HOME_X+DATA.ENTRY_OFFSET_X,-20.0)
		phase_start = position
		phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y)
	if enabled: _set_pose("lift",3)
	else: _set_pose("slash",0)

func advance_intro(delta: float, target: Vector2) -> void:
	if state == "entry": advance(delta,target)
	else:
		_set_pose("slash",0)
		effects.advance_effects(delta,true,"entry_recover",visual,pose_meta,pose_sheet,pose_frame)

func finish_intro() -> void:
	combat_enabled = true
	_set_pose("slash",0)
	_enter("ground_prepare")

func set_combat_enabled(enabled: bool) -> void:
	combat_enabled = enabled
	if not enabled:
		effects.clear_effects()
		melee_effects.clear_effects()

func _set_pose(sheet: String, frame: int) -> void:
	if frames.is_empty(): return
	pose_sheet = sheet
	pose_frame = clampi(frame,0,frames[sheet].size()-1)
	pose_meta = frames[sheet][pose_frame]
	visual.texture = frame_textures[sheet][pose_frame]
	visual.region_enabled = false
	visual.region_filter_clip_enabled = true
	# Each repacked sheet has its own source resolution; hold scale across its poses.
	var reference: Dictionary = frames[sheet][0]
	var reference_height: float = maxf(32.0,float(reference.bottom)-float(reference.top))
	# Calibrate fixed helmet width per sheet; weapon/leg pose cannot change body size.
	scale_factor = DATA.HELMET_WORLD_WIDTH/float(DATA.HELMET_SOURCE_WIDTH[sheet])
	source_unit = reference_height/float(ORIGINAL_BODY_HEIGHT[sheet])
	visual.scale = Vector2.ONE*scale_factor
	visual.flip_h = false
	visual.flip_v = false
	visual.rotation = 0.0
	var anchor_x: float = float(pose_meta.bx) if sheet == "death" else float(pose_meta.cx)+20.0*source_unit
	visual.position = -Vector2(anchor_x,float(pose_meta.bottom))*scale_factor
	if state in ["stab_prepare","stab","stab_recover"]:
		var direction: Vector2 = stab_direction
		var angle := clampf(angle_difference(PI,direction.angle()),-1.1,0.5)
		if state == "stab_recover": angle *= 1.0-smoothstep(0.0,1.0,minf(1.0,elapsed/DATA.STAB_RECOVERY))
		# Rotate around the chest, never around the sheet's top-left corner.
		var pivot := Vector2(pose_meta.cx,pose_meta.cy)
		var pivot_position := visual.position+pivot*scale_factor
		visual.rotation = angle
		visual.position = pivot_position-(pivot*scale_factor).rotated(angle)

func _frame(sequence: Array, duration: float) -> int:
	return int(sequence[clampi(int(elapsed/maxf(duration,0.001)*sequence.size()),0,sequence.size()-1)])

func _windup_frame(sequence: Array, duration: float) -> int:
	var animation_time: float = maxf(0.0,elapsed-(duration-DATA.MELEE_WINDUP_ANIMATION))
	return int(sequence[clampi(int(animation_time/DATA.MELEE_WINDUP_ANIMATION*sequence.size()),0,sequence.size()-1)])

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
		"stab_prepare":
			stab_direction = (player_target-core_position()).normalized()
			if stab_direction.x > -0.2: stab_direction = Vector2(-0.2,stab_direction.y).normalized()
		"stab":
			phase_goal = position+stab_direction*DATA.STAB_DISTANCE
			phase_goal.x = maxf(130.0,phase_goal.x)
			phase_goal.y = minf(GD.GROUND_Y-4.0,phase_goal.y)
		"air_return": phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y-DATA.HOVER_HEIGHT)
		"land": phase_goal = Vector2(DATA.HOME_X,GD.GROUND_Y)

func advance(delta: float, target: Vector2 = Vector2(GD.PLAYER_X,GD.GROUND_Y-46)) -> void:
	player_target = target
	if state == "dead":
		death_time += delta
		_set_pose("death",mini(7,int(death_time*DATA.DEATH_FPS)))
		return
	if not combat_enabled: return
	previous_position = position
	elapsed += delta
	match state:
		"entry":
			var descent: float = clampf(elapsed/DATA.ENTRY_TIME,0.0,1.0)
			position = phase_start.lerp(phase_goal,descent*descent)
			_set_pose("lift",4+mini(2,int(descent*3.0)))
			if descent >= 1.0:
				position = phase_goal
				effects.landing_burst()
				_enter("entry_recover")
		"entry_recover":
			_set_pose("slash",0)
			if elapsed >= DATA.ENTRY_RECOVERY: _enter("ground_prepare")
		"ground_prepare":
			_set_pose("slash",0)
			if elapsed >= wait_time(DATA.PREPARE): _enter("ground_fire")
		"ground_fire":
			_set_pose("ground_fire",_frame(DATA.GROUND_FIRE_FRAMES,DATA.GROUND_FIRE_TIME))
			_fire_burst(delta,false)
			if elapsed >= DATA.GROUND_FIRE_TIME: _enter("ground_recover")
		"ground_recover":
			_set_pose("slash",0)
			if elapsed >= wait_time(DATA.RECOVERY): _enter("slash_prepare")
		"slash_prepare":
			_set_pose("slash",_windup_frame(DATA.SLASH_READY,wait_time(DATA.SLASH_PREPARE)))
			if elapsed >= wait_time(DATA.SLASH_PREPARE): _enter("slash")
		"slash":
			_set_pose("slash",DATA.SLASH_CHARGE_FRAME)
			position = position.move_toward(phase_goal,DATA.CHARGE_SPEED*delta)
			if elapsed >= DATA.SLASH_TIME: _enter("slash_recover")
		"slash_recover":
			_set_pose("slash",_frame(DATA.SLASH_RECOVER,wait_time(DATA.RECOVERY)))
			if elapsed >= wait_time(DATA.RECOVERY): _enter("retreat")
		"retreat":
			_set_pose("slash",0)
			position = position.move_toward(phase_goal,DATA.GROUND_RETREAT_SPEED*delta)
			if position.distance_to(phase_goal) < 1: _enter("takeoff_wait")
		"takeoff_wait":
			_set_pose("slash",0)
			if elapsed >= wait_time(DATA.RECOVERY): _enter("takeoff")
		"takeoff":
			var index := mini(3,int(elapsed/DATA.TAKEOFF_TIME*4.0))
			if index == 0: _set_pose("slash",0)
			else: _set_pose("lift",index)
			position = phase_start.lerp(phase_goal,smoothstep(0.0,1.0,minf(1.0,elapsed/DATA.TAKEOFF_TIME)))
			if elapsed >= DATA.TAKEOFF_TIME: _enter("air_prepare")
		"air_prepare":
			_set_pose("lift",3)
			if elapsed >= wait_time(DATA.AIR_PREPARE): _enter("air_fire")
		"air_fire":
			_set_pose("air_fire",mini(7,int(elapsed/DATA.AIR_FIRE_TIME*8.0)))
			_fire_burst(delta,true)
			if elapsed >= DATA.AIR_FIRE_TIME: _enter("air_recover")
		"air_recover":
			_set_pose("lift",3)
			if elapsed >= wait_time(DATA.RECOVERY): _enter("stab_prepare")
		"stab_prepare":
			_set_pose("stab",_windup_frame(DATA.STAB_READY,wait_time(DATA.STAB_PREPARE)))
			if elapsed >= wait_time(DATA.STAB_PREPARE): _enter("stab")
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
			if elapsed >= DATA.LAND_TIME:
				effects.landing_burst()
				_enter("land_recover")
		"land_recover":
			_set_pose("slash",0)
			if elapsed >= wait_time(DATA.LAND_RECOVERY): _enter("ground_prepare")

	effects.advance_effects(delta,combat_enabled,state,visual,pose_meta,pose_sheet,pose_frame)
	melee_effects.advance_effects(delta,self)

func _muzzle(_air: bool) -> Vector2:
	# Source-space barrel tip; no flame included, same transformed pose as artwork.
	var source := Vector2(float(pose_meta.mx),float(pose_meta.my))
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

func _core_local(point: Vector2) -> Vector2:
	return (visual.to_local(point)-Vector2(float(pose_meta.cx),float(pose_meta.cy)))*scale_factor

func _core_hit(from: Vector2, to: Vector2) -> bool:
	# A chest-sized box, checked before opaque body pixels, following pose rotation.
	if pose_meta.is_empty(): return false
	return _segment_rect(_core_local(from),_core_local(to),DATA.CORE_HIT_RECT)

func _body_pixel(local: Vector2) -> bool:
	var x := int(local.x)
	var y := int(local.y)
	if x < int(DATA.ATLAS_INSET) or y < int(DATA.ATLAS_INSET) or x >= int(pose_meta.w-DATA.ATLAS_INSET) or y >= int(pose_meta.h-DATA.ATLAS_INSET): return false
	# Exclude the gun/sword beyond the actual torso/limbs envelope.
	if x < float(pose_meta.cx)-65.0*source_unit and y < float(pose_meta.cy)+48.0*source_unit: return false
	if x > float(pose_meta.cx)+175.0*source_unit or y < float(pose_meta.top): return false
	var pixel: Color = images[pose_sheet].get_pixel(int(pose_meta.x)+x,int(pose_meta.y)+y)
	if pixel.a < 0.85: return false
	# Red blade/energy glow and orange gun flash never count as body armor.
	if pixel.r > 0.4 and pixel.r > pixel.g*1.7 and pixel.r > pixel.b*1.7: return false
	if pixel.r > 0.8 and pixel.g > 0.8 and pixel.b > 0.8:
		for offset in [-4,-2,2,4]:
			var sample_y: int = int(pose_meta.y)+y+int(round(float(offset)*source_unit))
			if sample_y < 0 or sample_y >= images[pose_sheet].get_height(): continue
			var neighbor: Color = images[pose_sheet].get_pixel(int(pose_meta.x)+x,sample_y)
			if neighbor.a > 0.5 and neighbor.r > 0.6 and neighbor.g < 0.3 and neighbor.b < 0.3: return false
	return true

func shot_contact(from: Vector2, to: Vector2) -> Dictionary:
	if not combat_enabled or state in ["entry","entry_recover","dead","inactive"]: return {}
	var a: Vector2 = visual.to_local(from)
	var b: Vector2 = visual.to_local(to)
	var steps: int = maxi(1,int(ceil(a.distance_to(b))))
	# Walk from the incoming side, not the end of this physics tick or actor origin.
	for index in range(steps+1):
		var local: Vector2 = a.lerp(b,float(index)/float(steps))
		if _body_pixel(local):
			return {"position":visual.to_global(local)}
	# Retain the authored chest hitbox if a shot crosses a transparent chest gap.
	if _core_hit(from,to):
		for index in range(steps+1):
			var local: Vector2 = a.lerp(b,float(index)/float(steps))
			var chest: Vector2 = (local-Vector2(float(pose_meta.cx),float(pose_meta.cy)))*scale_factor
			if DATA.CORE_HIT_RECT.has_point(chest): return {"position":visual.to_global(local)}
	return {}

func shot_hits(from: Vector2, to: Vector2) -> bool:
	return not shot_contact(from,to).is_empty()

func receive_shot_segment(penetration: int, from: Vector2, to: Vector2) -> void:
	var contact: Dictionary = shot_contact(from,to)
	if contact.is_empty(): return
	var origin: Vector2 = contact.position
	var required: int = DATA.CORE_PENETRATION if _core_hit(from,to) else DATA.BODY_PENETRATION
	if penetration < required:
		sound_requested.emit("armor_ricochet")
		feedback.emit(origin,Color.WHITE,"RICOCHET")
		return
	damage_requested.emit(origin)

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
	if state == "stab":
		var blade_start := core_position()
		var blade_end := blade_start+stab_direction*DATA.STAB_HIT_LENGTH
		var stab_movement := global_position-previous_position
		for candidate in [player_rect,guard_rect]:
			var rect: Rect2 = candidate
			if not rect.has_area(): continue
			var expanded: Rect2 = rect.grow(DATA.STAB_HIT_RADIUS)
			if _segment_rect(blade_start,blade_end,expanded) or _segment_rect(blade_start-stab_movement,blade_end-stab_movement,expanded) or _segment_rect(blade_end-stab_movement,blade_end,expanded):
				action_contact_used = true
				return true
		return false
	var area := _blade_rect()
	# Include swept travel so fast lunges cannot skip player contact.
	var movement := global_position-previous_position
	area = area.merge(Rect2(area.position-movement,area.size))
	if area.intersects(player_rect) or (guard_rect.has_area() and area.intersects(guard_rect)):
		action_contact_used = true
		return true
	return false

func _segment_rect(from: Vector2, to: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from) or rect.has_point(to): return true
	var corners := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(from,to,corners[index],corners[(index+1)%4]) != null: return true
	return false

func start_death() -> void:
	combat_enabled = false
	state = "dead"
	death_time = 0.0
	effects.clear_effects()
	melee_effects.clear_effects()
	position.y = GD.GROUND_Y
	_set_pose("death",0)
	set_process(true)

func _process(delta: float) -> void:
	if state == "dead": advance(delta)
