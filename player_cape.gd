extends Node2D

# Visual-only ribbon cloth. Global simulation points retain inertia when the
# player moves; the renderer snaps back to the logical pixel grid.
const SHEET := preload("res://assets/player/cape_red_ivory_atlas.png")
const GD := preload("res://game_data.gd")
const LINKS := 12
const LINK_LENGTH := 6.5
const STEP := 1.0/60.0
var actor: Node2D
var points: Array[Vector2] = []
var previous: Array[Vector2] = []
var outer := Polygon2D.new()
var clock := 0.0
var accumulator := 0.0
var initialized := false
var previous_state := ""
var last_anchor := Vector2.ZERO
var anchor_velocity := Vector2.ZERO
var movement_acceleration := Vector2.ZERO

func _ready() -> void:
	z_index = 1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	outer.texture = SHEET
	outer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(outer)
	_configure_mesh(outer,Rect2(40,140,1210,490))

func _configure_mesh(mesh: Polygon2D, region: Rect2) -> void:
	var uv := PackedVector2Array()
	var faces: Array[PackedInt32Array] = []
	for index in range(LINKS+1):
		var t := float(index)/float(LINKS)
		uv.append(region.position+Vector2(t*region.size.x,0))
		uv.append(region.position+Vector2(t*region.size.x,region.size.y))
		if index < LINKS:
			faces.append(PackedInt32Array([index*2,index*2+1,index*2+3]))
			faces.append(PackedInt32Array([index*2,index*2+3,index*2+2]))
	var initial := PackedVector2Array()
	initial.resize((LINKS+1)*2)
	mesh.polygon = initial
	mesh.uv = uv
	mesh.polygons = faces

func _anchor() -> Vector2:
	var socket: Vector2 = actor.back_pivot.position
	if actor.body_state == "death":
		var t := clampf(float(actor.body_time)/maxf(0.01,actor.death_animation_duration()),0.0,1.0)
		socket = socket.lerp(Vector2(-18,-12),t)
	return get_parent().to_global(socket+Vector2(-12,-6))

func _reset_strip(anchor: Vector2) -> void:
	points.clear()
	previous.clear()
	for index in range(LINKS+1):
		var point := anchor+Vector2(-float(index)*LINK_LENGTH,float(index)*1.5)
		points.append(point)
		previous.append(point)
	last_anchor = anchor
	anchor_velocity = Vector2.ZERO
	movement_acceleration = Vector2.ZERO
	initialized = true

func _process(delta: float) -> void:
	if not is_instance_valid(actor): return
	if not actor.is_visible_in_tree():
		initialized = false
		return
	var game := actor.get_parent()
	if "ui_paused" in game and game.ui_paused: return
	var anchor := _anchor()
	if not initialized or anchor.distance_to(points[0]) > 180.0 or (previous_state == "death" and actor.body_state != "death"):
		_reset_strip(anchor)
	else:
		# Carry the entire strip with root motion before solving relative flutter.
		# Fast jumps/frame socket changes must not stretch or crush its mesh.
		var shift := anchor-last_anchor
		for index in range(points.size()):
			points[index] += shift
			previous[index] += shift
		var velocity := (shift/maxf(delta,0.001)).limit_length(500.0)
		movement_acceleration = ((velocity-anchor_velocity)/maxf(delta,0.001)).limit_length(1200.0)
		anchor_velocity = velocity
		last_anchor = anchor
	previous_state = actor.body_state
	clock += minf(delta,0.066)
	accumulator = minf(accumulator+delta,STEP*4.0)
	while accumulator >= STEP:
		_simulate(anchor)
		accumulator -= STEP
	_draw_strip()
