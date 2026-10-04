class_name BossBomb
extends Area2D

enum BombState {
	FALLING,
	GROUNDED,
	WARNING,
	EXPLODING,
	FINISHED,
}

@export var fall_speed := 620.0
@export var ground_hold_time := 0.35
@export var explosion_warning_time := 0.55
@export var explosion_duration := 0.28
@export var explosion_radius := 58.0
@export var damage := 1
@export var ground_y := 632.0

@onready var visual: Sprite2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D

var state: BombState = BombState.FALLING
var state_time := 0.0
var damage_consumed := false

func _ready() -> void:
	collision.disabled = true
	visual.frame = 0

func advance(delta: float, track_speed := 0.0) -> void:
	# Once planted on the rail, the bomb belongs to the scrolling world. This
	# keeps it visually locked to the track instead of hovering over the screen.
	if state != BombState.FALLING:
		position.x -= track_speed * delta
	match state:
		BombState.FALLING:
			position.y = minf(ground_y, position.y + fall_speed * delta)
			if position.y >= ground_y:
				state = BombState.GROUNDED
				state_time = ground_hold_time
				visual.frame = 1
		BombState.GROUNDED:
			state_time -= delta
			if state_time <= 0.0:
				state = BombState.WARNING
				state_time = explosion_warning_time
				visual.frame = 2
		BombState.WARNING:
			state_time -= delta
			if state_time <= 0.0:
				state = BombState.EXPLODING
				state_time = explosion_duration
				visual.frame = 3
				collision.disabled = false
		BombState.EXPLODING:
			state_time -= delta
			if state_time <= 0.0:
				state = BombState.FINISHED
				collision.disabled = true

func try_damage(player_rect: Rect2) -> bool:
	if state != BombState.EXPLODING or damage_consumed:
		return false
	var center := global_position + collision.position
	var closest := Vector2(clampf(center.x, player_rect.position.x, player_rect.end.x), clampf(center.y, player_rect.position.y, player_rect.end.y))
	if center.distance_squared_to(closest) <= explosion_radius * explosion_radius:
		damage_consumed = true
		return true
	return false

func is_finished() -> bool:
	return state == BombState.FINISHED
