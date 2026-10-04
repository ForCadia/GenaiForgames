extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var light: TurretBase = load("res://LightTurret.tscn").instantiate()
	root.add_child(light)
	await process_frame
	assert(light.sprite.sprite_frames.get_frame_count(&"idle") == 2)
	assert(light.sprite.sprite_frames.get_frame_count(&"shoot") == 2)
	assert(light.sprite.sprite_frames.get_frame_count(&"damaged_idle") == 1)
	assert(light.sprite.sprite_frames.get_frame_count(&"damaged_shoot") == 2)
	assert(light.sprite.sprite_frames.get_frame_count(&"explode") == 2)
	assert(light.sprite.scale == Vector2(0.7, 0.7))
	assert(light.solid_collision.shape.size == Vector2(82, 62))
	assert(light.muzzle.position == Vector2(-42, -48))
	var light_kills := [0]
	light.killed.connect(func(_turret, kind):
		assert(kind == "unarmored")
		light_kills[0] += 1
	)
	light.take_damage(1, Vector2.ZERO)
	assert(light.health == 1 and light.state == TurretBase.TurretState.DAMAGED)
	assert(light.sprite.animation == &"damaged_idle")
	light.take_damage(3, Vector2.ZERO)
	assert(light.state == TurretBase.TurretState.DEAD and light_kills[0] == 1)
	light.take_damage(3, Vector2.ZERO)
	assert(light_kills[0] == 1)

	var heavy: TurretBase = load("res://HeavyTurret.tscn").instantiate()
	root.add_child(heavy)
	await process_frame
	assert(heavy.sprite.sprite_frames.get_frame_count(&"armor_break") == 3)
	assert(heavy.sprite.sprite_frames.get_frame_count(&"explode") == 2)
	assert(heavy.solid_collision.shape.size == Vector2(100, 70))
	assert(heavy.muzzle.position == Vector2(-55, -59))
	heavy.take_damage(1, Vector2.ZERO)
	assert(heavy.state == TurretBase.TurretState.ACTIVE)
	heavy.take_damage(3, Vector2.ZERO)
	assert(heavy.state == TurretBase.TurretState.BREAKING and heavy.hurt_collision.disabled)
	heavy.take_damage(3, Vector2.ZERO)
	assert(heavy.state == TurretBase.TurretState.BREAKING)
	await create_timer(0.35).timeout
	assert(heavy.state == TurretBase.TurretState.EXPOSED and not heavy.hurt_collision.disabled)
	var heavy_kills := [0]
	heavy.killed.connect(func(_turret, kind):
		assert(kind == "heavy")
		heavy_kills[0] += 1
	)
	heavy.take_damage(1, Vector2.ZERO)
	assert(heavy.state == TurretBase.TurretState.DEAD and heavy_kills[0] == 1)

	var gun: TurretBase = load("res://LightTurret.tscn").instantiate()
	root.add_child(gun)
	await process_frame
	gun.position = Vector2(500, GameData.GROUND_Y)
	var projectile := [{}]
	gun.projectile_requested.connect(func(origin, direction, speed, color):
		projectile[0] = {"origin": origin, "direction": direction, "speed": speed, "color": color}
	)
	gun.target_position = Vector2(-200, -30)
	gun._on_attack_timeout()
	assert(not projectile[0].is_empty())
	assert(projectile[0].direction == Vector2.LEFT and projectile[0].speed == 520.0)
	assert(projectile[0].color == Color("ffcf70"))
	var entry_gun: TurretBase = load("res://LightTurret.tscn").instantiate()
	root.add_child(entry_gun)
	await process_frame
	entry_gun.position = Vector2(925, GameData.GROUND_Y)
	var entry_shots := [0]
	entry_gun.projectile_requested.connect(func(_o, direction, _s, _c):
		assert(direction == Vector2.LEFT)
		entry_shots[0] += 1
	)
	entry_gun.advance(0.02, 300.0, Vector2(190, GameData.GROUND_Y))
	assert(entry_gun.position.x == 919.0 and entry_shots[0] == 1)

	var laser: TurretBase = load("res://HeavyTurret.tscn").instantiate()
	root.add_child(laser)
	await process_frame
	laser.position = Vector2(700, GameData.GROUND_Y)
	laser._on_attack_timeout()
	assert(laser.state == TurretBase.TurretState.CHARGING and laser.telegraph.visible)
	assert(not laser.beam.visible and laser.laser_collision.disabled)
	laser.advance(laser.charge_time, 0.0, Vector2(190, 570))
	assert(laser.state == TurretBase.TurretState.CHARGING and laser.telegraph.visible)
	laser.position.x = laser.laser_fire_x
	laser.advance(0.0, 0.0, Vector2(190, 570))
	assert(laser.state == TurretBase.TurretState.FIRING and laser.beam.visible)
	assert(not laser.telegraph.visible and not laser.laser_collision.disabled)
	assert(is_equal_approx(laser.laser_rect().size.x, laser.laser_length))
	assert(laser.try_laser_damage(Rect2(171, 528, 38, 92)))
	assert(not laser.try_laser_damage(Rect2(171, 528, 38, 92)))
	laser.advance(laser.laser_duration, 0.0, Vector2(190, 570))
	assert(not laser.beam.visible and laser.laser_collision.disabled)

	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game.set_process(false)
	var enemy_count: int = game.enemies.size()
	game._spawn_enemy("unarmored", 0.0, false)
	game._spawn_enemy("heavy", 0.0, false)
	assert(game.turrets.size() == 2 and game.enemies.size() == enemy_count)
	game._spawn_enemy("light", 0.0, false)
	game._spawn_enemy("flyer", -100.0, false)
	assert(game.turrets.size() == 3 and game.enemies.size() == enemy_count)
	assert(game.turrets[0].position == Vector2(1020, GameData.GROUND_Y))
	var old_x: float = game.turrets[0].position.x
	var old_distance: float = game.distance
	game._update_world(0.1)
	assert(is_equal_approx(game.turrets[0].position.x, old_x - game._scroll() * 0.1))
	game._update_parallax()
	assert(game.get_node("Track").scroll_offset.x == -roundf(game.distance))
	assert(is_equal_approx(game.distance - old_distance, old_x - game.turrets[0].position.x))
	var start_score: int = game.score
	var routed_light: TurretBase = game.turrets[0]
	routed_light.take_damage(1, routed_light.global_position)
	assert(game.score == start_score and routed_light.state == TurretBase.TurretState.DAMAGED)
	routed_light.take_damage(3, routed_light.global_position)
	assert(game.score == start_score + GameData.SCORE.unarmored)
	var routed_heavy: TurretBase = game.turrets[1]
	routed_heavy.take_damage(1, routed_heavy.global_position)
	assert(game.score == start_score + GameData.SCORE.unarmored and routed_heavy.state == TurretBase.TurretState.ACTIVE)
	routed_heavy.take_damage(3, routed_heavy.global_position)
	assert(routed_heavy.state == TurretBase.TurretState.BREAKING)
	await create_timer(0.35).timeout
	routed_heavy.take_damage(1, routed_heavy.global_position)
	assert(game.score == start_score + GameData.SCORE.unarmored + GameData.SCORE.heavy)

	var stomp_game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(stomp_game)
	stomp_game.start_game("checkpoint", 0)
	stomp_game.lab_panel._process(0.01)
	stomp_game.lab_panel._process(0.01)
	await process_frame
	stomp_game.set_process(false)
	stomp_game._spawn_turret(load("res://LightTurret.tscn"))
	var stomp_turret: TurretBase = stomp_game.turrets[0]
	stomp_turret.position = Vector2(GameData.PLAYER_X, GameData.GROUND_Y)
	var turret_top: float = stomp_turret.body_rect().position.y
	stomp_game.player.y = turret_top + 5.0
	stomp_game.player_visual.position = stomp_game.player
	stomp_game.velocity_y = 180.0
	stomp_game._update_world(0.0)
	assert(stomp_game.state == "playing")
	assert(stomp_game.player.y == turret_top and stomp_game.velocity_y == -GameData.PLAYER.stomp_speed)
	print("TURRET SCENES / DAMAGE / ATTACKS / SPAWN: PASS")
	quit(0)
