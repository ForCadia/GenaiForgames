extends Node2D

const GD := preload("res://game_data.gd")
const LASER_GATE_SCENE := preload("res://LaserGateEnemy.tscn")
const GROUND_SPIKES_SCENE := preload("res://GroundSpikes.tscn")
const LIGHT_TURRET_SCENE := preload("res://LightTurret.tscn")
const HEAVY_TURRET_SCENE := preload("res://HeavyTurret.tscn")
const BOSS_BOMB_SCENE := preload("res://BossBomb.tscn")
const BOSS_PARTICLE_SCENE := preload("res://BossParticle.tscn")
const LASER_GATE_SPEED := 315.0
const CYAN := Color("63e6f2")
const WHITE := Color("e4f8ff")
const YELLOW := Color("ffcf70")
const RED := Color("ff5f6d")
const DIM := Color("54718e")
const PLAYER_CAN_DIE := true
const BOSS_IDLE_Y := 350.0
const BOSS_ATTACK_Y := 520.0
const BOSS_FLIGHT_SPEED := 300.0

@onready var player_visual: PlayerVisual = $Player
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var laser_gate_root: Node2D = $LaserGates
@onready var ground_spikes_root: Node2D = $GroundSpikes
@onready var turret_root: Node2D = $Turrets
@onready var boss_attack_root: Node2D = $BossAttacks
@onready var boss_actor: EyeballBoss = $EyeballBoss
@onready var background_layer: Parallax2D = $Background
@onready var middle_layer: Parallax2D = $MiddleLayer
@onready var track_layer: Parallax2D = $Track

var player := Vector2(GD.PLAYER_X, GD.GROUND_Y)
var velocity_y := 0.0
var crouching := false
const MIN_SLIDE_TIME := 0.7
var slide_time_left := 0.0
var guarding := false
var guard_energy: float = GD.GUARD.maximum
var guard_idle := 0.0
var guard_lock := 0.0
var aim := Vector2(700, 350)
var weapon_index := 0
var selected_slot := 0
var ammo := [GD.WEAPONS[0].magazine, GD.WEAPONS[1].magazine]
var reload_left := 0.0
var shot_left := 0.0
var has_grenade := false

var score := 0
var stats := {"unarmored": 0, "light": 0, "heavy": 0, "flyer": 0}
var checkpoint_score := 0
var checkpoint_stats := {}
var checkpoint_ammo := [24, 5]
var segment := 0
var segment_time := 0.0
var next_event := 0
var segment_transition_pending := false
var distance := 0.0
var boss_mode := false
var state := "playing"
var death_delay := 0.0
var banner := ""
var banner_time := 0.0
var notice := ""
var notice_time := 0.0

var enemies: Array[Dictionary] = []
var laser_gates: Array[LaserGateEnemy] = []
var ground_spikes: Array[GroundSpikes] = []
var turrets: Array[TurretBase] = []
var obstacles: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var threats: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var floaters: Array[Dictionary] = []
var boss_bombs: Array[BossBomb] = []
var boss_particles: Array[BossParticle] = []
var boss := {}

func _ready() -> void:
	randomize()
	boss_actor.bomb_requested.connect(_on_boss_bomb_requested)
	boss_actor.particle_requested.connect(_on_boss_particle_requested)
	boss_actor.feedback.connect(_on_boss_feedback)
	boss_actor.weak_point_hit.connect(_boss_damage)
	boss_actor.form_changed.connect(_on_boss_form_changed)
	_start_segment(0)
	_update_parallax()

func _process(delta: float) -> void:
	_update_fx(delta)
	if state == "dead":
		death_delay -= delta
		if death_delay <= 0 and (Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("fire")):
			_retry()
		queue_redraw()
		return
	if state == "victory":
		if Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("jump"):
			_new_run()
		queue_redraw()
		return
	banner_time = maxf(0, banner_time - delta)
	notice_time = maxf(0, notice_time - delta)
	segment_time += delta
	_update_player(delta)
	player_visual.position = player
	player_visual.set_motion(_grounded(), crouching, weapon_index, aim, guarding, state == "playing")
	player_hud.follow_hitbox(_player_hitbox())
	_update_world(delta)
	_update_parallax()
	if state != "playing":
		queue_redraw()
		return
	_update_shots(delta)
	_update_threats(delta)
	if state != "playing":
		queue_redraw()
		return
	if boss_mode: _update_boss(delta)
	else: _update_segment()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: aim = event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: aim = event.position
	if state == "playing" and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_switch_weapon()

