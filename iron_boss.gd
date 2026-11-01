class_name IronBastion
extends Node2D
signal damage_requested(origin: Vector2)
signal sound_requested(cue: String)
signal reinforcement_requested(kind: String, origin: Vector2)
signal feedback(origin: Vector2, color: Color, message: String)
const DATA := preload("res://iron_boss_data.gd")
const GD := preload("res://game_data.gd")
const PIXEL_FRAMES := preload("res://iron_boss_frames.gd").FRAMES
const VFX := preload("res://assets/vfx/neon_effects_source.png")
const ART := {
 "hull":preload("res://assets/boss_iron/reverse_spaced_pixel.png"),
 "cannon":preload("res://assets/boss_iron/cannon_spaced_pixel.png"),
 "cannon_dead":preload("res://assets/boss_iron/cannon_death.png"),
 "launcher":preload("res://assets/boss_iron/launcher_fire_clean.png"),
 "launcher_dead":preload("res://assets/boss_iron/launcher_death.png"),
 "plate":preload("res://assets/boss_iron/plate.png")}
var hull: Sprite2D
var cannon: Sprite2D
var launcher: Sprite2D
var plate: Sprite2D
var images: Dictionary = {}
var combat_enabled := false
var state := "inactive"
var elapsed := 0.0
var cannon_hp := DATA.CANNON_HP
var launcher_hp := DATA.LAUNCHER_HP
var plate_hp := DATA.PLATE_HP
var cannon_death := -1.0
var launcher_death := -1.0
var wait_multiplier := 1.0
var attack := "cannon"
var emitted := 0
var cannon_frame := 0
var hull_frame := 0
var track_time := 0.0
var hull_textures: Array[Texture2D] = []
var cannon_textures: Array[Texture2D] = []
var target_x := 190.0
var projectiles: Array[Dictionary] = []
var foreground_hitboxes: Array[Rect2] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	var vfx_material := ShaderMaterial.new()
	vfx_material.shader = preload("res://assets/vfx/black_key.gdshader")
	material = vfx_material
	for key in ART:
		var image: Image = ART[key].get_image()
		if image.is_compressed(): image.decompress()
		images[key] = image
	for metadata in PIXEL_FRAMES.hull: hull_textures.append(_atlas(ART.hull,metadata))
	for metadata in PIXEL_FRAMES.cannon: cannon_textures.append(_atlas(ART.cannon,metadata))
	hull = _sprite(ART.hull,Vector2.ZERO,Vector2.ONE*DATA.HULL_ANIM_SCALE)
	cannon = _sprite(ART.cannon,DATA.CANNON_MOUNT,Vector2.ONE*DATA.CANNON_SCALE)
	launcher = _sprite(ART.launcher,DATA.LAUNCHER_MOUNT,Vector2.ONE*DATA.LAUNCHER_SCALE)
	plate = _sprite(ART.plate,DATA.PLATE_MOUNT,Vector2.ONE*DATA.PLATE_SCALE)
	cannon.z_index = -1 # Behind the hull, with its mounting foot seated on the roof.
	hull.z_index = 0
	launcher.z_index = 1
	plate.z_index = 2
	for sprite in [hull,cannon]:
		var pixel_material := ShaderMaterial.new()
		pixel_material.shader = preload("res://assets/boss_iron/pixel_sample.gdshader")
		pixel_material.set_shader_parameter("pixel_step",1.0 if sprite == hull else 4.0)
		sprite.material = pixel_material
	reset_for_battle(false)

func _atlas(texture: Texture2D, metadata: Dictionary) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(metadata.x,metadata.y,metadata.w,metadata.h)
	atlas.filter_clip = true
	return atlas

func _animate_hull(delta: float) -> void:
	track_time += delta
	hull_frame = int(track_time*DATA.REVERSE_FPS)%8
	var metadata: Dictionary = PIXEL_FRAMES.hull[hull_frame]
	hull.texture = hull_textures[hull_frame]
	hull.position = -Vector2(float(metadata.anchor_x),float(metadata.bottom))*DATA.HULL_ANIM_SCALE

