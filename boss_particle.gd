class_name BossParticle
extends Area2D

@export var speed := 510.0
@export var telegraph_time := 0.72
@export var firing_interval := 2.5
@export var damage := 1
@export var lifetime := 2.2

@onready var visual: Sprite2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D

var life_left := 0.0
var impact_time := 0.0
var damage_consumed := false
var dissipating := false
var direction := Vector2.LEFT

func _ready() -> void:
	life_left = lifetime
	visual.frame = 5

func launch(origin: Vector2, flight_direction: Vector2) -> void:
	global_position = origin
	direction = flight_direction.normalized()
	# The supplied artwork points left at zero rotation.
	global_rotation = direction.angle() - PI

func advance(delta: float) -> void:
	if dissipating:
		impact_time -= delta
		visual.frame = 7 if impact_time < 0.1 else 6
		return
	global_position += direction * speed * delta
	life_left -= delta

func try_damage(player_rect: Rect2) -> bool:
	if dissipating or damage_consumed:
		return false
	var half_size := (collision.shape as RectangleShape2D).size * 0.5
	var hitbox := collision.global_transform * PackedVector2Array([
		Vector2(-half_size.x, -half_size.y), Vector2(half_size.x, -half_size.y),
		half_size, Vector2(-half_size.x, half_size.y),
	])
	var player_polygon := PackedVector2Array([
		player_rect.position, Vector2(player_rect.end.x, player_rect.position.y),
		player_rect.end, Vector2(player_rect.position.x, player_rect.end.y),
	])
	if not Geometry2D.intersect_polygons(hitbox, player_polygon).is_empty():
		damage_consumed = true
		start_dissipate()
		return true
	return false

func start_dissipate() -> void:
	dissipating = true
	impact_time = 0.2
	visual.frame = 6

func is_finished() -> bool:
	return life_left <= 0.0 or position.x < -90.0 or (dissipating and impact_time <= 0.0)