func _update_player(delta: float) -> void:
	player_visual.position = player
	var stick := Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	if stick.length() > 0.28: aim = _player_center() + stick.normalized() * 420
	var crouch_pressed := Input.is_action_pressed("crouch") and _grounded()
	if crouch_pressed and not crouching:
		slide_time_left = MIN_SLIDE_TIME
	slide_time_left = maxf(0.0, slide_time_left - delta)
	var wants_crouch := _grounded() and (crouch_pressed or slide_time_left > 0.0)
	if crouching and not wants_crouch and _grounded() and not _can_stand():
		wants_crouch = true
	crouching = wants_crouch
	if Input.is_action_just_pressed("jump") and _grounded() and not crouching:
		velocity_y = -GD.PLAYER.jump_speed
		_emit(_player_center(), CYAN, 7, 115)
	if not _grounded(): velocity_y += GD.PLAYER.gravity * delta
	player.y += velocity_y * delta
	if player.y >= GD.GROUND_Y: player.y = GD.GROUND_Y; velocity_y = 0
	player_visual.position = player
	player_visual.set_collision_pose(crouching)

	guard_lock = maxf(0, guard_lock - delta)
	guarding = Input.is_action_pressed("guard") and guard_energy > 0 and guard_lock <= 0
	if guarding:
		guard_idle = 0
		guard_energy = maxf(0, guard_energy - GD.GUARD.drain_per_second * delta)
		if guard_energy <= 0:
			guarding = false; guard_lock = GD.GUARD.break_lockout
			_notify("GUARD BREAK", RED); _emit(_player_center(), RED, 22, 190)
	else:
		guard_idle += delta
		if guard_lock <= 0 and guard_idle >= GD.GUARD.regen_delay:
			guard_energy = minf(GD.GUARD.maximum, guard_energy + GD.GUARD.regen_per_second * delta)

	if Input.is_action_just_pressed("switch_weapon"): _switch_weapon()
	if Input.is_action_just_pressed("weapon_slot_1"): _select_slot(0)
	if Input.is_action_just_pressed("weapon_slot_2"): _select_slot(1)
	if Input.is_action_just_pressed("weapon_slot_3"): _select_slot(2)
	if Input.is_action_just_pressed("reload"): _reload()
	if Input.is_action_just_pressed("use_grenade") and has_grenade: _grenade()
	shot_left = maxf(0, shot_left - delta)
	if reload_left > 0:
		reload_left = maxf(0, reload_left - delta)
		if reload_left <= 0:
			ammo[weapon_index] = _weapon().magazine
			_notify("MAGAZINE READY", CYAN)
		_refresh_player_ui()
	if Input.is_action_pressed("fire") and reload_left <= 0 and shot_left <= 0:
		if selected_slot == 2:
			if has_grenade: _grenade()
			else: _notify("GRENADE SLOT EMPTY", RED, 0.35)
		elif ammo[weapon_index] > 0: _fire()
		else: _notify("EMPTY — PRESS R / X", RED, 0.2)

func _switch_weapon() -> void:
	if reload_left > 0: return
	weapon_index = 1 - weapon_index; selected_slot = weapon_index
	player_visual.set_primary_weapon(weapon_index)
	_refresh_player_ui()
	_notify(_weapon().name, _weapon().color)

func _select_slot(slot: int) -> void:
	if reload_left > 0: return
	if slot == 2:
		if not has_grenade:
			_notify("SLOT 3 EMPTY // FIND GRENADE", RED)
			return
		selected_slot = 2
		_refresh_player_ui()
		_notify("GRENADE LAUNCHER // ONE SHOT", CYAN)
		return
	selected_slot = slot
	weapon_index = slot
	player_visual.set_primary_weapon(weapon_index)
	_refresh_player_ui()
	_notify("SLOT %d // %s" % [slot + 1, _weapon().name], _weapon().color)

func _reload() -> void:
	if state != "playing" or reload_left > 0 or ammo[weapon_index] >= _weapon().magazine: return
	reload_left = _weapon().reload
	player_visual.play_reload(reload_left)
	_refresh_player_ui()

func _fire() -> void:
	if state != "playing" or reload_left > 0 or shot_left > 0 or selected_slot == 2 or ammo[weapon_index] <= 0:
		return
	player_visual.position = player
	player_visual.set_motion(_grounded(), crouching, weapon_index, aim, guarding, state == "playing")
	player_visual.play_fire()
	var origin := player_visual.muzzle_world_position()
	var to_target := aim - origin
	var direction: Vector2 = to_target.normalized() if to_target.length_squared() > 0.001 else player_visual.shot_direction()
	shots.append({"pos": origin, "previous": origin, "velocity": direction * _weapon().projectile_speed, "penetration": _weapon().penetration, "color": _weapon().color})
	ammo[weapon_index] -= 1
	_refresh_player_ui()
	shot_left = _weapon().cadence
	_emit(origin, _weapon().color, 5, 145)

func _grenade() -> void:
	has_grenade = false
	selected_slot = 0
	weapon_index = 0
	_refresh_player_ui()
	var count := 0
	for enemy in enemies:
		if enemy.pos.distance_to(_player_center()) <= GD.GRENADE.radius: _kill_enemy(enemy); count += 1
	for turret in turrets:
		if is_instance_valid(turret) and turret.global_position.distance_to(_player_center()) <= GD.GRENADE.radius:
			turret.force_kill(); count += 1
	enemies = enemies.filter(func(e): return not e.dead)
	threats.clear(); _emit(Vector2(520, 380), CYAN, 70, 420)
	_notify("GRENADE PULSE // %d CLEARED" % count, CYAN, 1)

