extends Node2D

const MECHA_SCENE := preload("res://MechaBoss.tscn")
const MECHA_DATA := preload("res://mecha_boss_data.gd")
const BALANCE := preload("res://combat_balance.gd")
const AERIAL := preload("res://aerial_rifleman.gd")
const KAMIKAZE := preload("res://kamikaze_drone.gd")
const GD := preload("res://game_data.gd")
const CAMPAIGNS := preload("res://campaign_data.gd")
const THREAT_BUDGET := preload("res://threat_budget.gd")
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
const COIN_TEXTURE := preload("res://assets/items/credit_coin.png")
const GRENADE_TEXTURE := preload("res://assets/items/grenade.png")
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

var lab = preload("res://lab_telemetry.gd").new()
var lab_panel: CanvasLayer
var retry_requested := false
var restart_mode := "checkpoint"
var developer_mode := false
var boss_test_mode := false
var boss_test_kind := "eyeball"
var mecha_actor: Node2D
var selected_level := 0
var endless_mode := false
var endless_difficulty := "normal"
var endless_wave := 1
var level_segments: Array = []
var endless_wave_data: Dictionary = {}
var endless_intermission := 0.0
var endless_talent_ranks: Dictionary = {}
var endless_talent_effects: Dictionary = {}
var endless_talent_choices: Array[String] = []
var endless_reward_ui: CanvasLayer
var attract_mode := false
var attract_settings: Node
var attract_input: Dictionary = {}
var attract_taps: Dictionary = {}
var menu_demo: Node2D
var start_screen: CanvasLayer
var music: AudioStreamPlayer
var weapon_audio: Node
var world_audio: Node
var checkpoint_weapon_index := 0
var checkpoint_distance := 0.0

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
var manual_piercer_lock := false
var endless_fire_count := 0
var endless_homing_round_count := 0
var legacy_shot_target_serial := 0
var ammo := [GD.WEAPONS[0].magazine, GD.WEAPONS[1].magazine]
var reload_left := 0.0
var shot_left := 0.0
var grenade_count := 0
var checkpoint_grenades := 0
var has_grenade: bool:
	get: return grenade_count > 0
	set(value): grenade_count = maxi(1, grenade_count) if value else 0
var boss_grenade_spawned := false
var boss_entering := false

var score := 0
var stats := {"unarmored": 0, "light": 0, "heavy": 0, "flyer": 0}
var checkpoint_score := 0
var checkpoint_stats := {}
var checkpoint_ammo := [24, 5]
var segment := 0
var segment_time := 0.0
var next_event := 0
var next_budget_spawn_at := 0.0
var segment_transition_pending := false
var distance := 0.0
var boss_mode := false
var state := "start"
var death_delay := 0.0
var death_ui_ready := false
const DEATH_CAMERA_DURATION := 1.2
const DEATH_CAMERA_HOLD := 0.5
var death_camera_started := false
var death_camera_tween: Tween
var banner := ""
var banner_time := 0.0
var notice := ""
var notice_time := 0.0

var enemies: Array[Dictionary] = []
var laser_gates: Array[LaserGateEnemy] = []
var ground_spikes: Array[GroundSpikes] = []
var turrets: Array[TurretBase] = []
var kamikaze_drones: Array[Node2D] = []
var aerial_riflemen: Array[Node2D] = []
var obstacles: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var threats: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var floaters: Array[Dictionary] = []
var boss_bombs: Array[BossBomb] = []
var boss_particles: Array[BossParticle] = []
var boss := {}
var ui_paused := false
var ui_preview := false
var run_elapsed := 0.0
var run_deaths := 0
var run_record: Dictionary = {}
var overlays: CanvasLayer
var play_profile := "development"
var development_profile: Node
var session_profile: Node
var progression: Node
var coin_drops: Array[Dictionary] = []
var run_total_kills := 0
var run_total_shots := 0
var run_coins := 0
var settlement: Dictionary = {}
var auto_guard_left := 0.0
var settings: Node

func _ready() -> void:
	randomize()
	progression = preload("res://progression.gd").new()
	progression.preview_only = attract_mode
	add_child(progression)
	development_profile = progression
	if attract_mode:
		settings = attract_settings
	else:
		settings = preload("res://game_settings.gd").new()
		settings.name = "Settings"
		add_child(settings)
	music = preload("res://music_player.gd").new()
	music.silent = attract_mode
	music.name = "Music"
	add_child(music)
	weapon_audio = preload("res://weapon_audio.gd").new()
	weapon_audio.silent = attract_mode
	weapon_audio.name = "WeaponAudio"
	add_child(weapon_audio)
	world_audio = preload("res://world_audio.gd").new()
	world_audio.name = "WorldAudio"
	world_audio.game = self
	add_child(world_audio)
	lab_panel = preload("res://lab_panel.gd").new()
	lab_panel.game = self
	lab_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(lab_panel)
	mecha_actor = MECHA_SCENE.instantiate()
	add_child(mecha_actor)
	mecha_actor.damage_requested.connect(_boss_damage)
	mecha_actor.projectile_requested.connect(_on_turret_projectile)
	mecha_actor.sound_requested.connect(func(cue: String): world_audio.play_cue(cue,-1.0,mecha_actor))
	mecha_actor.feedback.connect(_on_turret_feedback)
	boss_actor.bomb_requested.connect(_on_boss_bomb_requested)
	boss_actor.particle_requested.connect(_on_boss_particle_requested)
	boss_actor.barrage_requested.connect(_on_boss_barrage_requested)
	boss_actor.feedback.connect(_on_boss_feedback)
	boss_actor.weak_point_hit.connect(_boss_damage)
	boss_actor.form_changed.connect(_on_boss_form_changed)
	boss_actor.sound_requested.connect(func(cue: String, duration: float): world_audio.play_cue(cue, duration, boss_actor))
	_clear_world()
	_reset_player()
	_update_parallax()
	if attract_mode:
		start_screen = CanvasLayer.new()
		add_child(start_screen)
		overlays = preload("res://ui/overlays.gd").new()
		overlays.game = self
		add_child(overlays)
		overlays.set_process(false)
		lab_panel.set_process(false)
		player_hud.set_process(false)
		player_hud.hide()
		player_hud.hints_layer.hide()
		return
	menu_demo = preload("res://ui/menu_demo.gd").new()
	menu_demo.game = self
	add_child(menu_demo)
	start_screen = preload("res://start_screen.gd").new()
	start_screen.game = self
	start_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(start_screen)
	overlays = preload("res://ui/overlays.gd").new()
	overlays.game = self
	add_child(overlays)
	return_to_start()

func _process(delta: float) -> void:
	if state == "start" or ui_paused or lab_panel.blocked: return
	if state in ["talent","talent_exit"]:
		# Empty moving track: retain player input and parallax, never advance spawns.
		_update_fx(delta)
		_update_player(delta)
		player_visual.position = player
		player_visual.set_motion(_grounded(),crouching,weapon_index,aim,guarding,true)
		player_hud.follow_hitbox(_player_hitbox())
		distance += _scroll()*delta
		_update_parallax()
		queue_redraw()
		return
	if lab.active: lab.duration += delta
	if state != "victory": _update_fx(delta)
	if state == "dead":
		death_delay -= delta
		var over_button := get_viewport().gui_get_hovered_control() is BaseButton
		if _control_tapped("restart") or _control_tapped("jump") or (_control_tapped("fire") and not over_button):
			_request_retry("polled_input")
		if death_delay <= 0 and not death_camera_started:
			_start_death_camera()
		elif death_ui_ready and retry_requested:
			_retry()
		queue_redraw()
		return
	if state == "intermission":
		# Boss death is a safe moving transition, not a frozen simulation second.
		shots.clear()
		threats.clear()
		_update_player(delta)
		player_visual.position = player
		player_visual.set_motion(_grounded(),crouching,weapon_index,aim,guarding,true)
		player_hud.follow_hitbox(_player_hitbox())
		_update_coins(delta)
		distance += _scroll()*delta
		_update_parallax()
		endless_intermission -= delta
		if endless_intermission <= 0: _advance_endless()
		queue_redraw()
		return
	if state == "victory":
		if _control_tapped("restart") or _control_tapped("jump"):
			_new_run()
		queue_redraw()
		return
	banner_time = maxf(0, banner_time - delta)
	notice_time = maxf(0, notice_time - delta)
	run_elapsed += delta
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
	if attract_mode: return
	if state != "start" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if state in ["playing", "intermission"] and not lab_panel.expanded: set_ui_paused(not ui_paused)
		else: return_to_start()
		get_viewport().set_input_as_handled()
		return
	if state == "start" or ui_paused or lab_panel.blocked: return
	if state == "dead":
		for action in ["restart", "jump", "fire"]:
			if event.is_action_pressed(action) and not event.is_echo():
				_request_retry(action)
				get_viewport().set_input_as_handled()
				return
	if event is InputEventMouseMotion: aim = event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: aim = event.position
	if state == "playing" and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_switch_weapon()

