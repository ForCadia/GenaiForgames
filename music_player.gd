extends AudioStreamPlayer

const MUSIC_VOLUME_DB := -14.0

var normal_music: AudioStreamMP3 = preload("res://assets/music/untitled.mp3").duplicate()
var boss_music: AudioStreamMP3 = preload("res://assets/music/chase_mode.mp3").duplicate()
var started := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	volume_db = MUSIC_VOLUME_DB
	normal_music.loop = true
	boss_music.loop = true

func play_track(is_boss: bool) -> void:
	var next_track := boss_music if is_boss else normal_music
	started = true
	# One player, and no restart when a checkpoint uses the same track.
	if stream == next_track and playing: return
	stream = next_track
	play()

func return_to_menu() -> void:
	# Wait for the first Start click before requesting audio in the browser.
	if started: play_track(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo: return
	if event.physical_keycode != KEY_M: return
	if get_viewport().gui_get_focus_owner() is LineEdit: return
	AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
	get_parent().queue_redraw()
	get_viewport().set_input_as_handled()
