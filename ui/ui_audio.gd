extends Node
const MIX := preload("res://audio_mix.gd")
const CLICK := preload("res://assets/sfx/ui_click.wav")
const ERROR := preload("res://assets/sfx/ui_error.wav")
var player := AudioStreamPlayer.new()
var reject_until := 0
var last_click := -1000

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	get_tree().node_added.connect(_watch)
	_watch_tree(get_tree().root)

func _watch_tree(node: Node) -> void:
	_watch(node)
	for child in node.get_children(): _watch_tree(child)

func _watch(node: Node) -> void:
	if node is BaseButton: bind_button(node)

func bind_button(button: BaseButton) -> void:
	if button.has_meta("ui_audio_bound"): return
	button.set_meta("ui_audio_bound",true)
	button.pressed.connect(confirm)
	button.gui_input.connect(func(event: InputEvent):
		if button.disabled and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: reject())

func tick() -> void:
	pass

func confirm() -> void:
	var now := Time.get_ticks_msec()
	if now < reject_until or now-last_click < 40: return
	last_click = now
	_play(CLICK,"ui_click.wav")

func reject() -> void:
	var now := Time.get_ticks_msec()
	if now < reject_until: return
	reject_until = now+180
	_play(ERROR,"ui_error.wav")

func _play(stream: AudioStream, filename: String) -> void:
	player.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
	player.stop()
	player.stream = stream
	player.volume_db = MIX.gain(filename)
	player.play()
