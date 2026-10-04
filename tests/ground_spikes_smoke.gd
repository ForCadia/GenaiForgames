extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://GroundSpikes.tscn")
	var preview: GroundSpikes = packed.instantiate()
	root.add_child(preview)
	await process_frame
	assert(preview is Area2D and preview.collision_layer == 16 and preview.collision_mask == 1)
	assert(preview.get_node("Sprite2D").position == Vector2(-128, -238))
	assert(preview.get_node("Sprite2D").scale == Vector2.ONE)
	assert(preview.get_node("Sprite2D").texture.get_size() == Vector2(256, 256))
	assert(preview.base_collision.position == Vector2(-0.5, -12.5))
	assert(preview.base_collision.shape.size == Vector2(213, 25))
	assert(preview.spike_collisions.size() == 3)
	preview.position = Vector2(190, GameData.GROUND_Y)
	assert(preview.hits_rect(Rect2(171, 540, 38, 92)))
	assert(preview.hits_rect(Rect2(163, 596, 54, 36)))
	assert(not preview.hits_rect(Rect2(171, 407, 38, 92)))
	assert(not preview.hits_rect(Rect2(310, 540, 38, 92)))
	preview.advance(0.1, 330.0)
	assert(is_equal_approx(preview.position.x, 157.0))

	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var original_obstacles: int = game.obstacles.size()
	game._spawn_event({"kind": "low_obstacle"})
	assert(game.ground_spikes.size() == 1 and game.obstacles.size() == original_obstacles)
	var spikes: GroundSpikes = game.ground_spikes[0]
	assert(spikes.position == Vector2(1010, GameData.GROUND_Y))
	var scroll: float = game._scroll()
	game._update_world(0.1)
	assert(is_equal_approx(spikes.position.x, 1010.0 - scroll * 0.1))
	spikes.position = Vector2(190, GameData.GROUND_Y)
	game._update_world(0.0)
	assert(game.state == "dead")

	var slide_game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(slide_game)
	await process_frame
	slide_game.set_process(false)
	slide_game.crouching = true
	slide_game.player_visual.set_collision_pose(true)
	slide_game._spawn_ground_spikes()
	slide_game.ground_spikes[0].position = Vector2(190, GameData.GROUND_Y)
	slide_game._update_world(0.0)
	assert(slide_game.state == "dead")

	var jump_game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(jump_game)
	await process_frame
	jump_game.set_process(false)
	jump_game._spawn_ground_spikes()
	jump_game.ground_spikes[0].position = Vector2(190, GameData.GROUND_Y)
	jump_game.player.y = 487
	jump_game.player_visual.position = jump_game.player
	jump_game._update_world(0.0)
	assert(jump_game.state == "playing")
	jump_game.ground_spikes[0].position.x = 420
	jump_game.player = Vector2(190, GameData.GROUND_Y)
	jump_game.player_visual.position = jump_game.player
	jump_game.velocity_y = -720.0
	for frame in range(75):
		jump_game._update_player(1.0 / 60.0)
		jump_game._update_world(1.0 / 60.0)
		assert(jump_game.state == "playing", "Normal-height jump should clear the whole spike set")
	# Spikes are absent from the shot hit list, so shots are not destroyed by them.
	jump_game.shots.append({"pos": Vector2(70, 580), "previous": Vector2(70, 580), "velocity": Vector2(1600, 0), "penetration": 1, "radius": 3.0})
	jump_game._update_shots(0.1)
	assert(jump_game.shots.size() == 1 and jump_game.score == 0)
	print("GROUND SPIKES SCENE / COLLISION / SPAWN / DAMAGE: PASS")
	quit(0)
