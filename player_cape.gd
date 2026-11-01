extends Node2D

# Visual-only ribbon cloth. Global simulation points retain inertia when the
# player moves; the renderer snaps back to the logical pixel grid.
const SHEET := preload("res://assets/player/cape_red_ivory_atlas.png")
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
			faces.append(PackedInt32Array([index*2,index*2+1,index*2+3,index*2+2]))
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
	var wind := -110.0 if running and not dead else -15.0
	var floor_y: float = actor.global_position.y-2.0
	points[0] = anchor
	previous[0] = anchor
	for index in range(1,LINKS+1):
		var old: Vector2 = points[index]
		var inertia: Vector2 = (points[index]-previous[index])*(0.9 if dead else 0.92)
		var t := float(index)/float(LINKS)
		var flutter := sin(clock*7.0-float(index)*0.45)*22.0 if not dead else 0.0
		var acceleration := Vector2(wind,(250.0 if dead else 85.0)+flutter)
		if not dead:
			# A thick-cloth rest shape resists collapse without freezing the tail.
			var rest := anchor+Vector2(-float(index)*LINK_LENGTH,t*(14.0 if running else 28.0)+sin(clock*4.0-t*3.0)*4.0*t)
			acceleration += (rest-points[index])*lerpf(70.0,24.0,t)
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
				var minimum := LINK_LENGTH*1.85
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
				points[index].x = minf(points[index].x,anchor.x-2.0)
				points[index] = _outside_shoulder(points[index])
			points[index].y = minf(points[index].y,floor_y)

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
		var normal := Vector2(-tangent.y,tangent.x)
		if normal.y < 0: normal = -normal
		var half_width := lerpf(4.0,17.0,sin(t*PI*0.5))
		if actor.body_state == "slide": half_width *= 0.8
		for side in [-1.0,1.0]:
			var world_point: Vector2 = points[index]+normal*half_width*side
			if index > 0: world_point = _outside_shoulder(world_point)
			world_point.y = minf(world_point.y,actor.global_position.y-1.0)
			red_vertices.append(to_local(world_point.round()))
			var shade := 0.88 if side < 0 else 1.0
			colors.append(Color(shade,shade,shade,1.0))
	outer.polygon = red_vertices
	outer.vertex_colors = colors