func _simulate(anchor: Vector2) -> void:
	var dead: bool = actor.body_state == "death"
	var running: bool = actor.body_state in ["run","slide","jump"]
	var wind := -35.0 if running and not dead else -8.0
	var floor_y := _track_floor_y()-2.0
	points[0] = anchor
	previous[0] = anchor
	var rest_target := anchor
	for index in range(1,LINKS+1):
		var old: Vector2 = points[index]
		var inertia: Vector2 = (points[index]-previous[index])*(0.9 if dead else 0.962)
		var t := float(index)/float(LINKS)
		var flutter := (sin(clock*8.5-float(index)*0.6)*180.0+sin(clock*14.0-float(index)*0.8)*55.0)*t*t if not dead else 0.0
		var acceleration := Vector2(wind,(250.0 if dead else 85.0)+flutter)
		if not dead: acceleration -= movement_acceleration*0.18*t
		if not dead:
			# Traveling bends retain link lengths instead of pulling into a flat line.
			# The root stays braced; amplitude grows toward the trailing edge.
			var envelope := pow(t,1.25)*(1.0 if running else 0.45)
			var bend := (sin(clock*8.5-float(index)*0.52)*0.85+sin(clock*3.7-float(index)*0.3)*0.18)*envelope
			rest_target += Vector2(-cos(bend),sin(bend))*LINK_LENGTH
			acceleration += (rest_target-points[index])*lerpf(85.0,65.0,t)
		points[index] += inertia+acceleration*STEP*STEP
		previous[index] = old
	for iteration in range(10):
		points[0] = anchor
		for index in range(LINKS):
			var offset: Vector2 = points[index+1]-points[index]
			var length := maxf(offset.length(),0.001)
			var correction: Vector2 = offset*(1.0-LINK_LENGTH/length)
			if index == 0:
				points[index+1] -= correction
			else:
				points[index] += correction*0.5
				points[index+1] -= correction*0.5
		if not dead:
			# Two-link chord constraints prevent sharp accordion folds.
			for index in range(LINKS-1):
				var chord: Vector2 = points[index+2]-points[index]
				var minimum := LINK_LENGTH*lerpf(1.85,1.65,float(index)/float(LINKS))
				if chord.length() < minimum:
					var direction := chord.normalized() if chord.length_squared() > 0.001 else Vector2.LEFT
					var push := direction*(minimum-chord.length())
					if index == 0: points[index+2] += push
					else:
						points[index] -= push*0.5
						points[index+2] += push*0.5
			points[1] = anchor+Vector2(-LINK_LENGTH,0.7)
		for index in range(1,LINKS+1):
			# Keep the cloth behind the torso and above the track.
			if not dead:
				points[index].x = minf(points[index].x,points[index-1].x-LINK_LENGTH*0.5)
				points[index] = _outside_shoulder(points[index])
			points[index].y = minf(points[index].y,floor_y)

func _track_floor_y() -> float:
	# Fixed world track, never the airborne player's feet.
	return actor.get_parent().to_global(Vector2(0,GD.GROUND_Y)).y

func _outside_shoulder(point: Vector2) -> Vector2:
	if actor.body_state == "death": return point
	var center: Vector2 = get_parent().to_global(actor.back_pivot.position+Vector2(-2,-8))
	var radius := Vector2(8,10)
	var relative: Vector2 = (point-center)/radius
	if relative.length_squared() >= 1.0: return point
	# Keep folded cloth on the rear half of the shoulder, not through the chest.
	var y := clampf(relative.y,-0.99,0.99)
	return Vector2(center.x-radius.x*sqrt(maxf(0.0,1.0-y*y))-1.0,point.y)

func _draw_strip() -> void:
	var red_vertices := PackedVector2Array()
	var colors := PackedColorArray()
	for index in range(LINKS+1):
		var t := float(index)/float(LINKS)
		var before: Vector2 = points[maxi(0,index-1)]
		var after: Vector2 = points[mini(LINKS,index+1)]
		var tangent := (after-before).normalized()
		# Stable downward-facing width axis; never swap UV edges at a sharp bend.
		var normal := Vector2(clampf(tangent.y,-0.45,0.45),maxf(0.75,-tangent.x)).normalized()
		var half_width := lerpf(4.0,17.0,sin(t*PI*0.5))
		if actor.body_state == "slide": half_width *= 0.8
		for side in [-1.0,1.0]:
			var world_point: Vector2 = points[index]+normal*half_width*side
			if index > 0: world_point = _outside_shoulder(world_point)
			world_point.y = minf(world_point.y,_track_floor_y()-1.0)
			red_vertices.append(to_local(world_point.round()))
			var shade := 0.88 if side < 0 else 1.0
			colors.append(Color(shade,shade,shade,1.0))
	outer.polygon = red_vertices
	outer.vertex_colors = colors