func _update_player(delta: float) -> void:
	var horizontal_input := float(_control_held("move_forward")) - float(_control_held("move_back")) if attract_mode else Input.get_axis("move_back", "move_forward")
	if not is_zero_approx(horizontal_input):
		player.x = clampf(player.x + horizontal_input * GD.PLAYER.horizontal_speed * delta,
			GD.PLAYER_X - GD.PLAYER.horizontal_range, GD.PLAYER_X + GD.PLAYER.horizontal_range)
	else:
		player.x = move_toward(player.x, GD.PLAYER_X, GD.PLAYER.horizontal_return_speed * delta)
	player_visual.position = player
	var stick := Vector2.ZERO if attract_mode else Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	if stick.length() > 0.28: aim = _player_center() + stick.normalized() * 420
	var crouch_pressed := _control_held("crouch") and _grounded()
	if crouch_pressed and not crouching:
		slide_time_left = float(lab_panel.values.slide_time)
	slide_time_left = maxf(0.0, slide_time_left - delta)
	var wants_crouch := _grounded() and (crouch_pressed or slide_time_left > 0.0)
	if crouching and not wants_crouch and _grounded() and not _can_stand():
		wants_crouch = true
	crouching = wants_crouch
	if _control_tapped("jump") and _grounded() and not crouching:
		velocity_y = -float(lab_panel.values.jump_speed)
		_emit(_player_center(), CYAN, 7, 115)
	if not _grounded(): velocity_y += float(lab_panel.values.gravity) * delta
	player.y += velocity_y * delta
	if player.y >= GD.GROUND_Y: player.y = GD.GROUND_Y; velocity_y = 0
	player_visual.position = player
	player_visual.set_collision_pose(crouching)

	guard_lock = maxf(0, guard_lock - delta)
	auto_guard_left = maxf(0, auto_guard_left - delta)
	if _control_held("guard"): auto_guard_left = 0
	guarding = (_control_held("guard") or auto_guard_left > 0) and guard_energy > 0 and guard_lock <= 0
	if guarding:
		guard_idle = 0
		guard_energy = maxf(0, guard_energy - _guard_drain() * delta)
		if guard_energy <= 0:
			guarding = false; guard_lock = maxf(0.1, float(lab_panel.values.guard_lock) + _meta_effect("guard_lock"))
			_notify("GUARD BREAK", RED); _emit(_player_center(), RED, 22, 190)
	else:
		guard_idle += delta
		if guard_lock <= 0 and guard_idle >= _guard_delay():
			guard_energy = minf(guard_capacity(), guard_energy + guard_regen() * delta)

	world_audio.set_shield_active(guarding)
	if _control_tapped("switch_weapon"): _switch_weapon()
	if _control_tapped("weapon_slot_1"): _select_slot(0)
	if _control_tapped("weapon_slot_2"): _select_slot(1)
	if _control_tapped("weapon_slot_3"): _select_slot(2)
	if _control_tapped("reload"): _reload()
	if _control_tapped("use_grenade") and has_grenade: _grenade()
	shot_left = maxf(0, shot_left - delta)
	if reload_left > 0:
		reload_left = maxf(0, reload_left - delta)
		if reload_left <= 0:
			weapon_audio.finish_reload()
			ammo[weapon_index] = _weapon().magazine
			guard_energy = minf(guard_capacity(),guard_energy+_meta_effect("reload_energy"))
			_notify("MAGAZINE READY", CYAN)
		_refresh_player_ui()
	if _control_held("fire") and reload_left <= 0 and shot_left <= 0:
		if selected_slot == 2:
			if has_grenade: _grenade()
			else: _notify("GRENADE SLOT EMPTY", RED, 0.35)
		else:
			_auto_select_weapon()
			if ammo[weapon_index] > 0: _fire()
			elif not _upgrade("auto_weapon"): _notify("EMPTY // PRESS R / X", RED, 0.2)
	_auto_reload_empty()

func _switch_weapon() -> void:
	if reload_left > 0: return
	weapon_index = 1 - weapon_index; selected_slot = weapon_index
	manual_piercer_lock = weapon_index == 1
	weapon_audio.switch_weapon()
	player_visual.set_primary_weapon(weapon_index)
	_refresh_player_ui()
	_notify(_weapon().name, _weapon().color)

func _select_slot(slot: int, automatic := false) -> void:
	if reload_left > 0: return
	if slot == 2:
		if not has_grenade:
			_notify("SLOT 3 EMPTY // FIND GRENADE", RED)
			return
		if selected_slot != 2: weapon_audio.switch_weapon()
		selected_slot = 2
		_refresh_player_ui()
		_notify("GRENADE LAUNCHER // ONE SHOT", CYAN)
		return
	if selected_slot != slot: weapon_audio.switch_weapon()
	if not automatic: manual_piercer_lock = slot == 1
	selected_slot = slot
	weapon_index = slot
	player_visual.set_primary_weapon(weapon_index)
	_refresh_player_ui()
	_notify("SLOT %d // %s" % [slot + 1, _weapon().name], _weapon().color)

func _reload() -> void:
	if state != "playing" or reload_left > 0 or ammo[weapon_index] >= _weapon().magazine: return
	reload_left = _reload_duration()
	weapon_audio.reload(weapon_index, reload_left)
	player_visual.play_reload(reload_left)
	_refresh_player_ui()

func _fire() -> void:
	if state != "playing" or reload_left > 0 or shot_left > 0 or selected_slot == 2 or ammo[weapon_index] <= 0:
		return
	player_visual.position = player
	player_visual.set_motion(_grounded(), crouching, weapon_index, aim, guarding, state == "playing")
	player_visual.play_fire()
	weapon_audio.fire(weapon_index)
	var origin := player_visual.muzzle_world_position()
	var to_target := aim - origin
	var direction: Vector2 = to_target.normalized() if to_target.length_squared() > 0.001 else player_visual.shot_direction()
	endless_fire_count += 1
	var third_shot := endless_mode and endless_fire_count % 3 == 0
	var extra := int(_meta_effect("multishot"))
	if third_shot: extra += int(_meta_effect("third_fan"))
	var penetration: int = int(_weapon().penetration)
	var color: Color = _weapon().color
	if third_shot and _meta_effect("third_ap") > 0:
		penetration = maxi(3,penetration)
		color = CYAN
	# Keep the aimed center round; extra rounds form symmetric pairs.
	_emit_player_round(origin,direction,penetration,color)
	for index in range(extra):
		# One extra round per rank; alternate above/below, retain aimed center.
		var spread := 28.0*(1.0-exp(-float(int(index/2)+1)/5.0))
		var angle := deg_to_rad(spread)*(-1.0 if index % 2 == 0 else 1.0)
		_emit_player_round(origin,direction.rotated(angle),penetration,color)
	if third_shot and _meta_effect("third_energy") > 0:
		guard_energy = minf(guard_capacity(),guard_energy+_meta_effect("third_energy"))
		_emit(_player_center(),CYAN,6,90)
	ammo[weapon_index] -= 1
	_refresh_player_ui()
	shot_left = float(lab_panel.values.rifle_cadence if weapon_index == 0 else lab_panel.values.piercer_cadence) * (1.0 + _meta_effect("cadence"))
	_emit(origin, _weapon().color, 5, 145)

func _emit_player_round(origin: Vector2, direction: Vector2, penetration: int, color: Color) -> void:
	var homing_rank := mini(4,int(_meta_effect("homing")))
	var guided := false
	if homing_rank > 0:
		endless_homing_round_count += 1
		if endless_homing_round_count >= 6-homing_rank:
			guided = true
			endless_homing_round_count = 0
	shots.append({"pos":origin,"previous":origin,"velocity":direction*_weapon().projectile_speed,
		"penetration":penetration,"color":color,"style":_weapon().projectile_style,
		"pierce_left":int(_meta_effect("pierce_targets")),"homing":guided,
		"hit_ids":[],"target_id":0,"age":0.0})
	run_total_shots += 1

func _grenade() -> void:
	if state != "playing" or not has_grenade: return
	grenade_count -= 1
	if selected_slot == 2 and not has_grenade: selected_slot = weapon_index
	var screen := Rect2(Vector2.ZERO, GD.VIEW_SIZE)
	for enemy in enemies:
		if screen.has_point(enemy.pos): _kill_enemy(enemy)
	for turret in turrets:
		if is_instance_valid(turret) and screen.intersects(turret.body_rect()):
			turret.force_kill()
	for drone in kamikaze_drones:
		if is_instance_valid(drone) and screen.intersects(drone.body_rect()): drone.force_kill()
	for soldier in aerial_riflemen:
		if is_instance_valid(soldier) and screen.intersects(soldier.body_rect()): soldier.force_kill()
	for gate in laser_gates:
		if is_instance_valid(gate) and screen.intersects(gate.hazard_rect()): gate.take_damage()
	for i in range(ground_spikes.size() - 1, -1, -1):
		if ground_spikes[i].position.x >= 0 and ground_spikes[i].position.x <= GD.VIEW_SIZE.x:
			ground_spikes[i].queue_free()
			ground_spikes.remove_at(i)
	for obstacle in obstacles:
		if obstacle.x >= 0 and obstacle.x <= GD.VIEW_SIZE.x: obstacle.danger = false
	enemies = enemies.filter(func(e): return not e.dead)
	# All hostile rounds are cleared, including offscreen Boss ammunition.
	threats.clear()
	_clear_boss_attacks()
	if boss_mode: _boss_damage()
	world_audio.play_cue("boss_bomb_explode")
	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 8
	add_child(flash_layer)
	var flash := ColorRect.new()
	flash.color = Color(1, 0.95, 0.75, 0.18 if settings.options.reduced_flash else 0.8)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.add_child(flash)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tween := flash_layer.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.25)
	tween.tween_callback(flash_layer.queue_free)
	_refresh_player_ui()
	_notify("GRENADE // SCREEN CLEAR", CYAN, 1)

func _spawn_grenade_pickup() -> void:
	pickups.append({"pos": Vector2(990, GD.GROUND_Y - 35), "collected": false})

func _update_segment() -> void:
	var data: Dictionary = current_segment()
	if not segment_transition_pending:
		while next_event < data.events.size() and segment_time >= data.events[next_event].at * GD.SEGMENT_PACE:
			var event: Dictionary = data.events[next_event]
			var cost: int = THREAT_BUDGET.event_cost(event)
			if _uses_threat_budget() and cost > 0:
				if segment_time < next_budget_spawn_at or _active_threat_points()+cost > _threat_limit():
					break
				# Reserve offscreen arrivals too; never burst a delayed queue at once.
				next_budget_spawn_at = segment_time+(THREAT_BUDGET.endless_gap(endless_difficulty) if endless_mode else THREAT_BUDGET.SPAWN_GAP)
			_spawn_event(event)
			next_event += 1
		if segment_time >= data.duration * GD.SEGMENT_PACE and (not _uses_threat_budget() or next_event >= data.events.size()):
			segment_transition_pending = true
	# Let the outgoing enemies, obstacles, pickups and hostile rounds leave
	# the screen instead of making them vanish mid-frame at the time limit.
	if segment_transition_pending and enemies.is_empty() and turrets.is_empty() and kamikaze_drones.is_empty() and aerial_riflemen.is_empty() and laser_gates.is_empty() and ground_spikes.is_empty() and obstacles.is_empty() and pickups.is_empty() and coin_drops.is_empty() and threats.is_empty():
		if endless_mode: _advance_endless()
		elif segment == GD.CAMPAIGN_SEGMENT_COUNT - 1: _start_boss(true)
		else: _start_segment(segment + 1, true)