func _sprite(texture: Texture2D, origin: Vector2, sizing: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = texture
	sprite.position = origin
	sprite.scale = sizing
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	return sprite

func _pose(sprite: Sprite2D, key: String, frame: int, mount: Vector2) -> void:
	if key == "cannon":
		cannon_frame = frame
		var metadata: Dictionary = PIXEL_FRAMES.cannon[frame]
		sprite.texture = cannon_textures[frame]
		sprite.scale = Vector2.ONE*DATA.CANNON_ANIM_SCALE
		sprite.position = mount-Vector2(float(metadata.anchor_x),float(metadata.bottom))*sprite.scale
		(sprite.material as ShaderMaterial).set_shader_parameter("pixel_step",4.0)
		return
	if key == "cannon_dead":
		sprite.scale = Vector2.ONE*DATA.CANNON_SCALE
		(sprite.material as ShaderMaterial).set_shader_parameter("pixel_step",6.0)
	var columns: int = 4 if key == "plate" else 2
	var width: int = 384 if columns == 4 else 768
	var source_origin := Vector2((frame%columns)*width,int(frame/columns)*512)
	var atlas := AtlasTexture.new()
	atlas.atlas = ART[key]
	# Detached missiles were removed; this module now deploys air support.
	var inset: float = 0.0
	atlas.region = Rect2(source_origin+Vector2(inset,0),Vector2(width-inset,512))
	atlas.margin = Rect2(Vector2(inset,0),Vector2(inset,0))
	atlas.filter_clip = true
	sprite.texture = atlas
	var anchor := Vector2(445,500)
	if key.begins_with("launcher"): anchor = Vector2(480,467)
	if key == "plate": anchor = Vector2(225,495)
	if key == "cannon" and frame >= 2: anchor = Vector2(480 if frame == 2 else 450,495)
	sprite.position = mount-anchor*sprite.scale

func set_difficulty(difficulty: String, growth_wait: float = 1.0) -> void:
	wait_multiplier = float(DATA.ATTACK_WAIT.get(difficulty,1.0))*growth_wait

func reset_for_battle(enabled: bool) -> void:
	combat_enabled = enabled
	visible = enabled
	state = "entry" if enabled else "inactive"
	elapsed = 0.0
	cannon_hp = DATA.CANNON_HP
	launcher_hp = 0
	plate_hp = 0
	cannon_death = -1.0
	launcher_death = -1.0
	attack = "cannon"
	emitted = 0
	hull.modulate = Color.WHITE
	track_time = 0.0
	_animate_hull(0.0)
	clear_projectiles()
	position = Vector2(GD.VIEW_SIZE.x+200.0,GD.GROUND_Y)
	_pose(cannon,"cannon",0,DATA.CANNON_MOUNT)
	_pose(launcher,"launcher",0,DATA.LAUNCHER_MOUNT)
	launcher.hide()
	plate.hide()
	foreground_hitboxes.clear()
	set_process(false)

func set_combat_enabled(enabled: bool) -> void:
	combat_enabled = enabled
	if not enabled: clear_projectiles()

func finish_intro() -> void:
	combat_enabled = true
	_enter("prepare")

func advance_intro(delta: float, target: Vector2) -> void:
	if state == "entry": advance(delta,target)
	else: _animate_hull(delta)

func _enter(next: String) -> void:
	state = next
	elapsed = 0.0
	emitted = 0
	if next == "prepare":
		if attack == "cannon" and cannon_hp <= 0: attack = "deploy"

func advance(delta: float, target: Vector2) -> void:
	if not combat_enabled: return
	elapsed += delta
	_animate_hull(delta)
	_update_wrecks(delta)
	_advance_projectiles(delta)
	match state:
		"entry":
			position = position.move_toward(Vector2(DATA.HOME_X,GD.GROUND_Y),DATA.ENTRY_SPEED*delta)
			if position.x <= DATA.HOME_X+1.0: _enter("intro_hold")
		"prepare":
			if elapsed >= maxf(0.65,DATA.PREPARE*wait_multiplier):
				target_x = clampf(target.x+rng.randf_range(-65,65),90,350)
				_enter("fire")
		"fire":
			if attack == "cannon" and cannon_hp > 0:
				_pose(cannon,"cannon",mini(3,int(elapsed/DATA.FIRE_TIME*4.0)),DATA.CANNON_MOUNT)
				if emitted == 0 and elapsed >= DATA.FIRE_TIME*0.25:
					_shell()
					emitted = 1
			elif attack == "deploy":
				if emitted < DATA.DEPLOY_ROSTER.size() and elapsed >= emitted*DATA.DEPLOY_INTERVAL:
					_deploy(emitted)
					emitted += 1
			var duration: float = DATA.FIRE_TIME if attack == "cannon" else DATA.DEPLOY_ROSTER.size()*DATA.DEPLOY_INTERVAL+0.25
			if elapsed >= duration:
				if cannon_hp > 0: _pose(cannon,"cannon",0,DATA.CANNON_MOUNT)
				_enter("recover")
		"recover":
			if elapsed >= maxf(0.3,DATA.RECOVERY*wait_multiplier):
				attack = "deploy" if attack == "cannon" else "cannon"
				_enter("prepare")
	queue_redraw()

func _shell() -> void:
	var muzzles := [Vector2(295,235),Vector2(285,232),Vector2(295,200),Vector2(252,195)]
	var source: Vector2 = muzzles[cannon_frame]
	var origin: Vector2 = cannon.to_global(source)
	# Solve speed for the authored left/up barrel angle and the locked landing point.
	var angle: float = deg_to_rad(DATA.CANNON_ANGLE)
	var dx: float = maxf(100.0,origin.x-target_x)
	var dy: float = GD.GROUND_Y-origin.y
	var speed: float = sqrt(DATA.SHELL_GRAVITY*dx*dx/maxf(1.0,2.0*cos(angle)*cos(angle)*(dy+dx*tan(angle))))
	var velocity := Vector2(-cos(angle),-sin(angle))*speed
	projectiles.append({"kind":"shell","p":origin,"previous":origin,"v":velocity,"life":5.0,"target":target_x,"explode":0.0,"spent":false})
	sound_requested.emit("iron_cannon_fire")

func _deploy(index: int) -> void:
	var origin: Vector2 = to_global(DATA.DEPLOY_ORIGIN+Vector2(index*16.0,0))
	reinforcement_requested.emit(DATA.DEPLOY_ROSTER[index],origin)

func _advance_projectiles(delta: float) -> void:
	for index in range(projectiles.size()-1,-1,-1):
		var round: Dictionary = projectiles[index]
		round.life = float(round.life)-delta
		if float(round.explode) > 0:
			round.explode = float(round.explode)-delta
			if float(round.explode) <= 0: projectiles.remove_at(index)
			continue
		round.previous = round.p
		if round.kind == "shell": round.v = Vector2(round.v)+Vector2(0,DATA.SHELL_GRAVITY)*delta
		round.p = Vector2(round.p)+Vector2(round.v)*delta
		if Vector2(round.p).y >= GD.GROUND_Y:
			round.p = Vector2(Vector2(round.p).x,GD.GROUND_Y)
			round.explode = DATA.EXPLOSION_TIME
			sound_requested.emit("boss_bomb_explode")
		if float(round.life) <= 0 or Vector2(round.p).x < -120: projectiles.remove_at(index)

func try_melee(player_rect: Rect2, guard_rect: Rect2) -> bool:
	if not combat_enabled: return false
	for round in projectiles:
		if bool(round.spent): continue
		var radius: float = DATA.EXPLOSION_RADIUS if float(round.explode) > 0 else DATA.SHELL_RADIUS
		for candidate in [guard_rect,player_rect]:
			var rect: Rect2 = candidate
			if not rect.has_area(): continue
			if _segment_rect(Vector2(round.previous),Vector2(round.p),rect.grow(radius)):
				round.spent = true
				round.explode = DATA.EXPLOSION_TIME
				return true
	return false

func _segment_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	if rect.has_point(a) or rect.has_point(b): return true
	var points := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(a,b,points[index],points[(index+1)%4]) != null: return true
	return false

func _pixel_hit(sprite: Sprite2D, key: String, point: Vector2, exclude_flash: bool = true) -> bool:
	var atlas: AtlasTexture = sprite.texture as AtlasTexture
	if atlas == null: return false
	var local: Vector2 = sprite.to_local(point)
	var source: Vector2 = local+atlas.region.position-atlas.margin.position
	if not atlas.region.has_point(source): return false
	var image: Image = images[key]
	var pixel: Color = image.get_pixel(int(source.x),int(source.y))
	return pixel.a > 0.9 and (not exclude_flash or not (pixel.r > pixel.g*1.6 and pixel.g > pixel.b*1.8))

func shot_contact(from: Vector2, to: Vector2) -> Dictionary:
	if not combat_enabled or state in ["entry","intro_hold","dead","inactive"]: return {}
	# Foreground flyers take priority over the large background fortress along this aim.
	var direction: Vector2 = (to-from).normalized()
	if not direction.is_zero_approx():
		for box in foreground_hitboxes:
			if _segment_rect(from,from+direction*1400.0,box): return {}
	var steps: int = maxi(1,int(ceil(from.distance_to(to)*2.0)))
	for index in range(steps+1):
		var p: Vector2 = from.lerp(to,float(index)/float(steps))
		var local: Vector2 = to_local(p)
		# Flying enemies are drawn in front and own these overlapping shot regions.
		var foreground := false
		for box in foreground_hitboxes:
			if box.has_point(p):
				foreground = true
				break
		if foreground: continue
		var core_rect: Rect2 = Rect2(to_local(core_position())-DATA.CORE_RECT.size*0.5,DATA.CORE_RECT.size)
		if core_rect.has_point(local): return {"position":p,"module":"core"}
		if cannon_hp > 0 and _pixel_hit(cannon,"cannon",p): return {"position":p,"module":"cannon"}
		# Restrict hull collision to opaque artwork instead of its broad rectangular bounds.
		var core_lane: bool = local.y >= core_rect.position.y and local.y <= core_rect.end.y and local.x <= core_rect.end.x
		if not core_lane and _pixel_hit(hull,"hull",p,false): return {"position":p,"module":"body"}
	return {}

func shot_hits(from: Vector2, to: Vector2) -> bool:
	return not shot_contact(from,to).is_empty()

func required_penetration(from: Vector2, to: Vector2) -> int:
	var contact: Dictionary = shot_contact(from,to)
	return DATA.CORE_ARMOR if contact.get("module","") == "core" else DATA.ARMOR

func receive_shot_segment(penetration: int, from: Vector2, to: Vector2) -> void:
	var contact: Dictionary = shot_contact(from,to)
	if contact.is_empty(): return
	var origin: Vector2 = contact.position
	var module: String = contact.module
	var required: int = DATA.CORE_ARMOR if module == "core" else DATA.ARMOR
	if penetration < required or module == "body":
		sound_requested.emit("armor_ricochet")
		feedback.emit(origin,Color.WHITE,"RICOCHET")
		return
	match module:
		"core": damage_requested.emit(origin)
		"cannon":
			cannon_hp -= 1
			if cannon_hp == 0:
				cannon_death = 0.0
				sound_requested.emit("enemy_explode")
	if module == "cannon": feedback.emit(origin,Color("ffb347"),"")

func _update_plate() -> void:
	var frame: int = clampi(int((1.0-float(plate_hp)/DATA.PLATE_HP)*7.0),0,7)
	_pose(plate,"plate",frame,DATA.PLATE_MOUNT)

func _update_wrecks(delta: float) -> void:
	if cannon_death >= 0:
		cannon_death += delta
		_pose(cannon,"cannon_dead",mini(3,int(cannon_death*DATA.DEATH_FPS)),DATA.CANNON_MOUNT)
	if launcher_death >= 0:
		launcher_death += delta
		_pose(launcher,"launcher_dead",mini(3,int(launcher_death*DATA.DEATH_FPS)),DATA.LAUNCHER_MOUNT)

func intro_focus_position() -> Vector2:
	return to_global(DATA.INTRO_FOCUS)

func core_position() -> Vector2:
	var metadata: Dictionary = PIXEL_FRAMES.hull[hull_frame]
	return hull.to_global(Vector2(float(metadata.core_x),float(metadata.core_y)))

func clear_projectiles() -> void:
	projectiles.clear()
	queue_redraw()

func start_death() -> void:
	combat_enabled = false
	state = "dead"
	clear_projectiles()
	cannon_hp = 0
	launcher_hp = 0
	plate_hp = 0
	cannon_death = maxf(0.0,cannon_death)
	launcher_death = maxf(0.0,launcher_death)
	elapsed = 0.0
	set_process(true)

func _process(delta: float) -> void:
	if state != "dead": return
	elapsed += delta
	_update_wrecks(delta)
	hull.modulate = Color(0.45,0.45,0.45)

func _draw() -> void:
	if combat_enabled and state == "prepare" and attack == "cannon" and cannon_hp > 0:
		draw_circle(to_local(cannon.to_global(Vector2(300,250))),9.0+sin(elapsed*14.0)*2.0,Color(1,0.2,0.05,0.8))
	for round in projectiles:
		var p: Vector2 = to_local(Vector2(round.p))
		if float(round.explode) > 0:
			var progress: float = 1.0-float(round.explode)/DATA.EXPLOSION_TIME
			var frames := [Rect2(28,650,100,90),Rect2(133,650,72,90),Rect2(210,660,60,75),Rect2(276,670,48,60)]
			var frame: int = clampi(int(progress*frames.size()),0,frames.size()-1)
			draw_texture_rect_region(VFX,Rect2(p-Vector2(40,40),Vector2(80,80)),frames[frame])
			continue
		var direction: Vector2 = Vector2(round.v).normalized()
		draw_set_transform(p,direction.angle()-PI)
		draw_texture_rect_region(VFX,Rect2(-16,-12,32,24),Rect2(28,40,95,68))
		draw_set_transform(Vector2.ZERO,0.0)
		var landing := Vector2(float(round.target)-global_position.x,GD.GROUND_Y-global_position.y)
		draw_line(landing-Vector2(25,0),landing+Vector2(25,0),Color(1,0.15,0.07,0.8),3)