func _update_segment() -> void:
	var data: Dictionary = GD.SEGMENTS[segment]
	if not segment_transition_pending:
		while next_event < data.events.size() and segment_time >= data.events[next_event].at * GD.SEGMENT_PACE:
			_spawn_event(data.events[next_event]); next_event += 1
		if segment_time >= data.duration * GD.SEGMENT_PACE:
			segment_transition_pending = true
	# Let the outgoing enemies, obstacles, pickups and hostile rounds leave
	# the screen instead of making them vanish mid-frame at the time limit.
	if segment_transition_pending and enemies.is_empty() and turrets.is_empty() and laser_gates.is_empty() and ground_spikes.is_empty() and obstacles.is_empty() and pickups.is_empty() and threats.is_empty():
		if segment == GD.CAMPAIGN_SEGMENT_COUNT - 1: _start_boss()
		else: _start_segment(segment + 1)

func _spawn_event(event: Dictionary) -> void:
	match event.kind:
		"enemy": _spawn_enemy(event.type, event.get("y", 0), event.get("returns", false))
		"low_obstacle": _spawn_ground_spikes()
		"high_barrage": _spawn_laser_gate()
		_: pass

func _spawn_enemy(kind: String, _y: float, _returns: bool) -> void:
	if kind in ["unarmored", "light"]:
		_spawn_turret(LIGHT_TURRET_SCENE)
		return
	if kind == "heavy":
		_spawn_turret(HEAVY_TURRET_SCENE)
		return

func _spawn_turret(scene: PackedScene) -> void:
	var turret: TurretBase = scene.instantiate()
	turret_root.add_child(turret)
	turret.position = Vector2(1020, GD.GROUND_Y)
	turret.projectile_requested.connect(_on_turret_projectile)
	turret.killed.connect(_on_turret_killed)
	turret.feedback.connect(_on_turret_feedback)
	turrets.append(turret)

func _on_turret_projectile(origin: Vector2, direction: Vector2, speed: float, color: Color) -> void:
	threats.append({"pos": origin, "velocity": direction * speed, "unblockable": false, "radius": 7.0, "color": color})

func _on_turret_killed(turret: TurretBase, score_type: String) -> void:
	_award_enemy_kill(score_type, turret.global_position)

func _on_turret_feedback(origin: Vector2, color: Color, message: String) -> void:
	_emit(origin, color, 15, 210)
	_notify(message, color)

func _spawn_laser_gate() -> void:
	var gate: LaserGateEnemy = LASER_GATE_SCENE.instantiate()
	laser_gate_root.add_child(gate)
	gate.position = Vector2(990, 450)
	gate.destroyed.connect(_on_laser_gate_destroyed)
	laser_gates.append(gate)

func _spawn_ground_spikes() -> void:
	var spikes: GroundSpikes = GROUND_SPIKES_SCENE.instantiate()
	ground_spikes_root.add_child(spikes)
	spikes.position = Vector2(1010, GD.GROUND_Y)
	ground_spikes.append(spikes)

func _on_laser_gate_destroyed(gate: LaserGateEnemy) -> void:
	_emit(gate.global_position, RED, 12, 145)
	_notify("LASER GATE DOWN", CYAN)