func _threat_limit() -> int:
	return THREAT_BUDGET.endless_limit(endless_difficulty) if endless_mode else THREAT_BUDGET.LIMIT

func _uses_threat_budget() -> bool:
	return not developer_mode and not boss_mode and (endless_mode or selected_level > 0)

func _active_threat_points() -> int:
	var total := 0
	for soldier in aerial_riflemen:
		if is_instance_valid(soldier) and not soldier.is_queued_for_deletion() and soldier.state != "dead":
			total += int(THREAT_BUDGET.COSTS.aerial)
	for turret in turrets:
		if is_instance_valid(turret) and not turret.is_queued_for_deletion() and turret.state != TurretBase.TurretState.DEAD:
			total += int(THREAT_BUDGET.COSTS.heavy if turret.turret_kind == TurretBase.TurretKind.HEAVY else THREAT_BUDGET.COSTS.light)
	for drone in kamikaze_drones:
		if is_instance_valid(drone) and not drone.is_queued_for_deletion() and not drone.is_finished():
			total += int(THREAT_BUDGET.COSTS.kamikaze)
	for gate in laser_gates:
		if is_instance_valid(gate) and not gate.is_queued_for_deletion() and gate.state == "Hover":
			total += THREAT_BUDGET.GATE_COST
	for spikes in ground_spikes:
		if is_instance_valid(spikes) and not spikes.is_queued_for_deletion():
			total += THREAT_BUDGET.SPIKES_COST
	for enemy in enemies:
		if not enemy.dead:
			total += int(THREAT_BUDGET.COSTS.get(enemy.type,25))
	return total

func _spawn_event(event: Dictionary) -> void:
	match event.kind:
		"grenade": _spawn_grenade_pickup()
		"enemy": _spawn_enemy(event.type, event.get("y", 0), event.get("returns", false))
		"low_obstacle": _spawn_ground_spikes()
		"high_barrage": _spawn_laser_gate()
		_: pass

func _spawn_enemy(kind: String, _y: float, _returns: bool) -> void:
	if kind == "aerial":
		if developer_mode or (not endless_mode and selected_level != 2): return
		var soldier: Node2D = AERIAL.new()
		turret_root.add_child(soldier)
		soldier.position = Vector2(1040,280 if segment % 2 == 0 else 340)
		soldier.base_y = soldier.position.y
		soldier.projectile_requested.connect(_on_aerial_projectile)
		soldier.killed.connect(func(actor: Node2D): _award_enemy_kill("aerial",actor.global_position))
		soldier.sound_requested.connect(func(cue: String): world_audio.play_cue(cue))
		aerial_riflemen.append(soldier)
		return
	if kind == "kamikaze":
		var drone: Node2D = KAMIKAZE.new()
		turret_root.add_child(drone)
		drone.position = Vector2(1010,220 if segment % 2 == 0 else 250)
		drone.base_y = drone.position.y
		drone.killed.connect(func(actor: Node2D): _award_enemy_kill("kamikaze",actor.global_position))
		drone.exploded.connect(func(_actor: Node2D): world_audio.play_cue("enemy_explode"))
		kamikaze_drones.append(drone)
		return
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
	turret.sound_requested.connect(func(cue: String, duration: float): world_audio.play_cue(cue, duration, turret))
	turrets.append(turret)

func _on_aerial_projectile(origin: Vector2, direction: Vector2, speed: float, color: Color) -> void:
	threats.append({"pos":origin,"velocity":direction*speed,"unblockable":false,
		"radius":4.0,"glow":4.0,"color":color})

func _on_turret_projectile(origin: Vector2, direction: Vector2, speed: float, color: Color) -> void:
	threats.append({"pos": origin, "velocity": direction * speed, "unblockable": false, "radius": 7.0, "color": color})

func _on_turret_killed(turret: TurretBase, score_type: String) -> void:
	world_audio.play_cue("enemy_explode")
	_award_enemy_kill(score_type, turret.global_position)

func _on_turret_feedback(origin: Vector2, color: Color, message: String) -> void:
	_emit(origin, color, 15, 210)
	_notify(message, color)

func _spawn_laser_gate() -> void:
	var gate: LaserGateEnemy = LASER_GATE_SCENE.instantiate()
	laser_gate_root.add_child(gate)
	gate.position = Vector2(990, 450)
	gate.destroyed.connect(_on_laser_gate_destroyed)
	gate.exploded.connect(func(): world_audio.play_cue("enemy_explode"))
	laser_gates.append(gate)

func _spawn_ground_spikes() -> void:
	var spikes: GroundSpikes = GROUND_SPIKES_SCENE.instantiate()
	ground_spikes_root.add_child(spikes)
	spikes.position = Vector2(1010, GD.GROUND_Y)
	ground_spikes.append(spikes)

func _on_laser_gate_destroyed(gate: LaserGateEnemy) -> void:
	_award_enemy_kill("flyer", gate.global_position)
	_emit(gate.global_position, RED, 12, 145)
	_notify("LASER GATE DOWN", CYAN)

func _update_world(delta: float) -> void:
	_update_coins(delta)
	_update_kamikaze_drones(delta)
	if state != "playing": return
	_update_aerial_riflemen(delta)
	if state != "playing": return
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
			_consume_guard_hit()
			_emit(turret_rect.get_center(), CYAN, 24, 260)
			_notify("SHIELD IMPACT // TARGET DESTROYED", CYAN)
			continue
		if turret.state != TurretBase.TurretState.DEAD and turret.contact_cooldown <= 0.0 and turret_rect.intersects(_player_hitbox()):
			var landed_on_turret := velocity_y > 80.0 and player.y <= turret_rect.position.y + 16.0
			if landed_on_turret:
				player.y = turret_rect.position.y
				player_visual.position = player
				velocity_y = -float(lab_panel.values.stomp_speed)
				turret.contact_cooldown = 0.3
				_emit(Vector2(player.x, turret_rect.position.y), CYAN, 7, 115)
			else:
				_receive(false, "TURRET COLLISION")
	for i in range(laser_gates.size() - 1, -1, -1):
		var gate := laser_gates[i]
		if not is_instance_valid(gate) or gate.is_queued_for_deletion():
			laser_gates.remove_at(i)
			continue
		gate.advance(delta, float(lab_panel.values.laser_gate_speed))
		if gate.position.x < -200:
			gate.queue_free()
			laser_gates.remove_at(i)
			continue
		if guarding and gate.state == "Hover" and _guard_hitbox().intersects(gate.hazard_rect()):
			gate.take_damage()
			_consume_guard_hit()
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
		if guarding and guard_energy > 0 and spikes.hits_rect(_guard_hitbox()):
			_emit(spikes.global_position + Vector2(0, -40), CYAN, 24, 260)
			_notify("SHIELD IMPACT // OBSTACLE DESTROYED", CYAN)
			spikes.queue_free()
			ground_spikes.remove_at(i)
			_consume_guard_hit()
			continue
		var touching := spikes.hits_rect(_player_hitbox())
		if touching and not spikes.touching_player:
			var blocked := _receive(false, "GROUND SPIKES")
			if blocked:
				_emit(spikes.global_position + Vector2(0,-40), CYAN,24,260)
				spikes.queue_free()
				ground_spikes.remove_at(i)
				continue
		spikes.touching_player = touching
	for obstacle in obstacles:
		obstacle.x -= scroll * delta
		var rect: Rect2 = obstacle.rect; rect.position += Vector2(obstacle.x, GD.GROUND_Y)
		if obstacle.danger:
			if guarding and _guard_hitbox().intersects(rect):
				_consume_guard_hit()
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
			world_audio.play_cue("item_pickup")
			grenade_count += 1; pickup.collected = true; _emit(pickup.pos, CYAN, 20, 180); _notify("GRENADE +1 // TOTAL %d // F / RB" % grenade_count, CYAN, 1.2)
	enemies = enemies.filter(func(e): return not e.dead and e.pos.x > -110)
	obstacles = obstacles.filter(func(o): return o.x > -100)
	pickups = pickups.filter(func(p): return not p.collected and p.pos.x > -80)
	world_audio.set_drone_active(laser_gates.any(func(gate):
		return is_instance_valid(gate) and not gate.is_queued_for_deletion() and gate.state == "Hover" and gate.position.x >= 0 and gate.position.x <= GD.VIEW_SIZE.x) or kamikaze_drones.any(func(drone): return is_instance_valid(drone) and drone.state != "explode" and drone.position.x >= 0 and drone.position.x <= GD.VIEW_SIZE.x))

func _enemy_contact(enemy: Dictionary) -> void:
	if enemy.dead or enemy.touch_lock > 0: return
	if guarding and _circle_rect(enemy.pos, enemy.radius, _guard_hitbox()):
		_kill_enemy(enemy)
		_consume_guard_hit()
		_notify("SHIELD IMPACT // TARGET DESTROYED", CYAN)
		return
	if not _circle_rect(enemy.pos, enemy.radius, _player_hitbox()): return
	if velocity_y > 80 and player.y < enemy.pos.y - enemy.radius * 0.35:
		velocity_y = -float(lab_panel.values.stomp_speed); enemy.touch_lock = 0.5
		if enemy.type == "heavy": _notify("HEAVY STOMP // SLIDE OFF", RED); _emit(enemy.pos, YELLOW, 14, 210)
		else: _kill_enemy(enemy); _notify("STOMP", CYAN)
	else: _receive(false, "ENEMY COLLISION")

