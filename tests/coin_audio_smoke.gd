extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_level(0)
	game._register_kill("heavy",game.player)
	for coin in game.coin_drops:
		coin.landed = true
		coin.pos = game.player-Vector2(0,10)
	var wallet: int = game.progression.coins
	game._update_coins(0)
	assert(game.run_coins == 7 and game.progression.coins == wallet+7)
	var coin_voices := 0
	for voice in game.world_audio.voices.get_children():
		if voice.stream == game.world_audio.SOUNDS.coin_pickup:
			coin_voices += 1
			assert(voice.bus == "SFX")
	assert(coin_voices == 1)
	assert(not game.world_audio.play_coin_pickup())
	game.world_audio._process(0.09)
	assert(game.world_audio.play_coin_pickup())
	game.attract_mode = true
	game.world_audio._process(0.09)
	assert(not game.world_audio.play_coin_pickup())
	game.attract_mode = false
	game.world_audio.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("COIN CREDIT SOUND / BURST LIMIT / SFX ROUTING / DEMO SILENCE: PASS")
	quit()
