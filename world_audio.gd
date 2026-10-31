extends Node

const SOUNDS := {
	"light_turret_fire": preload("res://assets/sfx/light_turret_fire.wav"),
	"heavy_turret_fire": preload("res://assets/sfx/heavy_turret_fire.wav"),
	"heavy_turret_charge": preload("res://assets/sfx/heavy_turret_charge.wav"),
	"item_pickup": preload("res://assets/sfx/item_pickup.wav"),
	"enemy_explode": preload("res://assets/sfx/enemy_explode.wav"),
	"boss_bomb_countdown": preload("res://assets/sfx/boss_bomb_countdown.wav"),
	"boss_bomb_explode": preload("res://assets/sfx/boss_bomb_explode.wav"),
	"boss_particle_charge": preload("res://assets/sfx/heavy_turret_charge.wav"),
	"boss_particle_fire": preload("res://assets/sfx/heavy_turret_fire.wav"),
	"shield_open": preload("res://assets/sfx/shield_open.wav"),
}
const CUE_GAINS_DB := {
	"boss_bomb_countdown": -2.0,
	"boss_bomb_explode": -2.0,
	"boss_particle_charge": -2.0,
	"boss_particle_fire": -2.0,
	"item_pickup": -4.0,
	"shield_open": -6.0,
}

var game: Node
var voices := Node.new()
var drone_player := AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(voices)
	var drone_stream: AudioStreamWAV = preload("res://assets/sfx/laser_gate_hover.wav").duplicate()
	drone_stream.loop_begin = 0
	drone_stream.loop_end = int(round(drone_stream.get_length() * drone_stream.mix_rate))
	drone_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	drone_player.stream = drone_stream
	drone_player.volume_db = -10.0
	add_child(drone_player)

func set_drone_active(active: bool) -> void:
	# Several gates share one ambience voice instead of stacking loud loops.
	if active and game.state == "playing":
		if not drone_player.playing: drone_player.play()
	else:
		drone_player.stop()

func play_cue(cue: String, duration := -1.0, source: Node = null) -> void:
	if cue == "stop":
		stop_for(source)
		return
	if not SOUNDS.has(cue): return
	if game.state != "playing" and not (game.state == "victory" and cue == "enemy_explode"): return
	# Keep completed actors' one-shot tails, but cancel interrupted charge cues.
	if cue in ["heavy_turret_fire", "boss_bomb_explode", "boss_particle_fire"]: stop_for(source)
	if voices.get_child_count() >= 24:
		var oldest := voices.get_child(0) as AudioStreamPlayer
		oldest.stop()
		voices.remove_child(oldest)
		oldest.queue_free()
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[cue]
	player.set_meta("explosion", cue in ["enemy_explode", "boss_bomb_explode"])
	player.volume_db = CUE_GAINS_DB.get(cue, -8.0)
	if duration > 0.0: player.pitch_scale = player.stream.get_length() / duration
	if cue in ["heavy_turret_charge", "boss_bomb_countdown", "boss_particle_charge"] and is_instance_valid(source):
		player.set_meta("source_id", source.get_instance_id())
		source.tree_exiting.connect(func():
			if is_instance_valid(player):
				player.stop()
				player.queue_free(), CONNECT_ONE_SHOT)
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
	for player in voices.get_children():
		if keep_explosions and player.get_meta("explosion", false): continue
		player.stop()
		player.queue_free()