func _round_targets() -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	for soldier in aerial_riflemen:
		if is_instance_valid(soldier) and not soldier.is_queued_for_deletion() and soldier.state != "dead":
			targets.append({"id":soldier.get_instance_id(),"kind":"drone","actor":soldier,"point":soldier.body_rect().get_center()})
	for turret in turrets:
		if is_instance_valid(turret) and not turret.is_queued_for_deletion() and turret.state not in [TurretBase.TurretState.BREAKING,TurretBase.TurretState.DEAD]:
			targets.append({"id":turret.get_instance_id(),"kind":"turret","actor":turret,"point":turret.hurt_collision.global_position})
	for gate in laser_gates:
		if is_instance_valid(gate) and not gate.is_queued_for_deletion() and gate.state == "Hover":
			# Aim at an actual drone hitbox, not the gap between laser emitters.
			targets.append({"id":gate.get_instance_id(),"kind":"gate","actor":gate,"point":gate.left_hit.global_position})
	for drone in kamikaze_drones:
		if is_instance_valid(drone) and not drone.is_queued_for_deletion() and drone.state != "explode":
			targets.append({"id":drone.get_instance_id(),"kind":"drone","actor":drone,"point":drone.body_rect().get_center()})
	for enemy in enemies:
		if enemy.dead: continue
		if not enemy.has("shot_target_id"):
			legacy_shot_target_serial += 1
			enemy.shot_target_id = -legacy_shot_target_serial
		targets.append({"id":enemy.shot_target_id,"kind":"legacy","actor":enemy,"point":enemy.pos})
	if boss_mode and is_mecha_boss() and mecha_actor.combat_enabled:
		targets.append({"id":mecha_actor.get_instance_id(),"kind":"mecha","actor":mecha_actor,"point":mecha_actor.core_position()})
	if boss_mode and not is_mecha_boss() and boss_actor.combat_enabled and boss_actor.attack_state not in [EyeballBoss.AttackState.ARMOR_BREAK,EyeballBoss.AttackState.DEAD]:
		targets.append({"id":boss_actor.get_instance_id(),"kind":"boss","actor":boss_actor,"point":boss_actor.global_position})
	return targets

func _round_hits_target(bullet: Dictionary, target: Dictionary) -> bool:
	if target.kind == "legacy":
		return _line_circle(bullet.previous,bullet.pos,target.actor.pos,target.actor.radius)
	return target.actor.shot_hits(bullet.previous,bullet.pos)

func _steer_homing_round(bullet: Dictionary, targets: Array[Dictionary], delta: float) -> void:
	var chosen: Dictionary = {}
	var nearest := INF
	for target in targets:
		if target.id in bullet.hit_ids: continue
		if int(target.id) == int(bullet.target_id):
			chosen = target
			break
		var distance_squared: float = bullet.pos.distance_squared_to(target.point)
		if distance_squared < nearest:
			nearest = distance_squared
			chosen = target
	if chosen.is_empty():
		bullet.target_id = 0
		return
	bullet.target_id = chosen.id
	var offset: Vector2 = chosen.point-bullet.pos
	var speed: float = bullet.velocity.length()
	if offset.length_squared() > 0.001:
		bullet.velocity = offset.normalized()*speed
	# At contact distance, end at the real hitbox center instead of overshooting
	# and repeatedly turning around it. Collision still resolves normally below.
	if offset.length() <= speed*delta:
		bullet.pos = chosen.point
	else:
		bullet.pos += bullet.velocity*delta

func _update_shots(delta: float) -> void:
	for i in range(shots.size()-1,-1,-1):
		var bullet: Dictionary = shots[i]
		bullet.previous = bullet.pos
		bullet.age = float(bullet.get("age",0.0))+delta
		if not bullet.has("hit_ids"): bullet.hit_ids = []
		var targets := _round_targets()
		if bool(bullet.get("homing",false)):
			var previous_position: Vector2 = bullet.pos
			_steer_homing_round(bullet,targets,delta)
			if bullet.pos == previous_position: bullet.pos += bullet.velocity*delta
		else:
			bullet.pos += bullet.velocity*delta
		# Resolve multiple crossed hitboxes in travel order, including same-frame hits.
		targets.sort_custom(func(a: Dictionary,b: Dictionary): return bullet.previous.distance_squared_to(a.point)<bullet.previous.distance_squared_to(b.point))
		var consumed := false
		for target in targets:
			if target.id in bullet.hit_ids or not _round_hits_target(bullet,target): continue
			bullet.hit_ids.append(target.id)
			match target.kind:
				"turret": target.actor.take_damage(int(bullet.penetration),bullet.pos)
				"gate": target.actor.take_damage()
				"drone": target.actor.take_damage(int(bullet.penetration))
				"legacy": _hit_enemy(target.actor,bullet)
				"boss": _hit_boss(bullet)
				"mecha": mecha_actor.receive_shot_segment(int(bullet.penetration),bullet.previous,bullet.pos)
			if int(bullet.get("pierce_left",0)) > 0:
				bullet.pierce_left -= 1
			else:
				consumed = true
				break
		var homing: bool = bool(bullet.get("homing",false))
		var outside: bool = bullet.pos.x > (1100 if homing else 1010) or bullet.pos.y < (40 if homing else 80) or bullet.pos.y > (800 if homing else 720)
		if consumed or outside or bullet.pos.x < -120 or bullet.age > 4.0:
			shots.remove_at(i)

func _hit_enemy(enemy: Dictionary, bullet: Dictionary) -> void:
	if enemy.armor > 0:
		if bullet.penetration >= enemy.armor: enemy.armor = 0; _emit(enemy.pos, YELLOW, 23, 245); _notify("ARMOR BROKEN", YELLOW)
		else:
			world_audio.play_cue("armor_ricochet")
			_emit(bullet.pos, WHITE, 13, 220); _notify("RICOCHET // USE PIERCER", WHITE)
		return
	enemy.hp -= 1
	if enemy.hp <= 0: _kill_enemy(enemy)

func _kill_enemy(enemy: Dictionary) -> void:
	if enemy.dead: return
	enemy.dead = true
	_award_enemy_kill(enemy.type, enemy.pos)

func _award_enemy_kill(enemy_type: String, origin: Vector2) -> void:
	var points: int = GD.SCORE.get(enemy_type,AERIAL.SCORE if enemy_type == "aerial" else KAMIKAZE.SCORE)
	stats[enemy_type] = int(stats.get(enemy_type,0))+1
	_register_kill(enemy_type, origin)
	score += points
	floaters.append({"pos": origin, "text": "+%d" % points, "color": YELLOW, "life": 0.85})
	_emit(origin, RED, 18, 205)

func _update_threats(delta: float) -> void:
	for i in range(threats.size() - 1, -1, -1):
		var bullet := threats[i]; bullet.pos += bullet.velocity * delta
		if guarding and guard_energy > 0 and not bullet.unblockable and _circle_rect(bullet.pos, bullet.radius, _guard_hitbox()):
			_consume_guard_hit()
			_emit(bullet.pos, CYAN, 14, 210)
			_notify("PARRY", CYAN, 0.25)
			threats.remove_at(i)
		elif _circle_rect(bullet.pos, bullet.radius, _player_hitbox()): _receive(bullet.unblockable, "HOSTILE FIRE"); threats.remove_at(i)
		elif bullet.pos.x < -50 or bullet.pos.x > 1020: threats.remove_at(i)

func _receive(unblockable: bool, cause: String) -> bool:
	if state != "playing": return false
	if not unblockable and not guarding and not _control_held("guard") and _upgrade("auto_guard") and guard_energy >= _guard_hit_cost() and guard_lock <= 0:
		auto_guard_left = 0.22
		guarding = true
		guard_idle = 0
		player_visual.set_motion(_grounded(), crouching, weapon_index, aim, true, true)
		world_audio.set_shield_active(true)
	if guarding and guard_energy > 0 and not unblockable:
		_consume_guard_hit(); _emit(_player_center(), CYAN, 18, 190); _notify("PARRY", CYAN)
		return true
	_die(cause)
	return false

func _die(cause: String) -> void:
	if not PLAYER_CAN_DIE: return
	if state != "playing": return
	world_audio.stop_all(true)
	weapon_audio.stop_all()
	lab.finish(score, cause, player, segment, boss_mode, true)
	retry_requested = false
	run_deaths += 1
	state = "dead"; death_delay = player_visual.death_animation_duration(); death_ui_ready = false
	banner = cause; _emit(_player_center(), RED, 40, 300)
	if endless_mode:
		_settle_run(false)
		overlays.record_result()
	if boss_mode:
		if is_mecha_boss(): mecha_actor.set_combat_enabled(false)
		else: boss_actor.set_combat_enabled(false)
		_clear_boss_attacks()
	player_visual.play_death()
	_refresh_player_ui()
	player_hud.follow_hitbox(_player_hitbox())

func _start_segment(index: int, preserve_motion := false) -> void:
	checkpoint_grenades = grenade_count
	music.play_track(false)
	segment = index; segment_time = 0; next_event = 0; segment_transition_pending = false; boss_mode = false
	next_budget_spawn_at = 0.0
	checkpoint_score = score; checkpoint_stats = stats.duplicate(true); checkpoint_ammo = ammo.duplicate()
	checkpoint_weapon_index = weapon_index; checkpoint_distance = distance
	_clear_world(); _reset_player(preserve_motion)
	lab.set_location(segment, false)
	if lab.active: lab.record("checkpoint_reached", {"score": score})
	player_visual.start_scrolling()
	if preserve_motion: player_visual.set_motion(_grounded(), crouching, weapon_index, aim, guarding, true)
	banner = (mode_caption() if endless_mode or selected_level > 0 else "CHECKPOINT") + " // " + str(current_segment().title)
	banner_time = 2

