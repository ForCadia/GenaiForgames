class_name TurretBase
extends Node2D

signal projectile_requested(origin: Vector2, direction: Vector2, speed: float, color: Color)
signal killed(turret: TurretBase, score_type: String)
signal feedback(origin: Vector2, color: Color, message: String)

enum TurretKind { LIGHT, HEAVY }
enum TurretState { ACTIVE, DAMAGED, BREAKING, EXPOSED, CHARGING, FIRING, DEAD }

@export var turret_kind := TurretKind.LIGHT
@export var score_type := "unarmored"
@export var attack_interval := 1.25
@export var projectile_speed := 520.0
@export var charge_time := 0.28
@export var laser_duration := 0.32
@export var laser_cooldown := 1.35
@export var laser_length := 700.0
@export var laser_fire_x := 640.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var solid_collision: CollisionShape2D = $CollisionShape2D
@onready var hurt_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var muzzle: Marker2D = $Muzzle
@onready var attack_timer: Timer = $AttackTimer
@onready var telegraph: Line2D = get_node_or_null("LaserTelegraph")
@onready var beam: Line2D = get_node_or_null("LaserBeam")
@onready var laser_area: Area2D = get_node_or_null("LaserHitbox")
@onready var laser_collision: CollisionShape2D = get_node_or_null("LaserHitbox/CollisionShape2D")
@onready var laser_ray: RayCast2D = get_node_or_null("LaserRay")

var state := TurretState.ACTIVE
var health := 2
var target_position := Vector2.ZERO
var phase_left := 0.0
var laser_hit_consumed := false
var attack_started := false
var contact_cooldown := 0.0

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	attack_timer.timeout.connect(_on_attack_timeout)
	attack_timer.wait_time = attack_interval
	if turret_kind == TurretKind.HEAVY:
		sprite.play(&"armored_idle")
		_set_laser_visible(false, false)
	else:
		sprite.play(&"idle")

func advance(delta: float, scroll_speed: float, player_position: Vector2) -> void:
	position.x -= scroll_speed * delta
	target_position = player_position
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	if not attack_started and global_position.x <= 920.0 and global_position.x > 290.0 \
			and state in [TurretState.ACTIVE, TurretState.DAMAGED, TurretState.EXPOSED]:
		attack_started = true
		_on_attack_timeout()
	if state == TurretState.CHARGING:
		phase_left -= delta
		_update_laser_length()
		if phase_left <= 0.0 and global_position.x <= laser_fire_x:
			state = TurretState.FIRING
			phase_left = laser_duration
			laser_hit_consumed = false
			sprite.play(&"laser_fire")
			_set_laser_visible(false, true)
	elif state == TurretState.FIRING:
		phase_left -= delta
		_update_laser_length()
		if phase_left <= 0.0:
			state = TurretState.EXPOSED if score_type == "heavy_exposed" else TurretState.ACTIVE
			_set_laser_visible(false, false)
			sprite.play(&"exposed_idle" if state == TurretState.EXPOSED else &"armored_idle")
			attack_timer.wait_time = laser_cooldown
			attack_timer.start()

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if state in [TurretState.BREAKING, TurretState.DEAD]:
		return false
	return _segment_hits_rect(from, to, _shape_rect(hurt_collision))

func take_damage(penetration: int, impact: Vector2) -> void:
	if state in [TurretState.BREAKING, TurretState.DEAD]:
		return
	if turret_kind == TurretKind.LIGHT:
		health -= 1
		if health > 0:
			state = TurretState.DAMAGED
			sprite.play(&"damaged_idle")
			feedback.emit(impact, Color("ffcf70"), "TURRET DAMAGED")
		else:
			_explode()
		return
	if state != TurretState.EXPOSED:
		if penetration < 3:
			feedback.emit(impact, Color.WHITE, "RICOCHET // USE PIERCER")
			return
		state = TurretState.BREAKING
		attack_timer.stop()
		_set_laser_visible(false, false)
		hurt_collision.disabled = true
		sprite.play(&"armor_break")
		feedback.emit(impact, Color("ffcf70"), "ARMOR BREAK")
		return
	_explode()

