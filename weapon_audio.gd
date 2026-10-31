extends Node

const MIX := preload("res://audio_mix.gd")

const FIRE_SOUNDS := [preload("res://assets/sfx/rifle_fire.wav"), preload("res://assets/sfx/piercer_fire.wav")]
const RELOAD_SOUNDS := [preload("res://assets/sfx/rifle_reload.mp3"), preload("res://assets/sfx/piercer_reload.wav")]
const SWITCH_SOUND := preload("res://assets/sfx/weapon_switch.wav")

var fire_players: Array[AudioStreamPlayer] = []
var reload_player: AudioStreamPlayer
var switch_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for sound in FIRE_SOUNDS:
		var player := _make_player(MIX.gain(sound.resource_path))
		player.stream = sound
		player.max_polyphony = 6
		fire_players.append(player)
	reload_player = _make_player(0.0)
	switch_player = _make_player(MIX.gain(SWITCH_SOUND.resource_path))
	switch_player.stream = SWITCH_SOUND

func _make_player(gain_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.volume_db = gain_db
	add_child(player)
	return player

func fire(weapon: int) -> void:
	# Keep the original speed and permit shot tails to overlap.
	fire_players[weapon].play()

func reload(weapon: int, duration: float) -> void:
	reload_player.stop()
	reload_player.stream = RELOAD_SOUNDS[weapon]
	reload_player.volume_db = MIX.gain(RELOAD_SOUNDS[weapon].resource_path)
	# Speed and pitch change together; fit the full clip to the actual reload.
	# Includes Fast Reload and manual reload-multiplier edits automatically.
	reload_player.pitch_scale = reload_player.stream.get_length() / maxf(duration, 0.01)
	reload_player.play()

func finish_reload() -> void:
	reload_player.stop()

func switch_weapon() -> void:
	switch_player.play()

func stop_all() -> void:
	for player in fire_players: player.stop()
	reload_player.stop()
	switch_player.stop()