func is_mecha_boss() -> bool:
	return boss_test_mode and boss_test_kind == "mecha"

func _start_boss(preserve_motion := false) -> void:
	checkpoint_grenades = grenade_count
	boss_grenade_spawned = false
	music.play_track(true)
	boss_mode = true; segment_time = 0; segment_transition_pending = false; _clear_world(); _reset_player(preserve_motion)
	player_visual.start_scrolling()
	if preserve_motion: player_visual.set_motion(_grounded(), crouching, weapon_index, aim, guarding, true)
	checkpoint_score = score; checkpoint_stats = stats.duplicate(true); checkpoint_ammo = ammo.duplicate()
	checkpoint_weapon_index = weapon_index; checkpoint_distance = distance
	lab.set_location(segment, true)
	if lab.active: lab.record("checkpoint_reached", {"score": score})
	if is_mecha_boss():
		boss = {"armor":0,"hp":MECHA_DATA.HEALTH,"maximum":MECHA_DATA.HEALTH,"phase":1}
		mecha_actor.position = Vector2(GD.VIEW_SIZE.x+180.0,GD.GROUND_Y)
		mecha_actor.reset_for_battle(true)
		boss_entering = false
		return
	boss = {"armor": GD.BOSS.armor_per_cycle, "hp": GD.BOSS.health, "phase": 1}
	boss_actor.position = Vector2(GD.VIEW_SIZE.x + 220.0, BOSS_IDLE_Y)
	boss_actor.armor_per_layer = 3 if developer_mode else BALANCE.BOSS_ARMOR_PER_LAYER
	boss_actor.reset_for_battle(true)
	boss_actor.set_combat_enabled(false)
	boss_entering = true
	banner = mode_caption() + " // BOSS // BREAK ARMOR"; banner_time = 2.2

func _update_boss(delta: float) -> void:
	if state != "playing": return
	if not boss_grenade_spawned and segment_time >= 0.5:
		boss_grenade_spawned = true
		_spawn_grenade_pickup()
	if is_mecha_boss():
		mecha_actor.advance(delta)
		if mecha_actor.try_melee(_player_hitbox(),_guard_hitbox() if guarding else Rect2()):
			_receive(false,"MECHA BLADE")
		return
	if boss_entering:
		boss_actor.position = boss_actor.position.move_toward(Vector2(785.0, BOSS_IDLE_Y), 250.0 * delta)
		if boss_actor.position.is_equal_approx(Vector2(785.0, BOSS_IDLE_Y)):
			boss_entering = false
			boss_actor.set_combat_enabled(true)
		return
	# Finish the descent before releasing the low three-shot attack. Bombs and
	# barrage waves stay in the upper-right flight region.
	boss_actor.attack_position_ready = absf(boss_actor.position.y - BOSS_ATTACK_Y) < 1.0 if boss_actor.wants_low_flight() else boss_actor.position.y <= BOSS_IDLE_Y + 1.0
	boss_actor.advance(delta, _player_center())
	var flight_target := Vector2(785.0 + sin(segment_time * 0.7) * 65.0, 265.0 + cos(segment_time * 0.9) * 75.0)
	if boss_actor.wants_low_flight(): flight_target = Vector2(785.0, BOSS_ATTACK_Y)
	boss_actor.position = boss_actor.position.move_toward(flight_target, BOSS_FLIGHT_SPEED * delta)
	for i in range(boss_bombs.size() - 1, -1, -1):
		var bomb := boss_bombs[i]
		if not is_instance_valid(bomb):
			boss_bombs.remove_at(i)
			continue
		bomb.advance(delta, _scroll())
		if bomb.try_damage(_player_hitbox()):
			_receive(false, "BOSS BOMB")
			# Death clears both attack arrays; do not continue this iteration.
			if state != "playing": return
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
			if state != "playing": return
		if projectile.is_finished():
			projectile.queue_free()
			boss_particles.remove_at(i)

func _on_boss_bomb_requested(target_x: float) -> void:
	if state != "playing" or not boss_mode:
		return
	var bomb: BossBomb = BOSS_BOMB_SCENE.instantiate()
	boss_attack_root.add_child(bomb)
	bomb.launch(boss_attack_root.to_local(boss_actor.global_position), target_x)
	bomb.sound_requested.connect(func(cue: String, duration: float): world_audio.play_cue(cue, duration, bomb))
	boss_bombs.append(bomb)

func _on_boss_particle_requested(origin: Vector2) -> void:
	if state != "playing" or not boss_mode:
		return
	world_audio.play_cue("boss_particle_fire", -1.0, boss_actor)
	for spread in [-1.0, 0.0, 1.0]:
		var projectile: BossParticle = BOSS_PARTICLE_SCENE.instantiate()
		boss_attack_root.add_child(projectile)
		var direction := Vector2.LEFT.rotated(deg_to_rad(boss_actor.particle_spread_degrees * spread))
		projectile.launch(origin, direction)
		boss_particles.append(projectile)

func _on_boss_barrage_requested(origin: Vector2, wave: int) -> void:
	if state != "playing" or not boss_mode: return
	world_audio.play_cue("boss_particle_fire", -1.0, boss_actor)
	# Eight normal-sized rounds retain the broad fan with wider gaps.
	for ray in range(8):
		var projectile: BossParticle = BOSS_PARTICLE_SCENE.instantiate()
		projectile.speed = GD.BOSS.barrage_speed
		projectile.lifetime = 4.0
		boss_attack_root.add_child(projectile)
		var angle := deg_to_rad(lerpf(95.0, 265.0, float(ray) / 7.0) + (wave - 1) * 3.0)
		projectile.launch(origin, Vector2.from_angle(angle))
		boss_particles.append(projectile)

func _on_boss_feedback(origin: Vector2, color: Color, message: String) -> void:
	if not message.begins_with("BOSS TELEGRAPH"):
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
	if state != "playing" or boss.is_empty() or int(boss.hp) <= 0: return
	boss.hp -= 1
	boss.phase = 1 if is_mecha_boss() else int(boss_actor.form)+1
	_emit(_boss_pos(), WHITE, 45, 390)
	if boss.hp <= 0:
		score += GD.SCORE.boss
		_register_kill("boss", _boss_pos())
		if endless_mode:
			state = "intermission"
			endless_intermission = 1.0
			world_audio.stop_all()
			world_audio.play_cue("enemy_explode")
			weapon_audio.stop_all()
			if is_mecha_boss(): mecha_actor.start_death()
			else: boss_actor.start_death()
			_clear_boss_attacks()
			_notify("BOSS DOWN // WAVE %02d CLEARED" % endless_wave, CYAN, 1.2)
			return
		lab.finish(score, "victory", player, segment, boss_mode)
		state = "victory"
		_bank_remaining_coins()
		_settle_run(true)
		if play_profile != "development" and not boss_test_mode and not developer_mode:
			progression.unlock_after(selected_level)
		if not developer_mode and not boss_test_mode: overlays.record_result()
		world_audio.stop_all()
		world_audio.play_cue("enemy_explode")
		weapon_audio.stop_all()
		music.play_track(false)
		banner = "THE FRONT NEVER STOPS"
		if is_mecha_boss(): mecha_actor.start_death()
		else: boss_actor.start_death()
		_clear_boss_attacks()
		player_visual.show_idle()
	else:
		_notify("BOSS HIT // HP %d / %d" % [boss.hp, GD.BOSS.health], WHITE, 1)

func _request_retry(action: String) -> void:
	if state != "dead" or retry_requested: return
	retry_requested = true
	lab.request_retry(action)

func _retry() -> void:
	if state != "dead": return
	if endless_mode:
		_new_run("administrative_endless_restart")
		_gate_gameplay_input()
		return
	if not retry_requested: _request_retry("direct_retry")
	retry_requested = false
	state = "playing"
	if restart_mode == "campaign":
		_reset_campaign()
	else:
		score = checkpoint_score
		stats = checkpoint_stats.duplicate(true)
		ammo = checkpoint_ammo.duplicate()
		grenade_count = checkpoint_grenades
		weapon_index = checkpoint_weapon_index
		distance = checkpoint_distance
		if boss_mode: _start_boss()
		else: _start_segment(segment)
	_update_parallax()
	# Keep old failure context until the retry event has been attributed.
	lab.retry()
	_start_lab_run()

func _reset_campaign() -> void:
	_close_endless_reward()
	endless_talent_ranks.clear()
	endless_talent_effects.clear()
	endless_fire_count = 0
	endless_homing_round_count = 0
	manual_piercer_lock = false
	level_segments = CAMPAIGNS.segments(selected_level,not developer_mode)
	endless_wave = 1
	endless_intermission = 0
	if endless_mode: endless_wave_data = CAMPAIGNS.endless_wave(endless_wave,endless_difficulty)
	_apply_level_look()
	grenade_count = 0
	retry_requested = false
	weapon_index = 0
	ammo = [weapon_data(0).magazine, weapon_data(1).magazine]
	distance = 0
	score = 0
	stats = {"unarmored": 0, "light": 0, "heavy": 0, "flyer": 0}
	state = "playing"
	if boss_test_mode:
		segment = GD.CAMPAIGN_SEGMENT_COUNT - 1
		_start_boss()
	else:
		_start_segment(0)
	_update_parallax()

func _start_lab_run() -> void:
	lab.start(lab_panel.values, restart_mode, lab_panel.parameter_mode, segment, boss_mode, score)
	lab_panel.refresh_summary()

func _new_run(reason := "administrative_restart") -> void:
	run_record.clear()
	run_total_kills = 0
	run_total_shots = 0
	run_coins = 0
	settlement.clear()
	run_elapsed = 0
	run_deaths = 0
	player_hud.reset_run()
	lab.finish(score, reason, player, segment, boss_mode)
	lab.clear_pending_retry()
	_reset_campaign()
	_start_lab_run()
	queue_redraw()

