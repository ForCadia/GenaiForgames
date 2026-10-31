extends SceneTree
const PROFILE := preload("res://progression.gd")
func _initialize() -> void: call_deferred("run")
func win_boss(game: Node) -> void:
	game._start_boss()
	for hit in range(GameData.BOSS.health): game._boss_damage()
	assert(game.state == "victory")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var original = game.development_profile
	var original_coins: int = original.coins
	var original_owned: Dictionary = original.owned.duplicate()
	game.enter_guest_session()
	assert(game.play_profile == "guest" and game.progression.coins == 0 and game.progression.owned.is_empty())
	assert(not game.progression.persistence)
	game.start_screen.show_build(true)
	assert(game.start_screen.build_view.graph.profile == game.progression)
	assert(game.start_screen.build_view.graph.node_state("cell") == "poor")
	game.start_screen.show_build(false)
	game.start_screen.show_levels(true)
	assert(not game.start_screen.level_select.mission_buttons[0].disabled)
	for index in range(1,4): assert(game.start_screen.level_select.mission_buttons[index].disabled)
	game.start_level(1)
	assert(game.state == "start")
	game.start_endless()
	assert(game.state == "start")
	for level in range(3):
		game.start_level(level)
		assert(game.state == "playing")
		win_boss(game)
		assert(game.progression.unlocked_stage == level+1)
		game.return_to_start()
	assert(game.progression.coins > 0)
	assert(game.progression.buy("cell"))
	var guest_coins: int = game.progression.coins
	game.open_player_session()
	assert(game.progression.coins == guest_coins and game.progression.has_upgrade("cell"))
	game.start_endless()
	assert(game.endless_mode and game.state == "playing")
	game.return_to_start()
	game.enter_development_session()
	assert(game.progression == original and original.coins == original_coins and original.owned == original_owned)
	for index in range(4): assert(game.mission_unlocked(index))
	game.enter_guest_session()
	assert(game.progression.coins == 0 and game.progression.owned.is_empty() and game.progression.unlocked_stage == 0)
	assert(game.enter_named_session("  Alice  "))
	assert(game.play_profile == "named" and game.progression.profile_name == "Alice" and game.progression.coins == 0)
	assert(not game.enter_named_session("   "))
	assert(game.play_profile == "named")
	var first := PROFILE.new()
	first.configure_named(" Alice ")
	first.preview_only = true
	root.add_child(first)
	var safe_path: String = first.save_path
	assert(safe_path.begins_with("user://profiles/") and not safe_path.contains("Alice"))
	first.save_path = "res://tmp/named-profile-smoke.cfg"
	first.persistence = true
	first.coins = 23
	first.owned = {"cell":true}
	first.unlocked_stage = 2
	first.records = {"best_score":4200}
	assert(first.save() == OK)
	var second := PROFILE.new()
	second.configure_named("alice")
	assert(second.save_path == safe_path)
	second.preview_only = true
	root.add_child(second)
	second.save_path = first.save_path
	assert(second.load_profile() == OK)
	assert(second.coins == 23 and second.has_upgrade("cell") and second.unlocked_stage == 2 and second.records.best_score == 4200)
	first.queue_free()
	second.queue_free()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("GUEST RESET / PROGRESSION LOCKS / DEVELOPMENT ISOLATION / NAMED SAVE ROUNDTRIP: PASS")
	quit()
