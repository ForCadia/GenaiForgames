extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://LaserGateEnemy.tscn")
	var preview: LaserGateEnemy = packed.instantiate()
	var sprite: AnimatedSprite2D = preview.get_node("AnimatedSprite2D")
	assert(sprite.sprite_frames != null and sprite.animation == &"Hover")
	assert(sprite.sprite_frames.get_frame_count(&"Hover") == 6)
	assert(sprite.sprite_frames.get_frame_count(&"Hit") == 2)
	assert(sprite.sprite_frames.get_frame_count(&"Explode") == 6)
	assert(sprite.sprite_frames.get_animation_speed(&"Hover") == 8.0)
	assert(sprite.sprite_frames.get_animation_speed(&"Hit") == 12.0)
	assert(sprite.sprite_frames.get_animation_speed(&"Explode") == 11.0)
	assert(sprite.sprite_frames.get_animation_loop(&"Hover"))
	assert(not sprite.sprite_frames.get_animation_loop(&"Hit"))
	assert(not sprite.sprite_frames.get_animation_loop(&"Explode"))
	assert(sprite.sprite_frames.get_frame_texture(&"Hit", 1).region.position == Vector2(296, 296))
	root.add_child(preview)
	preview.position = Vector2(190, 450)
	await process_frame
	assert(preview.left_hit.position == Vector2(-65, -54))
	assert(preview.right_hit.position == Vector2(89, -54))
	assert(preview.laser_hit.position == Vector2(14, 78))
	assert(preview.left_hit.shape.size == Vector2(98, 92))
	assert(preview.right_hit.shape.size == Vector2(98, 92))
	assert(preview.laser_hit.shape.size == Vector2(128, 104))
	assert(preview.hazard_rect() == Rect2(Vector2(140, 476), Vector2(128, 104)))
	assert(preview.hazard_rect().intersects(Rect2(171, 528, 38, 92)))
	assert(not preview.hazard_rect().intersects(Rect2(163, 584, 54, 36)))
	for collision in [preview.left_hit, preview.right_hit]:
		assert(preview.shot_hits(collision.global_position + Vector2(-60, 0), collision.global_position + Vector2(60, 0)))
	preview.take_damage()
	assert(preview.state == "Hit")
	assert(preview.left_hit.disabled and preview.right_hit.disabled and preview.laser_hit.disabled)
	assert(not preview.laser_area.monitoring and not preview.shot_hits(Vector2.ZERO, Vector2(400, 450)))
	preview.take_damage()
	assert(preview.state == "Hit")
	await create_timer(0.22).timeout
	assert(is_instance_valid(preview) and preview.state == "Explode")
	await create_timer(0.65).timeout
	assert(not is_instance_valid(preview))

	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var before_threats: int = game.threats.size()
	game._spawn_event({"kind": "high_barrage"})
	assert(game.laser_gates.size() == 1 and game.threats.size() == before_threats)
	var gate: LaserGateEnemy = game.laser_gates[0]
	assert(gate.position == Vector2(990, 450))
	game._update_world(0.1)
	assert(is_equal_approx(gate.position.x, 958.5))
	gate.position = Vector2(430, 450)
	var left_center := gate.left_hit.global_position
	game.shots.append({"pos": left_center + Vector2(-150, 0), "previous": left_center + Vector2(-150, 0), "velocity": Vector2(2000, 0), "penetration": 1})
	game._update_shots(0.1)
	assert(gate.state == "Hit" and game.shots.is_empty())
	assert(gate.laser_hit.disabled)
	game._spawn_laser_gate()
	var right_gate: LaserGateEnemy = game.laser_gates.back()
	right_gate.position = Vector2(600, 450)
	var right_center := right_gate.right_hit.global_position
	game.shots.append({"pos": right_center + Vector2(150, 0), "previous": right_center + Vector2(150, 0), "velocity": Vector2(-2000, 0), "penetration": 1})
	game._update_shots(0.1)
	assert(right_gate.state == "Hit" and game.shots.is_empty())

	var standing_game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(standing_game)
	await process_frame
	standing_game.set_process(false)
	standing_game._spawn_laser_gate()
	standing_game.laser_gates[0].position = Vector2(178, 450)
	standing_game._update_world(0.0)
	assert(standing_game.state == "dead")
	var sliding_game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(sliding_game)
	await process_frame
	sliding_game.set_process(false)
	sliding_game.crouching = true
	sliding_game.player_visual.set_collision_pose(true)
	sliding_game._spawn_laser_gate()
	sliding_game.laser_gates[0].position = Vector2(178, 450)
	sliding_game._update_world(0.0)
	assert(sliding_game.state == "playing")
	print("LASER GATE SCENE / ANIMATION / COLLISION / SPAWN: PASS")
	quit(0)