func set_restart_mode(mode: String) -> void:
	if not developer_mode: return
	if mode not in ["checkpoint", "campaign"] or mode == restart_mode: return
	var previous := restart_mode
	lab.finish(score, "administrative_variant_switch", player, segment, boss_mode)
	lab.record("variant_switch", {"from_restart_mode": previous, "to_restart_mode": mode,
		"from_variant": "A" if previous == "checkpoint" else "B",
		"to_variant": "A" if mode == "checkpoint" else "B"})
	lab.clear_pending_retry()
	restart_mode = mode
	lab_panel.mode_selector.select(0 if mode == "checkpoint" else 1)
	if state != "start":
		_new_run("administrative_variant_switch")
		_gate_gameplay_input()
	else:
		lab.restart_mode = mode
		lab.variant = "A" if mode == "checkpoint" else "B"
	lab_panel.refresh_summary()

func _gate_gameplay_input() -> void:
	if attract_mode:
		lab_panel.blocked = false
		lab_panel.release_pending = false
		return
	lab_panel.blocked = true
	lab_panel.release_pending = not lab_panel.expanded
	lab_panel.release_frames = 1

func start_game(mode := "checkpoint", parameter_index := 0, development := false, boss_only := false, level_index := 0, infinite := false, test_boss := "eyeball") -> void:
	if state != "start": return
	if development or boss_only: _use_development_profile()
	elif not mission_unlocked(3 if infinite else clampi(level_index,0,2)): return
	boss_test_mode = boss_only
	boss_test_kind = "mecha" if boss_only and test_boss == "mecha" else "eyeball"
	developer_mode = development
	selected_level = 0 if development or boss_only else clampi(level_index, 0, CAMPAIGNS.LEVELS.size() - 1)
	endless_mode = infinite and not development and not boss_only
	lab.set_enabled(developer_mode)
	if developer_mode:
		set_restart_mode(mode)
	else:
		restart_mode = "campaign" if endless_mode else "checkpoint"
		parameter_index = 0
	lab_panel.mode_selector.select(0 if restart_mode == "checkpoint" else 1)
	lab_panel.apply_preset(parameter_index, false)
	start_screen.hide()
	if is_instance_valid(menu_demo): menu_demo.set_active(false)
	player_visual.show()
	if not attract_mode and has_node("/root/SceneFader"): get_node("/root/SceneFader").reveal()
	lab_panel.visible = developer_mode
	lab_panel.expanded = false
	lab_panel.panel.hide()
	_new_run()
	_gate_gameplay_input()
	if not attract_mode: get_tree().paused = false

func return_to_start() -> void:
	_close_endless_reward()
	endless_talent_ranks.clear()
	endless_talent_effects.clear()
	endless_fire_count = 0
	endless_homing_round_count = 0
	manual_piercer_lock = false
	_reset_death_camera()
	grenade_count = 0
	ui_paused = false
	weapon_audio.stop_all()
	music.return_to_menu()
	lab.finish(score, "administrative_return_to_start", player, segment, boss_mode)
	lab.clear_pending_retry()
	retry_requested = false
	state = "start"
	boss_test_mode = false
	selected_level = 0
	endless_mode = false
	_apply_level_look()
	_clear_world()
	boss_mode = false
	lab_panel.expanded = false
	lab_panel.panel.hide()
	lab_panel.blocked = true
	lab_panel.release_pending = false
	lab_panel.hide()
	start_screen.show()
	if is_instance_valid(menu_demo): menu_demo.set_active(true)
	player_visual.hide()
	if not attract_mode and has_node("/root/SceneFader"): get_node("/root/SceneFader").reveal()
	player_hud.hide()
	if not attract_mode: get_tree().paused = true
	queue_redraw()

func _reset_player(preserve_motion := false) -> void:
	_reset_death_camera()
	weapon_audio.stop_all()
	death_delay = 0.0
	death_ui_ready = false
	player_visual.set_primary_weapon(weapon_index)
	# Natural progression keeps the current jump/slide; retries still reset fully.
	if not preserve_motion:
		player = Vector2(GD.PLAYER_X, GD.GROUND_Y)
		velocity_y = 0
		crouching = false
		slide_time_left = 0.0
	guarding = false
	player_visual.position = player
	player_visual.set_collision_pose(crouching)
	auto_guard_left = 0; guard_energy = guard_capacity(); guard_idle = 0; guard_lock = 0; reload_left = 0; shot_left = 0; selected_slot = weapon_index
	_refresh_player_ui()
	player_hud.follow_hitbox(_player_hitbox())

func _clear_world() -> void:
	for soldier in aerial_riflemen:
		if is_instance_valid(soldier): soldier.queue_free()
	aerial_riflemen.clear()
	for drone in kamikaze_drones:
		if is_instance_valid(drone): drone.queue_free()
	kamikaze_drones.clear()
	world_audio.stop_all()
	boss_entering = false
	coin_drops.clear(); enemies.clear(); obstacles.clear(); pickups.clear(); shots.clear(); threats.clear()
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
	particles.clear(); floaters.clear(); notice = ""; notice_time = 0.0
	boss.clear()
	if is_instance_valid(boss_actor): boss_actor.reset_for_battle(false)
	if is_instance_valid(mecha_actor): mecha_actor.reset_for_battle(false)

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
	if lab_panel and not lab_panel.values.particles_enabled: return
	for i in range(count): particles.append({"pos": origin, "velocity": Vector2.from_angle(randf_range(0, TAU)) * randf_range(speed * 0.3, speed), "life": randf_range(0.18, 0.62), "color": color})

func _notify(text: String, color: Color, duration := 0.55) -> void:
	notice = text; notice_time = duration
	player_hud.toast_label.modulate = color

func _weapon() -> Dictionary:
	return weapon_data(weapon_index)

func weapon_data(index: int) -> Dictionary:
	var data: Dictionary = GD.WEAPONS[index].duplicate()
	data.magazine += int(_meta_effect("rifle_mag" if index == 0 else "piercer_mag"))
	data.projectile_speed *= 1.0 + _meta_effect("projectile")
	return data
func _reload_duration() -> float: return float(_weapon().reload) * float(lab_panel.values.reload_multiplier) * (1.0 + _meta_effect("reload"))
func _refresh_player_ui() -> void:
	# The current game is one-hit death; state is its only health source.
	player_hud.refresh(0 if state == "dead" else 1, 1, _weapon().name,
		_weapon().penetration, ammo[weapon_index], _weapon().magazine,
		reload_left, _reload_duration())
	player_hud.follow_hitbox(_player_hitbox())
func _slot_color() -> Color: return CYAN if selected_slot == 2 else _weapon().color
func _slot_name() -> String: return "GRENADE LAUNCHER" if selected_slot == 2 else _weapon().name
func _scroll() -> float: return (GD.BOSS.scroll if boss_mode else current_segment().scroll) * float(lab_panel.values.scroll_multiplier)
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
	if boss_mode and is_mecha_boss() and is_instance_valid(mecha_actor): return mecha_actor.position
	if boss_mode and is_instance_valid(boss_actor) and boss_actor.visible:
		return boss_actor.position
	return Vector2(785.0, BOSS_IDLE_Y)
func _circle_rect(center: Vector2, radius: float, rect: Rect2) -> bool:
	var closest := Vector2(clampf(center.x, rect.position.x, rect.end.x), clampf(center.y, rect.position.y, rect.end.y))
	return center.distance_squared_to(closest) <= radius * radius
func _line_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool: return Geometry2D.get_closest_point_to_segment(center, a, b).distance_to(center) <= radius

func _draw() -> void:
	for coin in coin_drops:
		draw_circle(coin.pos, 14, Color(1, 0.65, 0.1, 0.12))
		draw_texture_rect(COIN_TEXTURE, Rect2(coin.pos - Vector2(13,13), Vector2(26,26)), false)
	for pickup in pickups:
		draw_circle(pickup.pos, 31, Color(1.0, 0.7, 0.15, 0.18))
		var marker := PackedVector2Array([pickup.pos + Vector2(0, -34), pickup.pos + Vector2(33, 0), pickup.pos + Vector2(0, 34), pickup.pos + Vector2(-33, 0), pickup.pos + Vector2(0, -34)])
		draw_polyline(marker, Color(1.0, 0.75, 0.22, 0.85), 2)
		draw_polyline(PackedVector2Array([pickup.pos + Vector2(-9, -47), pickup.pos + Vector2(0, -39), pickup.pos + Vector2(9, -47)]), Color("ffb32e"), 3)
		draw_texture_rect(GRENADE_TEXTURE, Rect2(pickup.pos - Vector2(24, 24), Vector2(48, 48)), false)
	for object in obstacles: _draw_obstacle(object)
	for bullet in threats:
		var threat_color: Color = bullet.get("color", RED)
		draw_circle(bullet.pos, bullet.radius + float(bullet.get("glow",8.0)), Color(threat_color, 0.12))
		draw_circle(bullet.pos, bullet.radius, threat_color)
	for bullet in shots: _draw_player_shot(bullet)
	for particle in particles: draw_circle(particle.pos, 3, Color(particle.color, clampf(particle.life * 2, 0, 1)))
	if state == "playing" and not ui_paused and not attract_mode: _draw_reticle()

func _draw_player_shot(bullet: Dictionary) -> void:
	var direction: Vector2 = bullet.velocity.normalized()
	var tip: Vector2 = bullet.pos
	var color: Color = bullet.color
	if bullet.get("style", "bullet") == "laser":
		var tail := tip - direction * 56.0
		draw_line(tail, tip, Color(color, 0.22), 8.0)
		draw_line(tail, tip, color, 4.0)
		draw_line(tail, tip, Color("d5efff"), 1.5)
	else:
		draw_line(tip - direction * 14.0, tip, color, 4.0)
		draw_circle(tip, 2.0, Color("ffe0a3"))