func _update_world(delta: float) -> void:
	var scroll := _scroll()
	distance += scroll * delta
	for enemy in enemies:
		enemy.touch_lock = maxf(0, enemy.touch_lock - delta)
		enemy.pos.x -= (scroll + enemy.local_speed) * delta
		if enemy.type == "flyer":
			enemy.pos.y = enemy.base_y + sin(segment_time * 2.2 + enemy.phase) * 34
			if enemy.pos.x < -70 and enemy.returns and not enemy.returned:
				enemy.pos.x = 1040; enemy.base_y = clampf(enemy.base_y + randf_range(-90, 90), 250, 500); enemy.returned = true
		enemy.fire -= delta
		if enemy.fire <= 0 and enemy.pos.x < 920 and enemy.pos.x > 290:
			enemy.fire = 2.5 if enemy.type == "flyer" else 3.4
			threats.append({"pos": enemy.pos, "velocity": (_player_center() - enemy.pos).normalized() * 305, "unblockable": false, "radius": 7.0})
		_enemy_contact(enemy)
	for i in range(turrets.size() - 1, -1, -1):
		var turret := turrets[i]
		if not is_instance_valid(turret) or turret.is_queued_for_deletion():
			turrets.remove_at(i)
			continue
		turret.advance(delta, scroll, _player_center())
		if turret.position.x < -120:
			turret.queue_free()
			turrets.remove_at(i)
			continue
		if turret.try_laser_damage(_player_hitbox()):
			_receive(false, "HEAVY TURRET LASER")
		var turret_rect := turret.body_rect()
		if guarding and turret.state != TurretBase.TurretState.DEAD and _guard_hitbox().intersects(turret_rect):
			turret.force_kill()
			guard_energy = maxf(0.0, guard_energy - 7.0)
			_emit(turret_rect.get_center(), CYAN, 24, 260)
			_notify("SHIELD IMPACT // TARGET DESTROYED", CYAN)
			continue
		if turret.state != TurretBase.TurretState.DEAD and turret.contact_cooldown <= 0.0 and turret_rect.intersects(_player_hitbox()):
			var landed_on_turret := velocity_y > 80.0 and player.y <= turret_rect.position.y + 16.0
			if landed_on_turret:
				player.y = turret_rect.position.y
				player_visual.position = player
				velocity_y = -GD.PLAYER.stomp_speed
				turret.contact_cooldown = 0.3
				_emit(Vector2(player.x, turret_rect.position.y), CYAN, 7, 115)
			else:
				_receive(false, "TURRET COLLISION")
	for i in range(laser_gates.size() - 1, -1, -1):
		var gate := laser_gates[i]
		if not is_instance_valid(gate) or gate.is_queued_for_deletion():
			laser_gates.remove_at(i)
			continue
		gate.advance(delta, LASER_GATE_SPEED)
		if gate.position.x < -200:
			gate.queue_free()
			laser_gates.remove_at(i)
			continue
		if guarding and gate.state == "Hover" and _guard_hitbox().intersects(gate.hazard_rect()):
			gate.take_damage()
			guard_energy = maxf(0.0, guard_energy - 7.0)
			_emit(gate.global_position, CYAN, 24, 260)
			_notify("SHIELD IMPACT // LASER GATE DESTROYED", CYAN)
			continue
		if gate.state == "Hover" and gate.hazard_cooldown <= 0.0 and _player_hitbox().intersects(gate.hazard_rect()):
			gate.hazard_cooldown = 0.45
			_receive(false, "LASER GATE")
	for i in range(ground_spikes.size() - 1, -1, -1):
		var spikes := ground_spikes[i]
		spikes.advance(delta, scroll)
		if spikes.position.x < -107:
			spikes.queue_free()
			ground_spikes.remove_at(i)
			continue
		if guarding and spikes.hits_rect(_guard_hitbox()):
			_emit(spikes.global_position + Vector2(0, -40), CYAN, 24, 260)
			_notify("SHIELD IMPACT // OBSTACLE DESTROYED", CYAN)
			spikes.queue_free()
			ground_spikes.remove_at(i)
			guard_energy = maxf(0.0, guard_energy - 7.0)
			continue
		var touching := spikes.hits_rect(_player_hitbox())
		if touching and not spikes.touching_player:
			_receive(true, "GROUND SPIKES // UNBLOCKABLE")
		spikes.touching_player = touching
	for obstacle in obstacles:
		obstacle.x -= scroll * delta
		var rect: Rect2 = obstacle.rect; rect.position += Vector2(obstacle.x, GD.GROUND_Y)
		if obstacle.danger:
			if guarding and _guard_hitbox().intersects(rect):
				obstacle.danger = false
				obstacle.x = -1000.0
				_emit(rect.get_center(), CYAN, 20, 230)
				continue
			if not _player_hitbox().intersects(rect):
				continue
			var landed_on_top: bool = obstacle.type == "low" and velocity_y >= 0 and player.y <= rect.position.y + 12
			if landed_on_top:
				# Top contact is safe. Snap out of the collider and give a small
				# automatic hop so the scrolling obstacle cannot kill on the next frame.
				player.y = rect.position.y
				player_visual.position = player
				velocity_y = -GD.PLAYER.obstacle_bounce
				_emit(Vector2(player.x, rect.position.y), CYAN, 6, 95)
			else:
				_die("TRACK IMPACT // UNBLOCKABLE")
	for pickup in pickups:
		pickup.pos.x -= scroll * delta
		if pickup.pos.distance_to(_player_center()) < 44:
			has_grenade = true; pickup.collected = true; _emit(pickup.pos, CYAN, 20, 180); _notify("GRENADE ACQUIRED // PRESS E / RB", CYAN, 1.2)
	enemies = enemies.filter(func(e): return not e.dead and e.pos.x > -110)
	obstacles = obstacles.filter(func(o): return o.x > -100)
	pickups = pickups.filter(func(p): return not p.collected and p.pos.x > -80)

func _enemy_contact(enemy: Dictionary) -> void:
	if enemy.dead or enemy.touch_lock > 0: return
	if guarding and _circle_rect(enemy.pos, enemy.radius, _guard_hitbox()):
		_kill_enemy(enemy)
		guard_energy = maxf(0.0, guard_energy - 7.0)
		_notify("SHIELD IMPACT // TARGET DESTROYED", CYAN)
		return
	if not _circle_rect(enemy.pos, enemy.radius, _player_hitbox()): return
	if velocity_y > 80 and player.y < enemy.pos.y - enemy.radius * 0.35:
		velocity_y = -GD.PLAYER.stomp_speed; enemy.touch_lock = 0.5
		if enemy.type == "heavy": _notify("HEAVY STOMP // SLIDE OFF", RED); _emit(enemy.pos, YELLOW, 14, 210)
		else: _kill_enemy(enemy); _notify("STOMP", CYAN)
	else: _receive(false, "ENEMY COLLISION")