func force_kill() -> void:
	if state != TurretState.DEAD:
		_explode()

func body_rect() -> Rect2:
	return _shape_rect(solid_collision)

func try_laser_damage(player_rect: Rect2) -> bool:
	if state != TurretState.FIRING or laser_hit_consumed or not laser_rect().intersects(player_rect):
		return false
	laser_hit_consumed = true
	return true

func laser_rect() -> Rect2:
	if laser_collision == null or laser_collision.disabled:
		return Rect2()
	return _shape_rect(laser_collision)

func _on_attack_timeout() -> void:
	if state == TurretState.DEAD or state == TurretState.BREAKING:
		return
	if global_position.x > 920.0:
		return
	if global_position.x < 290.0:
		return
	if turret_kind == TurretKind.LIGHT:
		projectile_requested.emit(muzzle.global_position, Vector2.LEFT, projectile_speed, Color("ffcf70"))
		sprite.play(&"damaged_shoot" if state == TurretState.DAMAGED else &"shoot")
		attack_timer.start(attack_interval)
	else:
		state = TurretState.CHARGING
		phase_left = charge_time
		sprite.play(&"laser_charge")
		_update_laser_length()
		_set_laser_visible(true, false)

func _on_animation_finished() -> void:
	if sprite.animation == &"explode":
		queue_free()
	elif sprite.animation == &"armor_break":
		state = TurretState.EXPOSED
		score_type = "heavy_exposed"
		hurt_collision.disabled = false
		sprite.play(&"exposed_idle")
		attack_timer.wait_time = laser_cooldown
		attack_timer.start()
	elif sprite.animation in [&"shoot", &"damaged_shoot"]:
		sprite.play(&"damaged_idle" if state == TurretState.DAMAGED else &"idle")

func _explode() -> void:
	state = TurretState.DEAD
	attack_timer.stop()
	solid_collision.disabled = true
	hurt_collision.disabled = true
	_set_laser_visible(false, false)
	killed.emit(self, "heavy" if turret_kind == TurretKind.HEAVY else "unarmored")
	sprite.play(&"explode")

func _update_laser_length() -> void:
	if laser_ray == null:
		return
	laser_ray.target_position = Vector2(-laser_length, 0)
	laser_ray.force_raycast_update()
	var length := laser_length
	if laser_ray.is_colliding():
		length = muzzle.global_position.distance_to(laser_ray.get_collision_point())
	telegraph.points = PackedVector2Array([muzzle.position, muzzle.position + Vector2(-length, 0)])
	beam.points = telegraph.points
	var shape := laser_collision.shape as RectangleShape2D
	shape.size = Vector2(length, 8)
	laser_collision.position = muzzle.position + Vector2(-length * 0.5, 0)

func _set_laser_visible(show_telegraph: bool, show_beam: bool) -> void:
	if telegraph == null:
		return
	telegraph.visible = show_telegraph
	beam.visible = show_beam
	laser_area.monitoring = show_beam
	laser_collision.disabled = not show_beam

func _shape_rect(collision: CollisionShape2D) -> Rect2:
	var shape := collision.shape as RectangleShape2D
	return Rect2(collision.global_position - shape.size * 0.5, shape.size)

func _segment_hits_rect(from: Vector2, to: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from) or rect.has_point(to):
		return true
	var a := rect.position
	var b := Vector2(rect.end.x, rect.position.y)
	var c := rect.end
	var d := Vector2(rect.position.x, rect.end.y)
	return Geometry2D.segment_intersects_segment(from, to, a, b) != null \
		or Geometry2D.segment_intersects_segment(from, to, b, c) != null \
		or Geometry2D.segment_intersects_segment(from, to, c, d) != null \
		or Geometry2D.segment_intersects_segment(from, to, d, a) != null
