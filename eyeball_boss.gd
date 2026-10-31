class_name EyeballBoss
extends Node2D

signal bomb_requested(target_x: float)
signal particle_requested(origin: Vector2)
signal barrage_requested(origin: Vector2, wave: int)
signal feedback(origin: Vector2, color: Color, message: String)
signal weak_point_hit()
signal form_changed(form: BossForm)
signal sound_requested(cue: String, duration: float)

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
	BARRAGE_ATTACK,
	RECOVERY,
	ARMOR_BREAK,
	DEAD,
}

@export var armor_per_layer := preload("res://combat_balance.gd").BOSS_ARMOR_PER_LAYER
var armor_hp := 18

@export var attack_interval := 2.5
@export var telegraph_time := 0.72
@export var recovery_time := 0.45
@export var armor_break_time := 0.55
@export var hit_radius := 88.0
@export var particle_spread_degrees := 6.0
@export var barrage_wave_interval := 0.75

@onready var visual: Sprite2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox

var form: BossForm = BossForm.DOUBLE_ARMOR
var attack_state: AttackState = AttackState.IDLE
var state_time := 0.0
var idle_frame_time := 0.0
var next_attack_is_bomb := true
var next_attack_is_barrage := false
var barrage_wave := 0
var attack_position_ready := true
var combat_enabled := false
var target_x := 440.0

func _ready() -> void:
	reset_for_battle(false)

func reset_for_battle(enabled: bool) -> void:
	sound_requested.emit("stop", -1.0)
	form = BossForm.DOUBLE_ARMOR
	armor_hp = armor_per_layer
	attack_state = AttackState.IDLE
	state_time = 1.15
	idle_frame_time = 0.0
	next_attack_is_bomb = true
	next_attack_is_barrage = false
	barrage_wave = 0
	attack_position_ready = true
	combat_enabled = enabled
	visible = enabled
	_set_hurtbox_enabled(enabled)
	_show_form_idle()

func set_combat_enabled(enabled: bool) -> void:
	if not enabled: sound_requested.emit("stop", -1.0)
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
				if not next_attack_is_bomb: sound_requested.emit("boss_particle_charge", telegraph_time)
				visual.frame = _form_row() * 8 + (2 if next_attack_is_bomb else 4)
				var hint := "DODGE // 3 WAVES" if next_attack_is_barrage else ("JUMP" if next_attack_is_bomb else "CROUCH")
				feedback.emit(global_position + Vector2(-90, 0), Color("ff5f6d"), "BOSS TELEGRAPH // " + hint)
		AttackState.TELEGRAPH:
			if state_time <= 0.0 and attack_position_ready:
				if next_attack_is_barrage:
					attack_state = AttackState.BARRAGE_ATTACK
					barrage_wave = 0
					_fire_barrage_wave()
					return
				elif next_attack_is_bomb:
					attack_state = AttackState.BOMB_ATTACK
					visual.frame = _form_row() * 8 + 3
					bomb_requested.emit(target_x)
				else:
					attack_state = AttackState.PARTICLE_ATTACK
					visual.frame = _form_row() * 8 + 5
					particle_requested.emit($ProjectileMuzzle.global_position)
				state_time = 0.18
		AttackState.BARRAGE_ATTACK:
			if state_time <= 0.0:
				if barrage_wave < 3:
					_fire_barrage_wave()
				else:
					attack_state = AttackState.RECOVERY
					state_time = recovery_time
		AttackState.BOMB_ATTACK, AttackState.PARTICLE_ATTACK:
			if state_time <= 0.0:
				attack_state = AttackState.RECOVERY
				state_time = recovery_time
		AttackState.RECOVERY:
			_animate_idle()
			if state_time <= 0.0:
				if next_attack_is_bomb:
					next_attack_is_bomb = false
				elif not next_attack_is_barrage:
					next_attack_is_barrage = true
				else:
					next_attack_is_barrage = false
					next_attack_is_bomb = true
				attack_state = AttackState.IDLE
				state_time = attack_interval
		AttackState.ARMOR_BREAK:
			# Existing cracked -> detached frames show the layer actually falling off.
			visual.frame = int(form) * 8 + (6 if state_time > armor_break_time * 0.5 else 7)
			if state_time <= 0.0:
				form = mini(int(form) + 1, int(BossForm.WEAK_POINT)) as BossForm
				armor_hp = armor_per_layer if form != BossForm.WEAK_POINT else 0
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
		sound_requested.emit("armor_ricochet", -1.0)
		feedback.emit(impact_position, Color("e4f8ff"), "ARMORED // USE PIERCER")
		return
	armor_hp = maxi(0, armor_hp - penetration)
	if armor_hp > 0:
		if attack_state in [AttackState.IDLE, AttackState.RECOVERY]: _animate_idle()
		feedback.emit(impact_position, Color("63e6f2"), "ARMOR HIT // %d / %d" % [armor_points(), armor_per_layer * 2])
		return
	attack_state = AttackState.ARMOR_BREAK
	sound_requested.emit("stop", -1.0)
	state_time = armor_break_time
	_set_hurtbox_enabled(false)
	visual.frame = _form_row() * 8 + 6
	feedback.emit(impact_position, Color("ffcf70"), "OUTER ARMOR BROKEN" if form == BossForm.DOUBLE_ARMOR else "INNER ARMOR BROKEN // WEAK POINT EXPOSED")

func start_death() -> void:
	sound_requested.emit("stop", -1.0)
	combat_enabled = false
	attack_state = AttackState.DEAD
	_set_hurtbox_enabled(false)
	visible = true
	visual.frame = int(BossForm.WEAK_POINT) * 8 + 7

func armor_layers() -> int:
	return 2 - int(form)

func wants_low_flight() -> bool:
	return not next_attack_is_bomb and not next_attack_is_barrage and attack_state in [
		AttackState.TELEGRAPH,
		AttackState.PARTICLE_ATTACK,
		AttackState.RECOVERY,
	]

func _fire_barrage_wave() -> void:
	visual.frame = _form_row() * 8 + 5
	barrage_requested.emit($ProjectileMuzzle.global_position, barrage_wave)
	barrage_wave += 1
	state_time = barrage_wave_interval

func _form_row() -> int:
	if attack_state in [AttackState.ARMOR_BREAK, AttackState.DEAD]: return int(form)
	var remaining := armor_points()
	if remaining <= 0: return int(BossForm.WEAK_POINT)
	return int(BossForm.SINGLE_ARMOR) if remaining <= armor_per_layer else int(BossForm.DOUBLE_ARMOR)

func _armor_cracked() -> bool:
	return form != BossForm.WEAK_POINT and armor_hp > 0 and armor_hp <= armor_per_layer * 0.5

func _animate_idle() -> void:
	visual.frame = _form_row() * 8 + (6 if _armor_cracked() else int(idle_frame_time * 3.0) % 2)

func _show_form_idle() -> void:
	visual.frame = _form_row() * 8 + (6 if _armor_cracked() else 0)

func _set_hurtbox_enabled(enabled: bool) -> void:
	if is_instance_valid(hurtbox):
		hurtbox.monitoring = enabled
		hurtbox.monitorable = enabled
	var shape := get_node_or_null("Hurtbox/CollisionShape2D") as CollisionShape2D
	if shape:
		shape.disabled = not enabled

func armor_points() -> int:
	if form == BossForm.WEAK_POINT: return 0
	return armor_hp + (armor_per_layer if form == BossForm.DOUBLE_ARMOR else 0)
