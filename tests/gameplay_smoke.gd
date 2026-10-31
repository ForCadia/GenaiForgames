extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_game("checkpoint", 0)
	game.lab_panel._process(0.01)
	game.lab_panel._process(0.01)
	await process_frame
	game.set_process(false)
	for segment_index in range(GameData.CAMPAIGN_SEGMENT_COUNT):
		for event in GameData.SEGMENTS[segment_index].events:
			assert(event.kind in ["enemy", "low_obstacle", "high_barrage", "grenade"])
			if event.kind == "enemy":
				assert(event.type in ["unarmored", "light", "heavy"])

	# Visible barrel and projectile both follow the muzzle-to-cursor line.
	game.aim = Vector2(380, 110)
	game._fire()
	var shot: Dictionary = game.shots.back()
	var expected: Vector2 = (game.aim - shot.pos).normalized()
	assert(shot.velocity.normalized().distance_to(expected) < 0.0001)
	assert(game.player_visual.shot_direction().dot(expected) > 0.9999)
	game.shots.clear()
	for weapon in range(2):
		for target in [Vector2(380, 110), Vector2(700, 590), Vector2(100, 300)]:
			game.player_visual.set_motion(true, false, weapon, target, false, true)
			game.player_visual.play_fire()
			for elapsed in [0.0, 0.11]:
				game.player_visual.arm_time = elapsed
				game.player_visual._apply_frames()
				var direction: Vector2 = (target - game.player_visual.muzzle_world_position()).normalized()
				assert(game.player_visual.shot_direction().dot(direction) > 0.9999)

	# The old weakpoint location must no longer bypass heavy armor.
	game._spawn_enemy("heavy", 0, false)
	var heavy: TurretBase = game.turrets.back()
	var impact := heavy.global_position + Vector2(0, -20)
	heavy.take_damage(1, impact)
	assert(heavy.state == TurretBase.TurretState.ACTIVE)
	assert(game.stats.heavy == 0)
	heavy.take_damage(3, impact)
	assert(heavy.state == TurretBase.TurretState.BREAKING)
	await create_timer(0.35).timeout
	assert(heavy.state == TurretBase.TurretState.EXPOSED)
	heavy.take_damage(1, impact)
	assert(heavy.state == TurretBase.TurretState.DEAD and game.stats.heavy == 1)
	heavy.queue_free()
	game.turrets.clear()

	# A timed-out segment waits for outgoing objects, then starts clean.
	game.next_event = GameData.SEGMENTS[0].events.size()
	game.segment_time = GameData.SEGMENTS[0].duration * GameData.SEGMENT_PACE
	game.obstacles.append({"x": 400.0, "rect": Rect2(-20, -60, 40, 60), "danger": true})
	game._update_segment()
	assert(game.segment == 0 and game.segment_transition_pending)
	game.enemies.clear()
	game._update_segment()
	assert(game.segment == 0)
	game.obstacles.clear()
	game.particles.append({"pos": Vector2.ZERO, "velocity": Vector2.ZERO, "life": 1.0, "color": Color.WHITE})
	game.player.y = GameData.GROUND_Y - 160.0
	game.velocity_y = -220.0
	game._update_segment()
	assert(game.segment == 1 and not game.segment_transition_pending)
	assert(game.player.y == GameData.GROUND_Y - 160.0 and game.velocity_y == -220.0)
	assert(game.player_visual.position == game.player)
	assert(game.enemies.is_empty() and game.turrets.is_empty() and game.obstacles.is_empty() and game.pickups.is_empty())
	assert(game.shots.is_empty() and game.threats.is_empty() and game.particles.is_empty() and game.floaters.is_empty())
	for current_segment in range(1, GameData.CAMPAIGN_SEGMENT_COUNT):
		assert(game.segment == current_segment)
		game.next_event = GameData.SEGMENTS[current_segment].events.size()
		game.segment_time = GameData.SEGMENTS[current_segment].duration * GameData.SEGMENT_PACE
		game.player.y = GameData.GROUND_Y - 120.0
		game.velocity_y = 180.0
		game._update_segment()
		assert(game.player.y == GameData.GROUND_Y - 120.0 and game.velocity_y == 180.0)
		assert(game.player_visual.position == game.player)
		assert(game.enemies.is_empty() and game.turrets.is_empty() and game.obstacles.is_empty() and game.pickups.is_empty())
		assert(game.shots.is_empty() and game.threats.is_empty())
	assert(game.boss_mode)
	var boss_hp: int = game.boss.hp
	game._hit_boss({"penetration": 1, "pos": game._boss_pos()})
	assert(game.boss.armor == GameData.BOSS.armor_per_cycle and game.boss.hp == boss_hp)
	for hit in range(GameData.BOSS.armor_per_cycle):
		game._hit_boss({"penetration": 3, "pos": game._boss_pos()})
		game.boss_actor.advance(game.boss_actor.armor_break_time + 0.01, game._player_center())
	assert(game.boss.armor == 0 and game.boss.hp == boss_hp)
	game._hit_boss({"penetration": 1, "pos": game._boss_pos()})
	assert(game.boss.hp == boss_hp - 1 and game.boss.armor == 0)
	# A death in midair still respawns on the ground at the full Boss checkpoint.
	game._die("AIRBORNE_RETRY_CHECK")
	game._request_retry("keyboard")
	game._process(game.player_visual.death_animation_duration())
	game.death_camera_tween.custom_step(game.DEATH_CAMERA_DURATION + game.DEATH_CAMERA_HOLD + 0.01)
	game._process(0.01)
	assert(game.state == "playing" and game.boss_mode)
	assert(game.player.y == GameData.GROUND_Y and game.velocity_y == 0.0)
	assert(game.boss.hp == GameData.BOSS.health and game.boss.armor == GameData.BOSS.armor_per_cycle)
	print("GAMEPLAY AIM / ARMOR / TRANSITION SMOKE: PASS")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit(0)
