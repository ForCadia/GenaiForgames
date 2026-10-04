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
	game.guarding = true
	game.player_visual.set_motion(true, false, 0, Vector2(700, 350), true, true)
	var shield: Sprite2D = game.player_visual.guard_effect
	assert(shield.texture.resource_path == "res://sheild_game.png")
	assert(shield.texture.get_size() == Vector2(932, 1688))
	assert(shield.scale == Vector2(0.16, 0.16))
	var guard_rect: Rect2 = game._guard_hitbox()
	assert(guard_rect.size.x > game._player_hitbox().size.x)
	assert(guard_rect.size.y > game._player_hitbox().size.y)
	assert(guard_rect.position.x <= game.player.x + 5.0 and guard_rect.end.x > game.player.x + 60.0)

	game._spawn_turret(load("res://LightTurret.tscn"))
	var turret: TurretBase = game.turrets.back()
	turret.position = Vector2(250, GameData.GROUND_Y)
	game._update_world(0.0)
	assert(turret.state == TurretBase.TurretState.DEAD)
	assert(game.state == "playing")

	game._spawn_ground_spikes()
	var spikes: GroundSpikes = game.ground_spikes.back()
	spikes.position = Vector2(250, GameData.GROUND_Y)
	game._update_world(0.0)
	assert(spikes.is_queued_for_deletion())
	assert(game.state == "playing")

	game.threats.append({"pos": guard_rect.get_center(), "velocity": Vector2.ZERO, "unblockable": false, "radius": 7.0})
	game._update_threats(0.0)
	assert(game.threats.is_empty())
	assert(game.state == "playing")
	print("SHIELD VISUAL / IMPACT / PLAYER SAFETY: PASS")
	quit(0)
