extends CanvasLayer
# Safe moving-track warning, Boss entrance, focus/hold and return before combat.
const GD := preload("res://game_data.gd")
const WARNING_TEXTURE := preload("res://assets/vfx/boss_warning_banner.png")
const FONT := preload("res://assets/fonts/FusionPixel.otf")
const WARNING_TIME := 1.5
const ENTRANCE_END := 2.8
const FOCUS_END := 3.6
const HOLD_END := 4.4
const TOTAL_TIME := 5.1
var elapsed := 0.0
var active := false
var title := ""
var surface: Control
var camera_target := Transform2D.IDENTITY

func _ready() -> void:
	layer = 80
	surface = Control.new()
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface.draw.connect(_draw_overlay)
	add_child(surface)
	visible = false

func begin(game: Node2D) -> void:
	elapsed = 0.0
	active = true
	visible = true
	title = "IRON BASTION" if game.is_iron_boss() else ("GUNBLADE" if game.is_mecha_boss() else "SENTINEL")
	game.mecha_actor.visible = false
	game.iron_actor.visible = false
	game.boss_actor.visible = false
	game.get_viewport().canvas_transform = Transform2D.IDENTITY
	surface.queue_redraw()

func cancel(game: Node2D) -> void:
	if active: game.get_viewport().canvas_transform = Transform2D.IDENTITY
	active = false
	visible = false

func advance_intro(delta: float, game: Node2D) -> bool:
	var before: float = elapsed
	elapsed += delta
	if elapsed >= WARNING_TIME:
		var entrance_delta: float = maxf(0.0,elapsed-maxf(before,WARNING_TIME))
		if game.is_mechanical_boss():
			var actor: Node2D = game._mechanical_actor()
			actor.visible = true
			actor.advance_intro(entrance_delta,game._player_center())
		else:
			game.boss_actor.visible = true
			game.boss_actor.position = game.boss_actor.position.move_toward(Vector2(785.0,265.0),400.0*entrance_delta)
	if elapsed >= ENTRANCE_END and before < ENTRANCE_END:
		var focus: Vector2 = game._mechanical_actor().core_position() if game.is_mechanical_boss() else game.boss_actor.position
		if game.is_iron_boss(): focus = game.iron_actor.intro_focus_position()
		var zoom: float = 1.05 if game.is_iron_boss() else 1.5
		camera_target = Transform2D(Vector2(zoom,0),Vector2(0,zoom),GD.VIEW_SIZE*Vector2(0.58,0.46)-focus*zoom)
	if bool(game.settings.options.death_camera):
		if elapsed >= ENTRANCE_END and elapsed < FOCUS_END:
			game.get_viewport().canvas_transform = Transform2D.IDENTITY.interpolate_with(camera_target,smoothstep(ENTRANCE_END,FOCUS_END,elapsed))
		elif elapsed >= FOCUS_END and elapsed < HOLD_END:
			game.get_viewport().canvas_transform = camera_target
		elif elapsed >= HOLD_END:
			game.get_viewport().canvas_transform = camera_target.interpolate_with(Transform2D.IDENTITY,smoothstep(HOLD_END,TOTAL_TIME,elapsed))
	surface.queue_redraw()
	if elapsed < TOTAL_TIME: return false
	game.get_viewport().canvas_transform = Transform2D.IDENTITY
	active = false
	visible = false
	return true

func _center_text(text: String, y: float, size: int, color: Color) -> void:
	var width: float = FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	surface.draw_string(FONT,Vector2((GD.VIEW_SIZE.x-width)*0.5,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw_overlay() -> void:
	if not active: return
	var edge: float = 55.0*smoothstep(0.0,0.3,elapsed)
	surface.draw_rect(Rect2(0,0,GD.VIEW_SIZE.x,edge),Color(0.015,0.02,0.03,0.92))
	surface.draw_rect(Rect2(0,GD.VIEW_SIZE.y-edge,GD.VIEW_SIZE.x,edge),Color(0.015,0.02,0.03,0.92))
	if elapsed < WARNING_TIME:
		var pulse: float = 1.0 if bool(get_parent().settings.options.reduced_flash) else 0.86+0.14*sin(elapsed*12.0)
		var slide: float = (1.0-smoothstep(0.0,0.25,elapsed))*GD.VIEW_SIZE.x
		var fade: float = 1.0-smoothstep(WARNING_TIME-0.2,WARNING_TIME,elapsed)
		surface.draw_texture_rect(WARNING_TEXTURE,Rect2(slide,160,GD.VIEW_SIZE.x,340),false,Color(1,1,1,pulse*fade))
	elif elapsed >= ENTRANCE_END:
		_center_text(title,GD.VIEW_SIZE.y-82,34,Color("fff0de"))