func _update_shots(delta: float) -> void:
	for i in range(shots.size() - 1, -1, -1):
		var bullet := shots[i]; bullet.previous = bullet.pos; bullet.pos += bullet.velocity * delta
		var hit := false
		for gate in laser_gates:
			if is_instance_valid(gate) and gate.shot_hits(bullet.previous, bullet.pos):
				gate.take_damage()
				hit = true
				break
		for turret in turrets:
			if not hit and is_instance_valid(turret) and turret.shot_hits(bullet.previous, bullet.pos):
				turret.take_damage(bullet.penetration, bullet.pos)
				hit = true
				break
		for enemy in enemies:
			if not hit and not enemy.dead and _line_circle(bullet.previous, bullet.pos, enemy.pos, enemy.radius): _hit_enemy(enemy, bullet); hit = true; break
		if not hit and boss_mode and boss_actor.shot_hits(bullet.previous, bullet.pos):
			_hit_boss(bullet)
			hit = true
		if hit or bullet.pos.x > 1010 or bullet.pos.y < 80 or bullet.pos.y > 720: shots.remove_at(i)

func _hit_enemy(enemy: Dictionary, bullet: Dictionary) -> void:
	if enemy.armor > 0:
		if bullet.penetration >= enemy.armor: enemy.armor = 0; _emit(enemy.pos, YELLOW, 23, 245); _notify("ARMOR BROKEN", YELLOW)
		else: _emit(bullet.pos, WHITE, 13, 220); _notify("RICOCHET // USE PIERCER", WHITE)
		return
	enemy.hp -= 1
	if enemy.hp <= 0: _kill_enemy(enemy)

func _kill_enemy(enemy: Dictionary) -> void:
	if enemy.dead: return
	enemy.dead = true
	_award_enemy_kill(enemy.type, enemy.pos)

func _award_enemy_kill(enemy_type: String, origin: Vector2) -> void:
	var points: int = GD.SCORE[enemy_type]
	stats[enemy_type] += 1
	score += points
	floaters.append({"pos": origin, "text": "+%d" % points, "color": YELLOW, "life": 0.85})
	_emit(origin, RED, 18, 205)

func _update_threats(delta: float) -> void:
	for i in range(threats.size() - 1, -1, -1):
		var bullet := threats[i]; bullet.pos += bullet.velocity * delta
		if guarding and not bullet.unblockable and _circle_rect(bullet.pos, bullet.radius, _guard_hitbox()):
			guard_energy = maxf(0.0, guard_energy - 7.0)
			_emit(bullet.pos, CYAN, 14, 210)
			_notify("PARRY", CYAN, 0.25)
			threats.remove_at(i)
		elif _circle_rect(bullet.pos, bullet.radius, _player_hitbox()): _receive(bullet.unblockable, "HOSTILE FIRE"); threats.remove_at(i)
		elif bullet.pos.x < -50 or bullet.pos.x > 1020: threats.remove_at(i)

func _receive(unblockable: bool, cause: String) -> void:
	if guarding and not unblockable:
		guard_energy = maxf(0, guard_energy - 7); _emit(_player_center(), CYAN, 18, 190); _notify("PARRY", CYAN)
	else: _die(cause)

func _die(cause: String) -> void:
	if not PLAYER_CAN_DIE: return
	if state != "playing": return
	state = "dead"; death_delay = 0.35; banner = cause; _emit(_player_center(), RED, 40, 300)
	if boss_mode:
		boss_actor.set_combat_enabled(false)
		_clear_boss_attacks()
	player_visual.play_death()
	_refresh_player_ui()
	player_hud.follow_hitbox(_player_hitbox())

func _start_segment(index: int) -> void:
	segment = index; segment_time = 0; next_event = 0; segment_transition_pending = false; boss_mode = false
	checkpoint_score = score; checkpoint_stats = stats.duplicate(true); checkpoint_ammo = ammo.duplicate()
	_clear_world(); _reset_player()
	player_visual.start_scrolling()
	banner = "CHECKPOINT // " + GD.SEGMENTS[index].title; banner_time = 2

func _start_boss() -> void:
	boss_mode = true; segment_time = 0; segment_transition_pending = false; _clear_world(); _reset_player()
	player_visual.start_scrolling()
	checkpoint_score = score; checkpoint_stats = stats.duplicate(true); checkpoint_ammo = ammo.duplicate()
	boss = {"armor": GD.BOSS.armor_per_cycle, "hp": GD.BOSS.health, "phase": 1}
	boss_actor.position = Vector2(785.0, BOSS_IDLE_Y)
	boss_actor.reset_for_battle(true)
	banner = "BOSS CHECKPOINT // BREAK ARMOR, THEN ATTACK"; banner_time = 2.2

