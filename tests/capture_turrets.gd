extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(960, 720)
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._spawn_turret(load("res://LightTurret.tscn"))
	game._spawn_turret(load("res://HeavyTurret.tscn"))
	game.turrets[-2].position = Vector2(430, GameData.GROUND_Y)
	game.turrets[-1].position = Vector2(650, GameData.GROUND_Y)
	await process_frame
	print("TURRETS: ", root.get_texture().get_image().save_png("res://tests/turrets_capture.png"))
	var heavy: TurretBase = game.turrets[-1]
	heavy._on_attack_timeout()
	await process_frame
	print("TURRET CHARGE: ", root.get_texture().get_image().save_png("res://tests/turret_charge.png"))
	heavy.advance(heavy.charge_time, 0.0, game._player_center())
	heavy.position.x = heavy.laser_fire_x
	heavy.advance(0.0, 0.0, game._player_center())
	await process_frame
	print("TURRET LASER: ", root.get_texture().get_image().save_png("res://tests/turret_laser.png"))
	quit(0)
