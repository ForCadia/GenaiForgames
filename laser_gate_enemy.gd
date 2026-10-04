class_name LaserGateEnemy
extends Node2D

signal destroyed(gate: LaserGateEnemy)

@export_range(1, 20, 1) var hit_points := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_hit: CollisionShape2D = $LeftDroneHitArea/CollisionShape2D
@onready var right_hit: CollisionShape2D = $RightDroneHitArea/CollisionShape2D
@onready var laser_hit: CollisionShape2D = $LaserHazardArea/CollisionShape2D
@onready var laser_area: Area2D = $LaserHazardArea

var health := 1
var state := "Hover"
var hazard_cooldown := 0.0

func _ready() -> void:
	health = hit_points
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play(&"Hover")

func advance(delta: float, speed: float) -> void:
	position.x -= speed * delta
	hazard_cooldown = maxf(0.0, hazard_cooldown - delta)

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if state != "Hover":
		return false
	return _segment_hits_rect(from, to, _shape_rect(left_hit)) or _segment_hits_rect(from, to, _shape_rect(right_hit))

func hazard_rect() -> Rect2:
	return _shape_rect(laser_hit)

func take_damage(amount := 1) -> void:
	if state != "Hover":
		return
	health -= amount
	if health > 0:
		return
	state = "Hit"
	# Gameplay checks state immediately, and physics shapes are disabled at
	# the same moment so a dying gate can never deal another hit.
	left_hit.disabled = true
	right_hit.disabled = true
	laser_hit.disabled = true
	laser_area.monitoring = false
	sprite.play(&"Hit")
	destroyed.emit(self)

func _on_animation_finished() -> void:
	if state == "Hit":
		state = "Explode"
		sprite.play(&"Explode")
	elif state == "Explode":
		queue_free()

func _shape_rect(collision: CollisionShape2D) -> Rect2:
	var shape := collision.shape as RectangleShape2D
	return Rect2(collision.global_position - shape.size / 2.0, shape.size)

func _segment_hits_rect(from: Vector2, to: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from) or rect.has_point(to):
		return true
	var top_left := rect.position
	var top_right := Vector2(rect.end.x, rect.position.y)
	var bottom_left := Vector2(rect.position.x, rect.end.y)
	var bottom_right := rect.end
	return Geometry2D.segment_intersects_segment(from, to, top_left, top_right) != null \
		or Geometry2D.segment_intersects_segment(from, to, top_right, bottom_right) != null \
		or Geometry2D.segment_intersects_segment(from, to, bottom_right, bottom_left) != null \
		or Geometry2D.segment_intersects_segment(from, to, bottom_left, top_left) != null