func _update_boss(delta: float) -> void:
	boss_actor.advance(delta, _player_center())
	var target_y := BOSS_ATTACK_Y if boss_actor.wants_low_flight() else BOSS_IDLE_Y + sin(segment_time * 0.8) * 22.0
	boss_actor.position = Vector2(785.0, move_toward(boss_actor.position.y, target_y, BOSS_FLIGHT_SPEED * delta))
	for i in range(boss_bombs.size() - 1, -1, -1):
		var bomb := boss_bombs[i]
		if not is_instance_valid(bomb):
			boss_bombs.remove_at(i)
			continue
		bomb.advance(delta, _scroll())
		if bomb.try_damage(_player_hitbox()):
			_receive(false, "BOSS BOMB")
		if bomb.is_finished():
			bomb.queue_free()
			boss_bombs.remove_at(i)
	for i in range(boss_particles.size() - 1, -1, -1):
		var projectile := boss_particles[i]
		if not is_instance_valid(projectile):
			boss_particles.remove_at(i)
			continue
		projectile.advance(delta)
		if projectile.try_damage(_player_hitbox()):
			_receive(false, "BOSS HIGH PARTICLE")
		if projectile.is_finished():
			projectile.queue_free()
			boss_particles.remove_at(i)

func _on_boss_bomb_requested(target_x: float) -> void:
	if state != "playing" or not boss_mode:
		return
	var bomb: BossBomb = BOSS_BOMB_SCENE.instantiate()
	boss_attack_root.add_child(bomb)
	bomb.position = Vector2(target_x, 115.0)
	boss_bombs.append(bomb)

func _on_boss_particle_requested(origin: Vector2) -> void:
	if state != "playing" or not boss_mode:
		return
	var projectile: BossParticle = BOSS_PARTICLE_SCENE.instantiate()
	boss_attack_root.add_child(projectile)
	projectile.position = Vector2(origin.x, projectile.firing_height)
	boss_particles.append(projectile)

func _on_boss_feedback(origin: Vector2, color: Color, message: String) -> void:
	_emit(origin, color, 18, 230)
	_notify(message, color, GD.BOSS.telegraph_time if message.begins_with("BOSS TELEGRAPH") else 0.9)

func _on_boss_form_changed(form: EyeballBoss.BossForm) -> void:
	boss.armor = boss_actor.armor_layers()
	boss.phase = int(form) + 1

func _hit_boss(bullet: Dictionary) -> void:
	if state != "playing":
		return
	boss_actor.receive_shot(bullet.penetration, bullet.pos)

func _boss_damage() -> void:
	boss.hp -= 1; boss.phase = int(boss_actor.form) + 1
	_emit(_boss_pos(), WHITE, 45, 390)
	if boss.hp <= 0:
		score += GD.SCORE.boss
		state = "victory"
		banner = "THE FRONT NEVER STOPS"
		boss_actor.start_death()
		_clear_boss_attacks()
		player_visual.show_idle()
	else:
		_notify("BOSS HIT // HP %d / %d" % [boss.hp, GD.BOSS.health], WHITE, 1)

func _retry() -> void:
	state = "playing"; score = checkpoint_score; stats = checkpoint_stats.duplicate(true); ammo = checkpoint_ammo.duplicate()
	if boss_mode: _start_boss()
	else: _start_segment(segment)

func _new_run() -> void:
	score = 0; stats = {"unarmored": 0, "light": 0, "heavy": 0, "flyer": 0}; state = "playing"; _start_segment(0)

func _reset_player() -> void:
	player = Vector2(GD.PLAYER_X, GD.GROUND_Y); velocity_y = 0; crouching = false; guarding = false; slide_time_left = 0.0
	player_visual.position = player
	player_visual.set_collision_pose(false)
	guard_energy = GD.GUARD.maximum; guard_idle = 0; guard_lock = 0; reload_left = 0; shot_left = 0; selected_slot = weapon_index
	_refresh_player_ui()
	player_hud.follow_hitbox(_player_hitbox())

func _clear_world() -> void:
	enemies.clear(); obstacles.clear(); pickups.clear(); shots.clear(); threats.clear()
	for spikes in ground_spikes:
		if is_instance_valid(spikes): spikes.queue_free()
	ground_spikes.clear()
	for turret in turrets:
		if is_instance_valid(turret): turret.queue_free()
	turrets.clear()
	for gate in laser_gates:
		if is_instance_valid(gate): gate.queue_free()
	laser_gates.clear()
	_clear_boss_attacks()
	particles.clear(); floaters.clear(); notice = ""; notice_time = 0.0; has_grenade = false
	boss.clear()
	if is_instance_valid(boss_actor): boss_actor.reset_for_battle(false)

func _clear_boss_attacks() -> void:
	for bomb in boss_bombs:
		if is_instance_valid(bomb): bomb.queue_free()
	boss_bombs.clear()
	for projectile in boss_particles:
		if is_instance_valid(projectile): projectile.queue_free()
	boss_particles.clear()

