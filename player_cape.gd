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
var lining := Polygon2D.new()
var scarf := Sprite2D.new()
var clock := 0.0
var accumulator := 0.0
var initialized := false
var previous_state := ""

func _ready() -> void:
	z_index = -3
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for mesh in [lining,outer]:
		mesh.texture = SHEET
		mesh.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(mesh)
	scarf.texture = preload("res://assets/player/scarf_red_pixel.png")
	scarf.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Scarf size is independent of the cape; it must stay under the helmet.
	scarf.scale = Vector2.ONE*(68.0/float(scarf.texture.get_width()))
	scarf.z_index = 0
	_attach_scarf.call_deferred()
	_configure_mesh(outer,Rect2(40,140,1210,490))
	_configure_mesh(lining,Rect2(520,800,730,380))

func _attach_scarf() -> void:
	if not is_instance_valid(actor): return
	get_parent().add_child(scarf)
	# Same CanvasItem z layer, explicit sibling order: body < scarf < helmet
	# < front arm. Never parent the scarf to the weapon aiming pivot.
	get_parent().move_child(scarf,actor.helmet.get_index())

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
		scarf.hide()
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
	if is_instance_valid(scarf) and scarf.is_inside_tree():
		scarf.visible = actor.body_state != "death"
		scarf.position = actor.helmet.position+Vector2(-6,9)
		scarf.rotation = 0.0 if actor.body_state != "death" else minf(1.1,float(actor.body_time))

func _simulate(anchor: Vector2) -> void:
	var dead: bool = actor.body_state == "death"
	var running: bool = actor.body_state in ["run","slide","jump"]
	var wind := -250.0 if running and not dead else -25.0
	var floor_y: float = actor.global_position.y-2.0
	points[0] = anchor
	previous[0] = anchor
	for index in range(1,LINKS+1):
		var old: Vector2 = points[index]
		var inertia: Vector2 = (points[index]-previous[index])*(0.9 if dead else 0.975)
		var flutter := sin(clock*9.0-float(index)*0.65)*55.0 if not dead else 0.0
		points[index] += inertia+Vector2(wind,250.0+flutter)*STEP*STEP
		previous[index] = old
	for iteration in range(7):
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
		for index in range(1,LINKS+1):
			# Keep the cloth behind the torso and above the track.
			if not dead: points[index].x = minf(points[index].x,anchor.x-2.0)
			points[index].y = minf(points[index].y,floor_y)

func _draw_strip() -> void:
	var red_vertices := PackedVector2Array()
	var ivory_vertices := PackedVector2Array()
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
		var curl := sin(clock*5.0-t*6.0)*(0.5+t)*1.1
		for side in [-1.0,1.0]:
			var world_point: Vector2 = points[index]+normal*half_width*side
			world_point.y = minf(world_point.y,actor.global_position.y-1.0)
			red_vertices.append(to_local(world_point.round()))
			var ivory_point: Vector2 = world_point+normal*(1.5+curl)
			ivory_point.y = minf(ivory_point.y,actor.global_position.y-1.0)
			ivory_vertices.append(to_local(ivory_point.round()))
			var shade := 0.88 if side < 0 else 1.0
			colors.append(Color(shade,shade,shade,1.0))
	outer.polygon = red_vertices
	lining.polygon = ivory_vertices
	outer.vertex_colors = colors

func _exit_tree() -> void:
	if is_instance_valid(scarf): scarf.queue_free()
