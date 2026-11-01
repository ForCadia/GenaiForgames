extends Node

const MIX := preload("res://audio_mix.gd")

const SOUNDS := {
	"boss_melee_sword": preload("res://assets/sfx/boss_melee_sword.wav"),
	"iron_cannon_fire": preload("res://assets/sfx/iron_cannon_fire.wav"),
	"iron_missile_fire": preload("res://assets/sfx/iron_missile_fire.wav"),
	"coin_pickup": preload("res://assets/sfx/coin_pickup.wav"),
	"armor_ricochet": preload("res://assets/sfx/armor_ricochet.wav"),
	"light_turret_fire": preload("res://assets/sfx/light_turret_fire.wav"),
	"heavy_turret_fire": preload("res://assets/sfx/heavy_turret_fire.wav"),
	"heavy_turret_charge": preload("res://assets/sfx/heavy_turret_charge.wav"),
	"item_pickup": preload("res://assets/sfx/item_pickup.wav"),
	"enemy_explode": preload("res://assets/sfx/enemy_explode.wav"),
	"boss_bomb_countdown": preload("res://assets/sfx/boss_bomb_countdown.wav"),
	"boss_bomb_explode": preload("res://assets/sfx/boss_bomb_explode.wav"),
	"boss_particle_charge": preload("res://assets/sfx/heavy_turret_charge.wav"),
	"boss_particle_fire": preload("res://assets/sfx/heavy_turret_fire.wav"),
}

var coin_sound_left := 0.0
var game: Node
var voices := Node.new()
var drone_player := AudioStreamPlayer.new()
var shield_player := AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(voices)
	var drone_stream: AudioStreamWAV = preload("res://assets/sfx/laser_gate_hover.wav").duplicate()
	drone_stream.loop_begin = 0
	drone_stream.loop_end = int(round(drone_stream.get_length() * drone_stream.mix_rate))
	drone_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	drone_player.stream = drone_stream
	drone_player.bus = "SFX"
	drone_player.volume_db = MIX.gain("laser_gate_hover.wav")
	add_child(drone_player)
	shield_player.stream = preload("res://assets/sfx/shield_open.wav")
	shield_player.bus = "SFX"
	shield_player.volume_db = MIX.gain("shield_open.wav")
	add_child(shield_player)

func set_shield_active(active: bool) -> void:
	if game.attract_mode: return
	# One sustained voice, tied to the actual shield rather than a button press.
	if active and game.state == "playing":
		if not shield_player.playing: shield_player.play()
	else:
		shield_player.stop()

func set_drone_active(active: bool) -> void:
	if game.attract_mode: return
	# Several gates share one ambience voice instead of stacking loud loops.
	if active and game.state == "playing":
		if not drone_player.playing: drone_player.play()
	else:
		drone_player.stop()

func play_cue(cue: String, duration := -1.0, source: Node = null) -> void:
	if game.attract_mode: return
	if cue == "stop":
		stop_for(source)
		return
	if not SOUNDS.has(cue): return
	if game.state != "playing" and not (game.state in ["victory", "intermission"] and cue == "enemy_explode"): return
	# Keep completed actors' one-shot tails, but cancel interrupted charge cues.
	if cue in ["heavy_turret_fire", "boss_bomb_explode", "boss_particle_fire"]: stop_for(source)
	if voices.get_child_count() >= 24:
		var oldest := voices.get_child(0) as AudioStreamPlayer
		oldest.stop()
		voices.remove_child(oldest)
		oldest.queue_free()
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = SOUNDS[cue]
	player.set_meta("explosion", cue in ["enemy_explode", "boss_bomb_explode"])
	player.volume_db = MIX.gain(SOUNDS[cue].resource_path)
	if duration > 0.0: player.pitch_scale = player.stream.get_length() / duration
	if cue in ["heavy_turret_charge", "boss_bomb_countdown", "boss_particle_charge"] and is_instance_valid(source):
		player.set_meta("source_id", source.get_instance_id())
		var player_ref: WeakRef = weakref(player)
		source.tree_exiting.connect(func():
			var active_player = player_ref.get_ref()
			if is_instance_valid(active_player):
				active_player.stop()
				active_player.queue_free(), CONNECT_ONE_SHOT)
	voices.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func stop_for(source: Node) -> void:
	if not is_instance_valid(source): return
	for player in voices.get_children():
		if player.get_meta("source_id", 0) == source.get_instance_id():
			player.stop()
			player.queue_free()

func stop_all(keep_explosions := false) -> void:
	drone_player.stop()
	shield_player.stop()
	for player in voices.get_children():
		if keep_explosions and player.get_meta("explosion", false): continue
		player.stop()
		player.queue_free()

func _process(delta: float) -> void:
	coin_sound_left = maxf(0.0,coin_sound_left-delta)

func play_coin_pickup() -> bool:
	if game.attract_mode or game.state != "playing" or coin_sound_left > 0: return false
	coin_sound_left = 0.08
	play_cue("coin_pickup")
	return true
