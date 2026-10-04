class_name BossParticle
extends Area2D

@export var speed := 510.0
@export var firing_height := 565.0
@export var telegraph_time := 0.72
@export var firing_interval := 2.5
@export var damage := 1
@export var lifetime := 2.2

@onready var visual: Sprite2D = $Visual

var life_left := 0.0
var impact_time := 0.0
var damage_consumed := false
var dissipating := false

func _ready() -> void:
	life_left = lifetime
	visual.frame = 5

func advance(delta: float) -> void:
	if dissipating:
		impact_time -= delta
		visual.frame = 7 if impact_time < 0.1 else 6
		return
	position.x -= speed * delta
	life_left -= delta

func try_damage(player_rect: Rect2) -> bool:
	if dissipating or damage_consumed:
		return false
	var hitbox := Rect2(global_position + Vector2(-43, -15), Vector2(86, 30))
	if hitbox.intersects(player_rect):
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