func _update_fx(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		particles[i].pos += particles[i].velocity * delta; particles[i].velocity *= pow(0.04, delta); particles[i].life -= delta
		if particles[i].life <= 0: particles.remove_at(i)
	for i in range(floaters.size() - 1, -1, -1):
		floaters[i].pos.y -= 30 * delta; floaters[i].life -= delta
		if floaters[i].life <= 0: floaters.remove_at(i)

func _emit(origin: Vector2, color: Color, count: int, speed: float) -> void:
	for i in range(count): particles.append({"pos": origin, "velocity": Vector2.from_angle(randf_range(0, TAU)) * randf_range(speed * 0.3, speed), "life": randf_range(0.18, 0.62), "color": color})

func _notify(text: String, color: Color, duration := 0.55) -> void:
	notice = text; notice_time = duration
	floaters.append({"pos": Vector2(330, 158), "text": text, "color": color, "life": duration})

func _weapon() -> Dictionary: return GD.WEAPONS[weapon_index]
func _refresh_player_ui() -> void:
	# The current game is one-hit death; state is its only health source.
	player_hud.refresh(0 if state == "dead" else 1, 1, _weapon().name,
		_weapon().penetration, ammo[weapon_index], _weapon().magazine,
		reload_left, _weapon().reload)
	player_hud.follow_hitbox(_player_hitbox())
func _slot_color() -> Color: return CYAN if selected_slot == 2 else _weapon().color
func _slot_name() -> String: return "GRENADE LAUNCHER" if selected_slot == 2 else _weapon().name
func _scroll() -> float: return (GD.BOSS.scroll if boss_mode else GD.SEGMENTS[segment].scroll) * GD.SCROLL_MULTIPLIER
func _update_parallax() -> void:
	# The world distance already drives enemies and obstacles. Quantize only
	# rendering offsets so the unscaled pixel art never samples half pixels.
	background_layer.scroll_offset = Vector2(-roundf(distance * 0.15), 0)
	middle_layer.scroll_offset = Vector2(-roundf(distance * 0.55), 0)
	# Track and ground actors share the same world distance, so their feet do
	# not slide relative to the rail artwork.
	track_layer.scroll_offset = Vector2(-roundf(distance), 0)
func _can_stand() -> bool:
	var standing_rect := player_visual.standing_rect_at(player)
	for obstacle in obstacles:
		if not obstacle.danger: continue
		var rect: Rect2 = obstacle.rect
		rect.position += Vector2(obstacle.x, GD.GROUND_Y)
		if standing_rect.intersects(rect): return false
	return true
func _player_hitbox() -> Rect2: return player_visual.hurtbox_rect()
func _guard_hitbox() -> Rect2: return player_visual.guard_rect()
func _player_center() -> Vector2: return _player_hitbox().get_center()
func _grounded() -> bool: return is_zero_approx(player.y - GD.GROUND_Y)
func _boss_pos() -> Vector2:
	if boss_mode and is_instance_valid(boss_actor) and boss_actor.visible:
		return boss_actor.position
	return Vector2(785.0, BOSS_IDLE_Y)
func _circle_rect(center: Vector2, radius: float, rect: Rect2) -> bool:
	var closest := Vector2(clampf(center.x, rect.position.x, rect.end.x), clampf(center.y, rect.position.y, rect.end.y))
	return center.distance_squared_to(closest) <= radius * radius
func _line_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool: return Geometry2D.get_closest_point_to_segment(center, a, b).distance_to(center) <= radius

func _draw() -> void:
	for object in obstacles: _draw_obstacle(object)
	for bullet in threats:
		var threat_color: Color = bullet.get("color", RED)
		draw_circle(bullet.pos, bullet.radius + 8, Color(threat_color, 0.12))
		draw_circle(bullet.pos, bullet.radius, threat_color)
	for bullet in shots: draw_line(bullet.pos, bullet.pos - bullet.velocity.normalized() * 22, bullet.color, 4)
	for particle in particles: draw_circle(particle.pos, 3, Color(particle.color, clampf(particle.life * 2, 0, 1)))
	if state == "playing": _draw_reticle()
	_draw_hud()
	for label in floaters: draw_string(ThemeDB.fallback_font, label.pos, label.text, HORIZONTAL_ALIGNMENT_CENTER, 300, 14, Color(label.color, clampf(label.life * 2, 0, 1)))
	if state == "dead": _draw_death()
	if state == "victory": _draw_victory()

func _draw_reticle() -> void:
	draw_arc(aim, 11, 0, TAU, 20, _slot_color(), 2)
	draw_line(aim + Vector2(-17, 0), aim + Vector2(-7, 0), _slot_color(), 2); draw_line(aim + Vector2(7, 0), aim + Vector2(17, 0), _slot_color(), 2)
	draw_line(aim + Vector2(0, -17), aim + Vector2(0, -7), _slot_color(), 2); draw_line(aim + Vector2(0, 7), aim + Vector2(0, 17), _slot_color(), 2)

func _draw_obstacle(object: Dictionary) -> void:
	if object.type == "barrel" and object.shot: return
	var rect: Rect2 = object.rect; rect.position += Vector2(object.x, GD.GROUND_Y)
	draw_rect(rect, YELLOW if object.type == "barrel" else Color("69758a"))
	if object.type == "barrel": draw_string(ThemeDB.fallback_font, rect.position + Vector2(3, -8), "SHOOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, YELLOW)
	else: draw_line(rect.position + Vector2(8, 8), rect.end - Vector2(8, 8), WHITE, 3)

func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, 960, 88), Color(0.02, 0.05, 0.12, 0.95)); draw_line(Vector2(0, 88), Vector2(960, 88), CYAN, 1)
	draw_string(ThemeDB.fallback_font, Vector2(26, 30), "THE FRONT NEVER STOPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, CYAN)
	draw_string(ThemeDB.fallback_font, Vector2(26, 59), "BOSS // PHASE %d" % boss.get("phase", 1) if boss_mode else "SEGMENT %02d / %02d" % [segment + 1, GD.CAMPAIGN_SEGMENT_COUNT], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, DIM)
	draw_string(ThemeDB.fallback_font, Vector2(304, 31), "SCORE %06d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(304, 59), "KILLS %02d" % [stats.unarmored + stats.light + stats.heavy + stats.flyer], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, YELLOW)
	draw_string(ThemeDB.fallback_font, Vector2(735, 26), "GUARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, DIM); draw_rect(Rect2(735, 36, 190, 12), Color("18273b")); draw_rect(Rect2(735, 36, 190 * guard_energy / GD.GUARD.maximum, 12), RED if guard_lock > 0 else CYAN)
	draw_string(ThemeDB.fallback_font, Vector2(735, 70), "[E/RB] GRENADE" if has_grenade else "GRENADE —", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CYAN if has_grenade else DIM)
	if boss_mode:
		var boss_health: float = float(boss.hp) / float(GD.BOSS.health)
		draw_rect(Rect2(250, 101, 460, 18), Color("241827"))
		draw_rect(Rect2(254, 105, 452 * boss_health, 10), RED)
		draw_string(ThemeDB.fallback_font, Vector2(0, 137), "BOSS HP %d / %d   //   ARMOR %d" % [boss.hp, GD.BOSS.health, boss.armor], HORIZONTAL_ALIGNMENT_CENTER, 960, 14, WHITE if boss.armor == 0 else RED)
	else: draw_string(ThemeDB.fallback_font, Vector2(0, 116), GD.SEGMENTS[segment].hint, HORIZONTAL_ALIGNMENT_CENTER, 960, 12, DIM)
	if banner_time > 0: draw_string(ThemeDB.fallback_font, Vector2(0, 157), banner, HORIZONTAL_ALIGNMENT_CENTER, 960, 17, WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(24, 704), "SPACE/W JUMP   S/CTRL CROUCH   LMB/RT FIRE   RMB/LT GUARD   1/2/3 WEAPONS   Q/Y CYCLE   R/X RELOAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, DIM)

func _draw_death() -> void:
	draw_rect(Rect2(Vector2.ZERO, GD.VIEW_SIZE), Color(0.01, 0.02, 0.06, 0.82)); draw_string(ThemeDB.fallback_font, Vector2(0, 286), "ONE HIT // CHECKPOINT LOST", HORIZONTAL_ALIGNMENT_CENTER, 960, 34, RED); draw_string(ThemeDB.fallback_font, Vector2(0, 332), banner, HORIZONTAL_ALIGNMENT_CENTER, 960, 15, WHITE); draw_string(ThemeDB.fallback_font, Vector2(0, 382), "PRESS R / SPACE / FIRE TO RETRY", HORIZONTAL_ALIGNMENT_CENTER, 960, 14, CYAN)

func _draw_victory() -> void:
	draw_rect(Rect2(Vector2.ZERO, GD.VIEW_SIZE), Color(0.01, 0.02, 0.06, 0.92)); draw_string(ThemeDB.fallback_font, Vector2(0, 205), "MISSION COMPLETE", HORIZONTAL_ALIGNMENT_CENTER, 960, 38, CYAN); draw_string(ThemeDB.fallback_font, Vector2(0, 258), "FINAL SCORE  %06d" % score, HORIZONTAL_ALIGNMENT_CENTER, 960, 24, WHITE)
	var lines := [["LIGHT TURRETS", stats.unarmored], ["HEAVY TURRETS", stats.heavy], ["BOSS DEFEATED", "YES"]]
	for i in range(lines.size()): draw_string(ThemeDB.fallback_font, Vector2(300, 320 + i * 30), lines[i][0], HORIZONTAL_ALIGNMENT_LEFT, 210, 15, DIM); draw_string(ThemeDB.fallback_font, Vector2(560, 320 + i * 30), str(lines[i][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(0, 550), "PRESS R / SPACE TO REDEPLOY", HORIZONTAL_ALIGNMENT_CENTER, 960, 14, YELLOW)
