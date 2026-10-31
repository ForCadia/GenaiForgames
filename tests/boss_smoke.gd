extends SceneTree

var failures: Array[String] = []
var weak_hits := 0
var bombs_requested := 0
var barrage_waves: Array[int] = []
var armor_sounds := 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL: ", message)

func _run() -> void:
	var boss_scene := load("res://EyeballBoss.tscn") as PackedScene
	var boss := boss_scene.instantiate() as EyeballBoss
	root.add_child(boss)
	boss.position = Vector2(785, 350)
	boss.weak_point_hit.connect(func(): weak_hits += 1)
	boss.bomb_requested.connect(func(_x: float): bombs_requested += 1)
	boss.barrage_requested.connect(func(_origin: Vector2, wave: int): barrage_waves.append(wave))
	boss.sound_requested.connect(func(cue: String, _duration: float):
		if cue == "armor_ricochet": armor_sounds += 1)
	boss.reset_for_battle(true)
	_check(boss.armor_layers() == 2, "Boss must start with two armor layers")
	boss.receive_shot(1, boss.position)
	_check(boss.armor_layers() == 2, "Assault rifle must not damage double armor")
	_check(armor_sounds == 1, "Insufficient penetration must play armor ricochet")
	_check(boss.armor_points() == 36, "Rifle must not reduce armor points")
	for hit in range(5): boss.receive_shot(3,boss.position)
	_check(boss.armor_points() == 21 and boss.form == EyeballBoss.BossForm.DOUBLE_ARMOR, "Five AP hits must not break the first layer")
	boss.receive_shot(3,boss.position)
	_check(boss.armor_points() == 18, "Six AP hits must remove exactly 18 armor")
	boss.advance(0.6,Vector2(190,586))
	_check(boss.form == EyeballBoss.BossForm.SINGLE_ARMOR and boss.armor_points() == 18, "Outer break must preserve inner armor")
	boss.receive_shot(1,boss.position)
	_check(boss.armor_points() == 18,"Rifle must not damage inner armor")
	for hit in range(6): boss.receive_shot(3,boss.position)
	boss.advance(0.6,Vector2(190,586))
	_check(boss.form == EyeballBoss.BossForm.WEAK_POINT and boss.armor_points() == 0,"Twelve AP hits expose the weak point")
	_check(weak_hits == 0,"Armor damage must not damage red health")
	boss.receive_shot(1, boss.position)
	_check(weak_hits == 1, "Exposed weak point must forward damage to existing health logic")

	boss.reset_for_battle(true)
	boss.advance(1.2, Vector2(190, 586))
	_check(not boss.wants_low_flight(), "Bomb telegraph must keep the Boss hovering")
	boss.advance(0.8, Vector2(190, 586))
	_check(bombs_requested == 1, "One telegraph must create exactly one bomb")
	_check(not boss.wants_low_flight(), "Bomb release must not lower the Boss")
	boss.advance(0.2, Vector2(190, 586))
	_check(not boss.wants_low_flight(), "Bomb recovery must not lower the Boss")
	boss.advance(0.5, Vector2(190, 586))
	boss.advance(boss.attack_interval, Vector2(190, 586))
	_check(boss.wants_low_flight(), "Particle telegraph must retain its low attack altitude")
	boss.advance(boss.telegraph_time, Vector2(190, 586))
	boss.advance(0.2, Vector2(190, 586))
	boss.advance(0.5, Vector2(190, 586))
	_check(boss.next_attack_is_barrage, "Three-shot attack must cycle into the new barrage")
	boss.advance(boss.attack_interval, Vector2(190, 586))
	_check(not boss.wants_low_flight(), "Barrage must stay in the upper flight region")
	boss.advance(boss.telegraph_time, Vector2(190, 586))
	for wave in range(3): boss.advance(boss.barrage_wave_interval, Vector2(190, 586))
	_check(barrage_waves == [0, 1, 2], "Barrage must emit exactly three waves then recover")
	boss.advance(boss.recovery_time, Vector2(190, 586))
	_check(boss.next_attack_is_bomb and not boss.next_attack_is_barrage, "Barrage must cycle back to bombs")
	boss.reset_for_battle(true)
	boss.next_attack_is_bomb = false
	boss.next_attack_is_barrage = true
	boss.state_time = 0.0
	boss.advance(0.01, Vector2(190, 586))
	boss.advance(boss.telegraph_time, Vector2(190, 586))
	for hit in range(6): boss.receive_shot(3, boss.position)
	boss.advance(boss.armor_break_time, Vector2(190, 586))
	_check(barrage_waves.size() == 4, "Armor break must cancel the remaining barrage waves")

	var particle_scene := load("res://BossParticle.tscn") as PackedScene
	var particle := particle_scene.instantiate() as BossParticle
	root.add_child(particle)
	particle.position = Vector2(190, 565)
	var standing := Rect2(171, 540, 38, 92)
	var crouching := Rect2(163, 596, 54, 36)
	_check(particle.try_damage(standing), "Standing hitbox must intersect the high particle")
	particle.queue_free()
	particle = particle_scene.instantiate() as BossParticle
	root.add_child(particle)
	particle.position = Vector2(190, 565)
	_check(not particle.try_damage(crouching), "Crouching hitbox must pass below the high particle")

	var bomb_scene := load("res://BossBomb.tscn") as PackedScene
	var bomb := bomb_scene.instantiate() as BossBomb
	root.add_child(bomb)
	bomb.position = Vector2(440, 115)
	bomb.advance(1.0)
	bomb.advance(bomb.ground_hold_time + 0.01)
	bomb.advance(bomb.explosion_warning_time + 0.01)
	_check(bomb.state == BossBomb.BombState.EXPLODING, "Bomb must warn before enabling its explosion")
	_check(bomb.try_damage(Rect2(421, 540, 38, 92)), "Grounded explosion must overlap a nearby grounded player")
	var moving_bomb := bomb_scene.instantiate() as BossBomb
	root.add_child(moving_bomb)
	moving_bomb.launch(Vector2(785, 350), 440.0)
	moving_bomb.advance(0.1, 277.5)
	_check(moving_bomb.position.x < 785.0 and moving_bomb.position.x > 440.0 and moving_bomb.position.y > 350.0, "Thrown bomb must travel from Boss toward the landing point")
	moving_bomb.advance(1.0, 277.5)
	var landed_x := moving_bomb.position.x
	moving_bomb.advance(moving_bomb.ground_hold_time, 277.5)
	moving_bomb.advance(moving_bomb.explosion_warning_time, 277.5)
	_check(is_equal_approx(landed_x, 440.0), "Thrown bomb must land at its intended point even with a large frame delta")
	_check(absf(moving_bomb.position.x - 190.0) < 2.0, "Track-locked bomb must reach the player lane before exploding")

	var main_scene := load("res://main.tscn") as PackedScene
	_check(main_scene != null, "Main scene must load after Boss integration")
	var game := main_scene.instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game.set_process(false)
	game._start_boss()
	game._update_boss(2.0)
	game.boss_actor.state_time = 1.15
	_check(game.boss.hp == GameData.BOSS.health and game.boss.hp > 4 and game.boss.armor == 2, "Boss must start with increased red health and two armor layers")
	game._update_boss(1.2)
	_check(game.particles.is_empty(), "Attack warning must not create red particles")
	_check(absf(game.boss_actor.position.y - game.BOSS_IDLE_Y) <= 22.0, "Boss must keep its hover altitude during bomb telegraph")
	_check(game.boss_actor.position.y + 111.0 < GameData.GROUND_Y, "Boss artwork must remain airborne above the track while attacking")
	game.boss_actor.advance(game.boss_actor.telegraph_time, game._player_center())
	_check(game.boss_bombs.size() == 1, "Boss release must create one bomb in the game")
	_check(game.boss_bombs.back().global_position.is_equal_approx(game.boss_actor.global_position), "Bomb must originate at the Boss, not above the landing point")
	game._hit_boss({"penetration": 1, "pos": Vector2(700, 350)})
	_check(game.boss.hp == GameData.BOSS.health and game.boss.armor == 2, "Armored rifle impact must not update the Boss health bar")
	for plate in range(2):
		for hit in range(6): game._hit_boss({"penetration":3,"pos":Vector2(700,350)})
		game.boss_actor.advance(0.6,Vector2(190,586))
	_check(game.boss.hp == GameData.BOSS.health and game.boss.armor == 0,"Twelve AP hits expose armor without red-health damage")
	game._hit_boss({"penetration": 1, "pos": Vector2(700, 350)})
	_check(game.boss.hp == GameData.BOSS.health - 1 and game.boss.armor == 0, "Exposed damage must reuse the original Boss health logic without restoring armor")
	# A full particle telegraph emits one simultaneous fan from the eye marker.
	game._start_boss()
	game._update_boss(2.0)
	game.boss_actor.state_time = 1.15
	game.boss_actor.next_attack_is_bomb = false
	game.boss_actor.state_time = 0.0
	game._update_boss(0.01)
	for frame in range(44):
		game._update_boss(1.0 / 60.0)
	_check(game.boss_particles.size() == 3, "Particle attack must emit exactly three projectiles")
	_check(is_equal_approx(game.boss_actor.position.y, game.BOSS_ATTACK_Y), "Boss must descend before releasing the three-shot attack")
	var muzzle: Vector2 = game.boss_actor.get_node("ProjectileMuzzle").global_position
	_check(is_equal_approx(muzzle.y, game.boss_actor.global_position.y), "Eye muzzle must follow Boss height")
	var lower_hits_standing := false
	for shot in game.boss_particles:
		_check(shot.global_position.distance_to(muzzle) < 20.0, "Each projectile must begin at the moving eye muzzle")
		_check(shot.direction.x < 0.0 and is_equal_approx(shot.direction.length(), 1.0), "Fan must travel forward at the existing speed")
		shot.advance((shot.global_position.x - 190.0) / (-shot.direction.x * shot.speed))
		_check(not shot.try_damage(crouching), "Crouching must remain clear of the fan at the player lane")
		if shot.try_damage(standing): lower_hits_standing = true
	_check(lower_hits_standing, "Fan must still threaten a standing player")
	_check(game.boss_particles[0].direction.y > 0.0 and is_zero_approx(game.boss_particles[1].direction.y) and game.boss_particles[2].direction.y < 0.0, "Fan must contain lower, center and upper directions")
	game._start_boss()
	game._update_boss(2.0)
	game.boss_actor.state_time = 1.15
	_check(game.boss_particles.is_empty(), "Boss reset must clear all three projectiles")
	var initial_position: Vector2 = game.boss_actor.position
	for frame in range(30):
		game.segment_time += 1.0 / 60.0
		game._update_boss(1.0 / 60.0)
	_check(game.boss_actor.position.distance_to(initial_position) > 10.0, "Boss must move in the upper right")
	_check(game.boss_actor.position.x >= 720.0 and game.boss_actor.position.x <= 850.0 and game.boss_actor.position.y <= 350.0, "Upper flight must stay inside its visible region")
	for wave in range(3): game._on_boss_barrage_requested(game.boss_actor.global_position, wave)
	_check(game.boss_particles.size() == 24, "Three barrage waves must produce 8 rounds each")
	for shot in game.boss_particles:
		_check(shot.direction.x < 0.0 and shot.speed == GameData.BOSS.barrage_speed and shot.speed > 300.0 and shot.scale == Vector2.ONE, "Barrage rounds must be faster and use the normal attack size")
	game._start_boss()
	game._update_boss(2.0)
	game.boss_actor.state_time = 1.15
	_check(game.boss_particles.is_empty() and game.boss_actor.barrage_wave == 0, "Reset must remove barrage projectiles and progress")
	# Lethal hits clear both collections while _update_boss is iterating them.
	# Multiple pending attacks must not cause access to the now-empty arrays.
	for attack_kind in ["barrage", "bomb"]:
		game._on_boss_barrage_requested(game._player_center(), 0)
		if attack_kind == "bomb":
			for index in range(2): game._on_boss_bomb_requested(GameData.PLAYER_X)
			for planted in game.boss_bombs:
				planted.position = Vector2(GameData.PLAYER_X, GameData.GROUND_Y)
				planted.state = BossBomb.BombState.EXPLODING
				planted.state_time = planted.explosion_duration
		game._update_boss(0.0)
		_check(game.state == "dead" and game.boss_particles.is_empty() and game.boss_bombs.is_empty(), "Lethal " + attack_kind + " must clear attacks safely")
		game._request_retry("smoke")
		game._retry()
		game._update_boss(2.0)
		_check(game.state == "playing" and game.boss_mode and game.boss.hp == GameData.BOSS.health, "Lethal " + attack_kind + " must allow Boss retry")
	game.world_audio.stop_all()
	game.weapon_audio.stop_all()
	game.music.stop()
	await create_timer(0.2).timeout
	game.queue_free()
	boss.queue_free()
	bomb.queue_free()
	moving_bomb.queue_free()
	particle.queue_free()
	await process_frame
	if failures.is_empty():
		# Allow the audio thread to release stopped playbacks before shutdown.
		await create_timer(0.1).timeout
		print("BOSS_SMOKE_OK")
		quit(0)
	else:
		quit(1)
