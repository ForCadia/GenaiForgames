extends AudioStreamPlayer

const MIX := preload("res://audio_mix.gd")

var normal_music: AudioStreamOggVorbis = preload("res://assets/music/untitled_loop60.ogg").duplicate()
var boss_music: AudioStreamOggVorbis = preload("res://assets/music/chase_mode_loop60.ogg").duplicate()
var silent := false
var started := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = "Music"
	volume_db = MIX.gain("untitled_loop60.ogg")
	normal_music.loop = true
	boss_music.loop = true

func play_track(is_boss: bool) -> void:
	if silent: return
	var next_track := boss_music if is_boss else normal_music
	volume_db = MIX.gain("chase_mode_loop60.ogg" if is_boss else "untitled_loop60.ogg")
	started = true
	# One player, and no restart when a checkpoint uses the same track.
	if stream == next_track and playing: return
	stream = next_track
	play()

func return_to_menu() -> void:
	# Desktop plays immediately; browsers resume their audio context on user input.
	play_track(false)
