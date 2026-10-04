class_name EyeballBoss
extends Node2D

signal bomb_requested(target_x: float)
signal particle_requested(origin: Vector2)
signal feedback(origin: Vector2, color: Color, message: String)
signal weak_point_hit()
signal form_changed(form: BossForm)

enum BossForm {
	DOUBLE_ARMOR,
	SINGLE_ARMOR,
	WEAK_POINT,
}

enum AttackState {
	IDLE,
	TELEGRAPH,
	BOMB_ATTACK,
	PARTICLE_ATTACK,
	RECOVERY,
	ARMOR_BREAK,
	DEAD,
}

@export var attack_interval := 2.5
@export var telegraph_time := 0.72
@export var recovery_time := 0.45
@export var armor_break_time := 0.55
@export var hit_radius := 88.0

@onready var visual: Sprite2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox

var form: BossForm = BossForm.DOUBLE_ARMOR
var attack_state: AttackState = AttackState.IDLE
var state_time := 0.0
var idle_frame_time := 0.0
var next_attack_is_bomb := true
var combat_enabled := false
var target_x := 440.0

func _ready() -> void:
	reset_for_battle(false)

func reset_for_battle(enabled: bool) -> void:
	form = BossForm.DOUBLE_ARMOR
	attack_state = AttackState.IDLE
	state_time = 1.15
	idle_frame_time = 0.0
	next_attack_is_bomb = true
	combat_enabled = enabled
	visible = enabled
	_set_hurtbox_enabled(enabled)
	_show_form_idle()

func set_combat_enabled(enabled: bool) -> void:
	combat_enabled = enabled
	_set_hurtbox_enabled(enabled and attack_state != AttackState.ARMOR_BREAK and attack_state != AttackState.DEAD)
	if not enabled and attack_state != AttackState.DEAD:
		attack_state = AttackState.IDLE
		state_time = attack_interval
		_show_form_idle()

func advance(delta: float, player_position: Vector2) -> void:
	if not combat_enabled or attack_state == AttackState.DEAD:
		return
	target_x = clampf(player_position.x + 250.0, 330.0, 610.0)
	state_time = maxf(0.0, state_time - delta)
	idle_frame_time += delta
	match attack_state:
		AttackState.IDLE:
			_animate_idle()
			if state_time <= 0.0:
				attack_state = AttackState.TELEGRAPH
				state_time = telegraph_time
				visual.frame = _form_row() * 8 + (2 if next_attack_is_bomb else 4)
				feedback.emit(global_position + Vector2(-90, 0), Color("ff5f6d"), "BOSS TELEGRAPH // %s" % ("JUMP" if next_attack_is_bomb else "CROUCH"))
		AttackState.TELEGRAPH:
			if state_time <= 0.0:
				if next_attack_is_bomb:
					attack_state = AttackState.BOMB_ATTACK
					visual.frame = _form_row() * 8 + 3
					bomb_requested.emit(target_x)
				else:
					attack_state = AttackState.PARTICLE_ATTACK
					visual.frame = _form_row() * 8 + 5
					particle_requested.emit(Vector2(global_position.x - 105.0, 565.0))
				state_time = 0.18
		AttackState.BOMB_ATTACK, AttackState.PARTICLE_ATTACK:
			if state_time <= 0.0:
				attack_state = AttackState.RECOVERY
				state_time = recovery_time
		AttackState.RECOVERY:
			_animate_idle()
			if state_time <= 0.0:
				next_attack_is_bomb = not next_attack_is_bomb
				attack_state = AttackState.IDLE
				state_time = attack_interval
		AttackState.ARMOR_BREAK:
			if state_time <= 0.0:
				form = mini(int(form) + 1, int(BossForm.WEAK_POINT)) as BossForm
				form_changed.emit(form)
				attack_state = AttackState.RECOVERY
				state_time = recovery_time
				_set_hurtbox_enabled(true)
				_show_form_idle()

func shot_hits(from: Vector2, to: Vector2) -> bool:
	if not combat_enabled or attack_state in [AttackState.ARMOR_BREAK, AttackState.DEAD]:
		return false
	return Geometry2D.get_closest_point_to_segment(global_position, from, to).distance_to(global_position) <= hit_radius

func receive_shot(penetration: int, impact_position: Vector2) -> void:
	if not combat_enabled or attack_state in [AttackState.ARMOR_BREAK, AttackState.DEAD]:
		return
	if form == BossForm.WEAK_POINT:
		visual.frame = _form_row() * 8 + 6
		feedback.emit(impact_position, Color("e4f8ff"), "WEAK POINT HIT")
		weak_point_hit.emit()
		return
	if penetration < 3:
		feedback.emit(impact_position, Color("e4f8ff"), "ARMORED // USE PIERCER")
		return
	attack_state = AttackState.ARMOR_BREAK
	state_time = armor_break_time
	_set_hurtbox_enabled(false)
	visual.frame = _form_row() * 8 + 6
	feedback.emit(impact_position, Color("ffcf70"), "OUTER ARMOR BROKEN" if form == BossForm.DOUBLE_ARMOR else "INNER ARMOR BROKEN // WEAK POINT EXPOSED")

func start_death() -> void:
	combat_enabled = false
	attack_state = AttackState.DEAD
	_set_hurtbox_enabled(false)
	visible = true
	visual.frame = int(BossForm.WEAK_POINT) * 8 + 7

func armor_layers() -> int:
	return 2 - int(form)

func wants_low_flight() -> bool:
	return attack_state in [
		AttackState.TELEGRAPH,
		AttackState.BOMB_ATTACK,
		AttackState.PARTICLE_ATTACK,
		AttackState.RECOVERY,
	]

func _form_row() -> int:
	return int(form)

func _animate_idle() -> void:
	visual.frame = _form_row() * 8 + (int(idle_frame_time * 3.0) % 2)

func _show_form_idle() -> void:
	visual.frame = _form_row() * 8

func _set_hurtbox_enabled(enabled: bool) -> void:
	if is_instance_valid(hurtbox):
		hurtbox.monitoring = enabled
		hurtbox.monitorable = enabled
	var shape := get_node_or_null("Hurtbox/CollisionShape2D") as CollisionShape2D
	if shape:
		shape.disabled = not enabled
