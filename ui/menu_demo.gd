extends Node2D
# Runs the actual main.tscn in a separate world. This node only supplies controls.
const GD := preload("res://game_data.gd")
var game: Node
var session: Node
var viewport: SubViewport
var picture: Sprite2D
var active := false
var previous: Dictionary = {}
var victory_wait := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -100
	viewport = SubViewport.new()
	viewport.size = Vector2i(960,720)
	viewport.disable_3d = true
	viewport.world_2d = World2D.new()
	viewport.gui_disable_input = true
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	picture = Sprite2D.new()
	picture.centered = false
	picture.texture = viewport.get_texture()
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(picture)
	hide()

func set_active(value: bool) -> void:
	active = value
	visible = value
	previous.clear()
	victory_wait = 0
	if is_instance_valid(session):
		viewport.remove_child(session)
		session.queue_free()
		session = null
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if value else SubViewport.UPDATE_DISABLED
	if not value: return
	# Use a runtime load to avoid recursively preloading main -> menu -> main.
	session = load("res://main.tscn").instantiate()
	session.attract_mode = true
	session.attract_settings = game.settings
	session.process_mode = Node.PROCESS_MODE_ALWAYS
	session.process_priority = -50
	viewport.add_child(session)
	session.start_level(0)

func _process(delta: float) -> void:
	if not active or not is_instance_valid(session): return
	if game.state != "start": set_active(false); return
	var actions := {}
	if session.state == "dead":
		if session.death_ui_ready: actions.restart = true
	elif session.state == "victory":
		victory_wait += delta
		if victory_wait >= 2.5:
			victory_wait = 0
			if session.selected_level < 2: session.next_level()
			else:
				session.selected_level = 0
				session._new_run()
	elif session.state == "playing":
		actions = choose_controls()
	session.attract_taps.clear()
	for action in actions:
		if bool(actions[action]) and not bool(previous.get(action,false)): session.attract_taps[action] = true
	session.attract_input = actions
	previous = actions.duplicate()

func choose_controls() -> Dictionary:
	var actions := {}
	var target := Vector2(850,500)
	var required := 0
	var distance_to_target := INF
	var has_target := false
	for turret in session.turrets:
		if not is_instance_valid(turret) or turret.state in [TurretBase.TurretState.DEAD,TurretBase.TurretState.BREAKING]: continue
		var center: Vector2 = turret.body_rect().get_center()
		if center.x < session.player.x+30 or center.x > 1020: continue
		var dx: float = center.x-session.player.x
		if dx < distance_to_target:
			distance_to_target = dx
			target = center
			has_target = true
			required = 3 if turret.turret_kind == TurretBase.TurretKind.HEAVY and turret.state != TurretBase.TurretState.EXPOSED else 0
	for gate in session.laser_gates:
		if not is_instance_valid(gate) or gate.state != "Hover": continue
		var center: Vector2 = gate.left_hit.global_position
		if center.x > session.player.x and center.x-session.player.x < distance_to_target:
			distance_to_target = center.x-session.player.x
			target = center
			has_target = true
			required = 0
	for drone in session.kamikaze_drones:
		if not is_instance_valid(drone) or drone.state == "explode": continue
		var dx: float = drone.position.x-session.player.x
		if dx > 0 and dx < distance_to_target:
			distance_to_target = dx
			target = drone.global_position
			has_target = true
			required = 0
	for drone in session.aerial_riflemen:
		if not is_instance_valid(drone) or drone.state == "dead": continue
		var dx: float = drone.position.x-session.player.x
		if dx > 0 and dx < distance_to_target:
			distance_to_target = dx
			target = drone.global_position
			has_target = true
			required = 0
	if session.boss_mode and session.boss_actor.combat_enabled:
		target = session.boss_actor.position
		required = 3 if session.boss_actor.armor_layers()>0 else 0
		has_target = true
	session.aim = target
	var weapon: int = session._best_weapon_for_armor(required)
	if session.weapon_index != weapon and session.reload_left <= 0:
		actions["weapon_slot_%d" % (weapon+1)] = true
	if session.ammo[session.weapon_index] <= 0: actions.reload = true
	actions.fire = has_target
	var jump := false
	for spikes in session.ground_spikes:
		if is_instance_valid(spikes):
			var dx: float = spikes.position.x-session.player.x
			if dx > -85 and dx < 225: jump = true
	for obstacle in session.obstacles:
		if obstacle.danger and obstacle.x-session.player.x > -50 and obstacle.x-session.player.x < 210: jump = true
	if jump: actions.jump = true
	for gate in session.laser_gates:
		if is_instance_valid(gate) and gate.state == "Hover":
			var hazard: Rect2 = gate.hazard_rect()
			if not jump and hazard.position.x-session.player.x < 220 and hazard.end.x>session.player.x-45: actions.crouch = true
	var danger := false
	for bullet in session.threats:
		if not bullet.unblockable and bullet.pos.distance_to(session._player_center()) < 190: danger = true
	for turret in session.turrets:
		if is_instance_valid(turret) and turret.state == TurretBase.TurretState.FIRING: danger = true
	for bullet in session.boss_particles:
		if is_instance_valid(bullet) and bullet.global_position.distance_to(session._player_center()) < 220: danger = true
	for bomb in session.boss_bombs:
		if is_instance_valid(bomb) and bomb.global_position.distance_to(session._player_center()) < 220: danger = true
	for drone in session.kamikaze_drones:
		if is_instance_valid(drone) and drone.position.distance_to(session._player_center()) < 155: danger = true
	if danger and session.guard_energy >= 12: actions.guard = true
	if danger and session.has_grenade and (session.boss_particles.size()>8 or session.threats.size()>7): actions.use_grenade = true
	return actions
