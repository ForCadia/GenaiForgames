extends SceneTree

var failures: Array[String] = []
var weak_hits := 0
var bombs_requested := 0

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
	boss.reset_for_battle(true)
	_check(boss.armor_layers() == 2, "Boss must start with two armor layers")
	boss.receive_shot(1, boss.position)
	_check(boss.armor_layers() == 2, "Assault rifle must not damage double armor")
	boss.receive_shot(3, boss.position)
	boss.receive_shot(3, boss.position)
	boss.advance(0.6, Vector2(190, 586))
	_check(boss.form == EyeballBoss.BossForm.SINGLE_ARMOR, "One AP hit must remove exactly one layer")
	boss.receive_shot(1, boss.position)
	_check(boss.armor_layers() == 1, "Assault rifle must not damage single armor")
	boss.receive_shot(3, boss.position)
	boss.advance(0.6, Vector2(190, 586))
	_check(boss.form == EyeballBoss.BossForm.WEAK_POINT, "Second AP hit must expose the weak point")
	_check(weak_hits == 0, "Second armor break must not damage the weak point")
	boss.receive_shot(1, boss.position)
	_check(weak_hits == 1, "Exposed weak point must forward damage to existing health logic")

	boss.reset_for_battle(true)
	boss.advance(1.2, Vector2(190, 586))
	boss.advance(0.8, Vector2(190, 586))
	_check(bombs_requested == 1, "One telegraph must create exactly one bomb")

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
	moving_bomb.position = Vector2(440, 115)
	moving_bomb.advance(1.0, 277.5)
	var landed_x := moving_bomb.position.x
	moving_bomb.advance(moving_bomb.ground_hold_time, 277.5)
	moving_bomb.advance(moving_bomb.explosion_warning_time, 277.5)
	_check(is_equal_approx(landed_x, 440.0), "Falling bomb must not drift before touching the track")
	_check(absf(moving_bomb.position.x - 190.0) < 2.0, "Track-locked bomb must reach the player lane before exploding")

	var main_scene := load("res://main.tscn") as PackedScene
	_check(main_scene != null, "Main scene must load after Boss integration")
	var game := main_scene.instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game._start_boss()
	_check(game.boss.hp == 4 and game.boss.armor == 2, "Boss checkpoint must preserve original four-point weak health")
	game._update_boss(1.2)
	_check(is_equal_approx(game.boss_actor.position.y, 520.0), "Boss must descend to its low attack altitude during telegraph")
	_check(game.boss_actor.position.y + 111.0 < GameData.GROUND_Y, "Boss artwork must remain airborne above the track while attacking")
	game._hit_boss({"penetration": 1, "pos": Vector2(700, 350)})
	_check(game.boss.hp == 4 and game.boss.armor == 2, "Armored rifle impact must not update the Boss health bar")
	game._hit_boss({"penetration": 3, "pos": Vector2(700, 350)})
	game.boss_actor.advance(0.6, Vector2(190, 586))
	game._hit_boss({"penetration": 3, "pos": Vector2(700, 350)})
	game.boss_actor.advance(0.6, Vector2(190, 586))
	_check(game.boss.hp == 4 and game.boss.armor == 0, "Two AP hits must expose without damaging the weak health")
	game._hit_boss({"penetration": 1, "pos": Vector2(700, 350)})
	_check(game.boss.hp == 3 and game.boss.armor == 0, "Exposed damage must reuse the original Boss health logic without restoring armor")
	game.queue_free()
	boss.queue_free()
	bomb.queue_free()
	moving_bomb.queue_free()
	particle.queue_free()
	await process_frame
	if failures.is_empty():
		print("BOSS_SMOKE_OK")
		quit(0)
	else:
		quit(1)