func _draw_reticle() -> void:
	var color := UIPalette.AMBER
	if reload_left > 0 or (selected_slot != 2 and ammo[weapon_index] == 0): color = UIPalette.TEXT_DIM
	else:
		for turret in turrets:
			if is_instance_valid(turret) and turret.body_rect().has_point(aim): color = UIPalette.RED
		if boss_mode and aim.distance_to(boss_actor.position) < 80: color = UIPalette.RED
	draw_arc(aim, 11, 0, TAU, 20, color, 2)
	for axis in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		draw_line(aim + axis * 7, aim + axis * 17, color, 2)

func _draw_obstacle(object: Dictionary) -> void:
	if object.type == "barrel" and object.shot: return
	var rect: Rect2 = object.rect; rect.position += Vector2(object.x, GD.GROUND_Y)
	draw_rect(rect, YELLOW if object.type == "barrel" else Color("69758a"))
	if object.type == "barrel": draw_string(ThemeDB.fallback_font, rect.position + Vector2(3, -8), "SHOOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, YELLOW)
	else: draw_line(rect.position + Vector2(8, 8), rect.end - Vector2(8, 8), WHITE, 3)

func lab_parameters_changed(key: String, manual := true) -> void:
	if not developer_mode: return
	if manual: lab_panel.mark_custom()
	lab.finish(score, "administrative_parameter_change", player, segment, boss_mode)
	lab.record("parameter_change", {"changed": key, "new_parameters": lab_panel.values.duplicate(true),
		"new_parameter_mode": lab_panel.parameter_mode})
	if state != "start":
		_new_run("administrative_parameter_change")
		_gate_gameplay_input()
	else:
		lab.snapshot = lab_panel.values.duplicate(true)
		lab.parameter_mode = lab_panel.parameter_mode
	lab_panel.refresh_summary()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		lab.finish(score, "window_close", player, segment, boss_mode)

func set_ui_paused(value: bool) -> void:
	if state not in ["playing", "intermission"]: return
	ui_paused = value
	queue_redraw()
	if not attract_mode: get_tree().paused = value
	if value:
		weapon_audio.stop_all()
		lab.record("ui_pause")
	else:
		lab.record("ui_resume")
		_gate_gameplay_input()

func _start_death_camera() -> void:
	death_camera_started = true
	var sprite := player_visual.body
	var image := sprite.sprite_frames.get_frame_texture(&"death", sprite.sprite_frames.get_frame_count(&"death") - 1).get_image()
	var local_center := Vector2(image.get_used_rect().get_center()) - Vector2(image.get_size()) * 0.5 + sprite.offset
	var focus := sprite.to_global(local_center)
	var zoom := 1.35
	var screen_anchor := Vector2(GD.VIEW_SIZE.x * 0.5, GD.VIEW_SIZE.y * 0.62)
	var target := Transform2D(Vector2(zoom, 0), Vector2(0, zoom), screen_anchor - focus * zoom)
	death_camera_tween = create_tween()
	if settings.options.death_camera:
		death_camera_tween.tween_property(get_viewport(), "canvas_transform", target, DEATH_CAMERA_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	death_camera_tween.tween_interval(DEATH_CAMERA_HOLD)
	death_camera_tween.tween_callback(func(): death_ui_ready = true)

func _reset_death_camera() -> void:
	if death_camera_tween: death_camera_tween.kill()
	death_camera_started = false
	death_ui_ready = false
	get_viewport().canvas_transform = Transform2D.IDENTITY

func start_level(index: int) -> void:
	start_game("checkpoint", 0, false, false, index)

func start_endless(difficulty := "") -> void:
	if state != "start" or not mission_unlocked(3): return
	if not difficulty.is_empty():
		endless_difficulty = difficulty if difficulty in ["easy","normal","hard"] else "normal"
	start_game("campaign", 0, false, false, 0, true)

func next_level() -> void:
	if state != "victory" or developer_mode or boss_test_mode or selected_level >= CAMPAIGNS.LEVELS.size() - 1: return
	selected_level += 1
	_new_run()
	_gate_gameplay_input()

func current_segment() -> Dictionary:
	if endless_mode and not endless_wave_data.is_empty(): return endless_wave_data
	if level_segments.is_empty(): return GD.SEGMENTS[segment]
	return level_segments[segment]

func current_stage_name() -> String:
	return str(current_segment().title).get_slice("//", 1).strip_edges()

func mode_caption() -> String:
	if endless_mode: return "ENDLESS / %s / WAVE %02d" % [endless_difficulty.to_upper(),endless_wave]
	if boss_test_mode: return "MECHA BOSS TEST" if is_mecha_boss() else "EYEBALL BOSS TEST"
	return "LEVEL %02d" % (selected_level + 1)

func record_key() -> String:
	if endless_mode: return "endless_best_score" if endless_difficulty == "normal" else "endless_%s_best_score" % endless_difficulty
	return "best_score" if selected_level == 0 else "level_%d_best_score" % (selected_level + 1)

func _advance_endless() -> void:
	if state == "talent": return
	_bank_remaining_coins()
	_clear_world()
	boss_mode = false
	state = "talent"
	guarding = false
	auto_guard_left = 0.0
	world_audio.stop_all()
	weapon_audio.stop_all()
	endless_talent_choices = preload("res://endless_talents.gd").roll(endless_talent_ranks)
	if attract_mode:
		choose_endless_talent(endless_talent_choices[0])
		return
	endless_reward_ui = preload("res://ui/endless_reward.gd").new()
	endless_reward_ui.game = self
	endless_reward_ui.choices = endless_talent_choices.duplicate()
	add_child(endless_reward_ui)

func _close_endless_reward() -> void:
	if is_instance_valid(endless_reward_ui):
		endless_reward_ui.hide()
		endless_reward_ui.queue_free()
	endless_reward_ui = null
	endless_talent_choices.clear()

func choose_endless_talent(id: String) -> void:
	if state != "talent" or id not in endless_talent_choices: return
	var data: Dictionary = preload("res://endless_talents.gd").POOL[id]
	endless_talent_ranks[id] = int(endless_talent_ranks.get(id,0))+1
	for key in data.effects:
		endless_talent_effects[key] = float(endless_talent_effects.get(key,0.0))+float(data.effects[key])
	match id:
		"grenade": grenade_count += 2
		"battery": guard_energy = minf(guard_capacity(),guard_energy+20.0)
		"ammo":
			ammo = [weapon_data(0).magazine,weapon_data(1).magazine]
			reload_left = 0.0
			grenade_count += 1
	state = "talent_exit"
	endless_talent_choices.clear()
	if is_instance_valid(endless_reward_ui):
		endless_reward_ui.retract(_finish_endless_selection)
	else:
		_finish_endless_selection()

func _finish_endless_selection() -> void:
	if state != "talent_exit": return
	_close_endless_reward()
	_continue_endless()
	_gate_gameplay_input()

func _continue_endless() -> void:
	endless_wave += 1
	state = "playing"
	if endless_wave % 5 == 0:
		segment = 3
		_start_boss(true)
	else:
		endless_wave_data = CAMPAIGNS.endless_wave(endless_wave,endless_difficulty)
		_start_segment((endless_wave - 1) % 5, true)

func _apply_level_look() -> void:
	var tint: Color = CAMPAIGNS.LEVELS[selected_level].tint
	background_layer.modulate = tint
	middle_layer.modulate = tint
	track_layer.modulate = tint

func _meta_enabled() -> bool:
	return not developer_mode and not boss_test_mode and not ui_preview

func _meta_effect(key: String) -> float:
	var value: float = progression.effect(key) if _meta_enabled() and is_instance_valid(progression) else 0.0
	if endless_mode and _meta_enabled(): value += float(endless_talent_effects.get(key,0.0))
	if key == "reload": return maxf(-0.75,value)
	if key == "cadence": return maxf(-0.65,value)
	if key == "drain": return maxf(-0.7,value)
	return value

func _upgrade(id: String) -> bool:
	return _meta_enabled() and is_instance_valid(progression) and progression.has_upgrade(id)

func guard_capacity() -> float:
	return GD.GUARD.maximum + _meta_effect("capacity")

func guard_regen() -> float:
	if developer_mode: return float(lab_panel.values.guard_regen)
	if _upgrade("fast_regen"): return (50.0 + (float(endless_talent_effects.get("regen",0.0)) if endless_mode else 0.0)) * BALANCE.GUARD_REGEN_MULTIPLIER
	return (12.5 + _meta_effect("regen")) * BALANCE.GUARD_REGEN_MULTIPLIER

func _register_kill(kind: String, origin: Vector2) -> void:
	run_total_kills += 1
	if not _meta_enabled(): return
	if _meta_effect("kill_grenade") > 0 and run_total_kills % 8 == 0:
		grenade_count += 1
	guard_energy = minf(guard_capacity(), guard_energy + _meta_effect("kill_energy"))
	var value: int = preload("res://build_data.gd").COIN_VALUES.get(kind, 3)
	var count := mini(value, 5)
	for i in range(count):
		coin_drops.append({"pos": Vector2(origin.x, minf(origin.y - 22, GD.GROUND_Y - 24)),
			"vx": lerpf(-130.0, 130.0, float(i) / maxf(1, count - 1)),
			"vy": randf_range(-280, -190), "landed": false, "bounced": false,
			"value": int(value / count) + (1 if i < value % count else 0)})

func _update_coins(delta: float) -> void:
	for i in range(coin_drops.size() - 1, -1, -1):
		var coin: Dictionary = coin_drops[i]
		var target := player + Vector2(0, -18)
		if not coin.landed:
			coin.pos.x += (float(coin.vx) - _scroll()) * delta
			coin.vy += 650 * delta
			coin.pos.y += float(coin.vy) * delta
			if coin.pos.y >= GD.GROUND_Y - 10:
				coin.pos.y = GD.GROUND_Y - 10
				if not coin.bounced:
					coin.vy = -absf(coin.vy) * 0.24
					coin.bounced = true
				else:
					coin.vy = 0.0
					coin.landed = true
				coin.vx = move_toward(coin.vx, 0, 550 * delta)
		if coin.landed:
			# Homing coins leave world scrolling/gravity so they can also catch
			# a jumping player or return from behind the player.
			coin.pos = coin.pos.move_toward(target, 720 * delta)
		if coin.landed and _player_hitbox().grow(24 + _meta_effect("pickup")).has_point(coin.pos):
			if progression.credit(int(coin.value)):
				run_coins += int(coin.value)
				world_audio.play_coin_pickup()
				floaters.append({"pos": coin.pos, "text": "+%d G" % coin.value, "color": YELLOW, "life": 0.65})
				coin_drops.remove_at(i)

func _bank_remaining_coins() -> void:
	if not _meta_enabled(): return
	var amount := 0
	for coin in coin_drops: amount += int(coin.value)
	if amount > 0 and progression.credit(amount):
		run_coins += amount
		coin_drops.clear()

func _settle_run(completed: bool) -> void:
	if not settlement.is_empty() or not _meta_enabled(): return
	var bonus := run_total_kills * 2 + (40 + selected_level * 20 if completed else maxi(0, endless_wave - 1) * 3)
	settlement = {"bonus": bonus, "paid": bonus == 0 or progression.credit(bonus)}

func _auto_select_weapon() -> void:
	if not _upgrade("auto_weapon") or manual_piercer_lock or selected_slot == 2 or reload_left > 0: return
	var armor := 0
	var nearest := INF
	var origin := player_visual.muzzle_world_position()
	var ray_end := origin + (aim - origin).normalized() * 1600.0
	for turret in turrets:
		if not is_instance_valid(turret) or turret.state in [TurretBase.TurretState.DEAD, TurretBase.TurretState.BREAKING]: continue
		if turret.body_rect().grow(8).has_point(aim) or turret.shot_hits(origin, ray_end):
			var distance_to_target := origin.distance_squared_to(turret.body_rect().get_center())
			if distance_to_target < nearest:
				nearest = distance_to_target
				armor = 3 if turret.turret_kind == TurretBase.TurretKind.HEAVY and turret.state != TurretBase.TurretState.EXPOSED else 0
	if boss_mode and is_mecha_boss() and mecha_actor.combat_enabled and mecha_actor.shot_hits(origin,ray_end):
		var distance_to_target: float = origin.distance_squared_to(mecha_actor.core_position())
		if distance_to_target < nearest:
			nearest = distance_to_target
			armor = mecha_actor.required_penetration(origin,ray_end)
	if boss_mode and not is_mecha_boss() and boss_actor.combat_enabled and boss_actor.shot_hits(origin, ray_end):
		var distance_to_target := origin.distance_squared_to(_boss_pos())
		if distance_to_target < nearest:
			nearest = distance_to_target
			armor = 3 if boss_actor.armor_layers() > 0 else 0
	for enemy in enemies:
		if not enemy.dead and _line_circle(origin, ray_end, enemy.pos, enemy.radius):
			var distance_to_target := origin.distance_squared_to(enemy.pos)
			if distance_to_target < nearest:
				nearest = distance_to_target
				armor = int(enemy.armor)
	for gate in laser_gates:
		if is_instance_valid(gate) and gate.shot_hits(origin, ray_end):
			var distance_to_target := origin.distance_squared_to(gate.global_position)
			if distance_to_target < nearest:
				nearest = distance_to_target
				armor = 0
	for drone in kamikaze_drones:
		if is_instance_valid(drone) and drone.shot_hits(origin,ray_end):
			var distance_to_target: float = origin.distance_squared_to(drone.global_position)
			if distance_to_target < nearest:
				nearest = distance_to_target
				armor = 0
	for soldier in aerial_riflemen:
		if is_instance_valid(soldier) and soldier.shot_hits(origin,ray_end):
			var distance_to_target: float = origin.distance_squared_to(soldier.global_position)
			if distance_to_target < nearest:
				nearest = distance_to_target
				armor = 0
	var desired := _best_weapon_for_armor(armor)
	if desired != weapon_index: _select_slot(desired,true)

func _best_weapon_for_armor(required: int) -> int:
	var best := 0
	var best_dps := -1.0
	for index in range(GD.WEAPONS.size()):
		var data := weapon_data(index)
		if int(data.penetration) < required: continue
		# Both guns inflict one hit. Include magazine and reload in sustained DPS.
		var cadence := float(lab_panel.values.rifle_cadence if index == 0 else lab_panel.values.piercer_cadence) * (1.0 + _meta_effect("cadence"))
		var reload_time := float(data.reload) * float(lab_panel.values.reload_multiplier) * (1.0 + _meta_effect("reload"))
		var dps := float(data.magazine) / (float(data.magazine) * cadence + reload_time)
		if dps > best_dps:
			best_dps = dps
			best = index
	return best

func _control_held(action: String) -> bool:
	return bool(attract_input.get(action,false)) if attract_mode else Input.is_action_pressed(action)

func _control_tapped(action: String) -> bool:
	return bool(attract_taps.get(action,false)) if attract_mode else Input.is_action_just_pressed(action)

func mission_unlocked(index: int) -> bool:
	return play_profile == "development" or index <= progression.unlocked_stage

func _use_development_profile() -> void:
	progression = development_profile
	play_profile = "development"
	if is_instance_valid(session_profile):
		session_profile.queue_free()
		session_profile = null

func open_player_session() -> void:
	if state != "start": return
	if play_profile == "development": enter_guest_session()
	else: start_screen.show_levels(true)

func enter_guest_session() -> void:
	if state != "start": return
	_use_development_profile()
	session_profile = preload("res://progression.gd").new()
	session_profile.preview_only = true
	session_profile.coins = 0
	session_profile.unlocked_stage = 0
	add_child(session_profile)
	progression = session_profile
	play_profile = "guest"
	run_record.clear()
	start_screen.show_levels(true)

func enter_development_session() -> void:
	if state != "start": return
	_use_development_profile()
	run_record.clear()
	start_screen.show_levels(true)

func enter_named_session(player_name: String) -> bool:
	if state != "start": return false
	var clean_name := player_name.strip_edges().left(32)
	if clean_name.is_empty(): return false
	var next_profile := preload("res://progression.gd").new()
	next_profile.configure_named(clean_name)
	add_child(next_profile)
	if next_profile.load_failed:
		next_profile.queue_free()
		return false
	_use_development_profile()
	session_profile = next_profile
	progression = next_profile
	play_profile = "named"
	run_record.clear()
	start_screen.show_levels(true)
	return true

func _guard_hit_cost() -> float:
	return 7.0 if developer_mode else maxf(6.0,BALANCE.GUARD_HIT_COST-_meta_effect("hit_saving"))

func _guard_drain() -> float:
	return float(lab_panel.values.guard_drain) * (1.0 + _meta_effect("drain")) * (1.0 if developer_mode else BALANCE.GUARD_DRAIN_MULTIPLIER)

func _guard_delay() -> float:
	return maxf(0.0, float(lab_panel.values.guard_delay) + _meta_effect("regen_delay") + (0.0 if developer_mode else BALANCE.GUARD_EXTRA_DELAY))

func _consume_guard_hit() -> void:
	guard_energy = maxf(0.0, guard_energy - _guard_hit_cost())
	guard_idle = 0
	if guard_energy <= 0:
		guarding = false
		auto_guard_left = 0
		guard_lock = maxf(0.1,float(lab_panel.values.guard_lock)+_meta_effect("guard_lock"))

func _auto_reload_empty() -> void:
	if state == "playing" and selected_slot != 2 and _upgrade("auto_weapon") and ammo[weapon_index] <= 0 and reload_left <= 0 and shot_left <= 0:
		_reload()

func _update_kamikaze_drones(delta: float) -> void:
	for index in range(kamikaze_drones.size()-1,-1,-1):
		var drone = kamikaze_drones[index]
		if not is_instance_valid(drone):
			kamikaze_drones.remove_at(index)
			continue
		drone.advance(delta,_scroll(),_player_center())
		if guarding and guard_energy > 0 and drone.state != "explode" and drone.body_rect().intersects(_guard_hitbox()):
			drone.force_kill()
			_consume_guard_hit()
		elif drone.try_damage(_player_hitbox()):
			_receive(false,"KAMIKAZE DRONE")
			if state != "playing": return
		if drone.is_finished():
			drone.queue_free()
			kamikaze_drones.remove_at(index)

func endless_wave_record_key() -> String:
	return "endless_best_wave" if endless_difficulty == "normal" else "endless_%s_best_wave" % endless_difficulty

func _update_aerial_riflemen(delta: float) -> void:
	for index in range(aerial_riflemen.size()-1,-1,-1):
		var soldier: Node2D = aerial_riflemen[index]
		if not is_instance_valid(soldier):
			aerial_riflemen.remove_at(index)
			continue
		soldier.advance(delta,_scroll(),_player_center())
		if soldier.state != "dead":
			if guarding and guard_energy > 0 and soldier.body_rect().intersects(_guard_hitbox()):
				soldier.force_kill()
				_consume_guard_hit()
			elif soldier.contact_left <= 0 and soldier.body_rect().intersects(_player_hitbox()):
				soldier.contact_left = 0.8
				_receive(false,"AERIAL RIFLEMAN")
				if state != "playing": return
		if soldier.is_finished():
			soldier.queue_free()
			aerial_riflemen.remove_at(index)

func refresh_boss_hud(hud: Node) -> void:
	if is_mecha_boss():
		hud.apply_mecha_state(int(boss.hp),int(boss.get("maximum",MECHA_DATA.HEALTH)))
	else:
		hud.apply_state(boss.hp,GD.BOSS.health,boss.armor,boss.phase,boss_actor.armor_points(),boss_actor.armor_per_layer*2)
