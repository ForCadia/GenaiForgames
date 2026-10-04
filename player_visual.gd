class_name PlayerVisual
extends CharacterBody2D

# main.gd retains gameplay state; this reusable scene owns visuals and shapes.
@export var low_fire_sheet: Texture2D
@export var high_fire_sheet: Texture2D
@export var low_reload_sheet: Texture2D
@export var high_reload_sheet: Texture2D
@export var standing_shape: RectangleShape2D
@export var slide_shape: RectangleShape2D
const BODY_CELL := Vector2i(256, 256)
const ARM_CELL := Vector2i(192, 204)
# Fixed per-action baselines retain the authored airborne frames, without
# recentering individual frames from their changing alpha bounds.
const BODY_BASELINES := [216, 230, 235, 214, 231]
# Ground-contact frames place a boot on the floor. In-between airborne poses
# retain a visible rise; only the artwork moves, never the collision root.
const RUN_CONTACT_BASELINES := [229, 231, 228, 230, 229, 231, 228, 230]
# The prominent dark circle in body(2) is the right-arm socket, not a head.
# Track it by frame to attach both weapon arm layers to the actual shoulder.
const SOCKET_X := [
	[130.0, 133.0, 145.0, 149.0, 154.0, 155.0, 149.0, 149.0],
	[138.0, 140.0, 143.0, 149.0, 138.0, 143.0, 146.0, 144.0],
	[128.0, 138.0, 143.0, 115.0, 126.0, 120.0, 119.0, 134.0],
	[103.0, 79.0, 77.0, 73.0, 72.0, 113.0, 131.0, 128.0],
]
const SOCKET_TOP := [
	[38, 38, 38, 38, 38, 37, 38, 37],
	[35, 37, 31, 15, 36, 37, 34, 28],
	[92, 50, 29, 24, 20, 59, 70, 89],
	[67, 85, 110, 112, 105, 85, 56, 41],
]
const SOCKET_CENTER_FROM_TOP := 30.0
const HELMET_X_FROM_SOCKET := 16.0
const HELMET_BOTTOM_FROM_SOCKET_TOP := 20.0
const HELMET_NECK_SOURCE := Vector2(110, 152)
const BODY_FPS := 12.0
const RUN_FPS := 14.0
const RUN_FRAME_ORDER := [0, 1, 2, 7, 5, 6, 2, 1, 0, 3]
const FIRE_FRAME_TIME := 0.05
const ARM_SCALE := Vector2(0.75, 0.75)
# Both source rows have their shoulder/upper-arm root near this cell pixel.
# The pivot node represents that point, not the middle of the gun.
const ARM_ROOT_SOURCE := Vector2(40, 125)
# Row 1's left-arm shoulder sits higher inside its cell than row 0's
# weapon-arm shoulder. Its own source anchor keeps both at one pivot.
const BACK_ARM_ROOT_SOURCE := Vector2(50, 95)
const RELOAD_FRONT_ROOT_SOURCE := Vector2(40, 105)
const RELOAD_BACK_ROOT_SOURCE := Vector2(40, 110)
const HIGH_RECOVERY_LEFT_TRIM := 25
const LOW_MUZZLE_SOURCE := Vector2(174, 107)
const HIGH_MUZZLE_SOURCE := Vector2(187, 106)
const HEAD_AIM_LIMIT := 0.28

@onready var visual_root: Node2D = $VisualRoot
@onready var back_pivot: Node2D = $VisualRoot/BackArmPivot
@onready var back_arm: Sprite2D = $VisualRoot/BackArmPivot/BackArmLayer
@onready var body: AnimatedSprite2D = $VisualRoot/Body
@onready var helmet: Sprite2D = $VisualRoot/Helmet
@onready var front_pivot: Node2D = $VisualRoot/WeaponPivot
@onready var front_arm: Sprite2D = $VisualRoot/WeaponPivot/Weapon
@onready var guard_effect: Sprite2D = $VisualRoot/GuardField
@onready var solid_collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurt_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var muzzle: Marker2D = $Muzzle

var body_state := "idle"
var body_time := 0.0
var arm_action := ""
var arm_time := 0.0
var reload_duration := 1.0
var primary_slot := 0
var guard_visible := false

func _ready() -> void:
	set_collision_pose(false)
	_apply_frames()
	_update_muzzle()

func set_collision_pose(sliding: bool) -> void:
	var selected: RectangleShape2D = slide_shape if sliding else standing_shape
	var center := Vector2(0, -selected.size.y / 2.0)
	solid_collision.shape = selected
	hurt_collision.shape = selected
	solid_collision.position = center
	hurt_collision.position = center
	solid_collision.disabled = false
	hurt_collision.disabled = false
	hurtbox.monitorable = true

func standing_rect_at(feet: Vector2) -> Rect2:
	return Rect2(feet + Vector2(-standing_shape.size.x / 2.0, -standing_shape.size.y), standing_shape.size)

func hurtbox_rect() -> Rect2:
	var rect_shape := hurt_collision.shape as RectangleShape2D
	return Rect2(global_position + hurt_collision.position - rect_shape.size / 2.0, rect_shape.size)

func guard_rect() -> Rect2:
	if not guard_visible or not guard_effect.visible or guard_effect.texture == null:
		return Rect2()
	var local_rect := guard_effect.get_rect()
	var top_left := guard_effect.to_global(local_rect.position)
	var bottom_right := guard_effect.to_global(local_rect.end)
	return Rect2(top_left, bottom_right - top_left).abs()

func _update_muzzle() -> void:
	var source: Vector2 = HIGH_MUZZLE_SOURCE if primary_slot == 1 else LOW_MUZZLE_SOURCE
	muzzle.global_position = front_arm.to_global(source)

func start_scrolling() -> void:
	body_state = "startup"
	body_time = 0.0
	arm_action = ""
	arm_time = 0.0
	back_arm.visible = true
	front_arm.visible = true
	helmet.visible = true
	guard_effect.visible = false
	set_collision_pose(false)
	_apply_frames()

func set_motion(grounded: bool, crouching: bool, primary_weapon: int, target: Vector2, guard_on: bool, scrolling: bool) -> void:
	if body_state == "death":
		return
	primary_slot = primary_weapon
	guard_visible = guard_on
	guard_effect.position.y = -121 if crouching else -135
	guard_effect.visible = guard_on
	set_collision_pose(crouching)
	var desired := "run" if scrolling else "idle"
	if not grounded:
		desired = "jump"
	elif crouching:
		desired = "slide"
	if desired != body_state and not (body_state == "startup" and desired == "run"):
		body_state = desired
		body_time = 0.0
	# Both arm rows rotate together about the same shoulder pivot. HIGH/LOW
	# selects the source art only; it never changes projectile direction.
	_apply_frames()
	var angle := clampf((target - to_global(front_pivot.position)).angle(), -1.1, 1.1)
	back_pivot.rotation = angle
	front_pivot.rotation = angle
	helmet.rotation = clampf((target - helmet.global_position).angle() * 0.65, -HEAD_AIM_LIMIT, HEAD_AIM_LIMIT)
	_update_muzzle()

func play_fire() -> void:
	if arm_action == "reload" or body_state == "death":
		return
	# Invoked once per real shot, not once per frame held.
	arm_action = "fire"
	arm_time = 0.0
	_apply_frames()

func set_primary_weapon(slot: int) -> void:
	primary_slot = slot
	_apply_frames()

func play_reload(duration: float) -> void:
	if body_state == "death":
		return
	arm_action = "reload"
	arm_time = 0.0
	reload_duration = maxf(duration, 0.01)
	_apply_frames()

func play_death() -> void:
	body_state = "death"
	body_time = 0.0
	arm_action = ""
	back_arm.visible = false
	front_arm.visible = false
	# The body death poses already contain their own helmet. The separate
	# standing overlay would otherwise hover above the fallen character.
	helmet.visible = false
	guard_visible = false
	guard_effect.visible = false
	solid_collision.disabled = true
	hurt_collision.disabled = true
	hurtbox.monitorable = false
	_apply_frames()

func muzzle_world_position() -> Vector2:
	_update_muzzle()
	return muzzle.global_position

func shot_direction() -> Vector2:
	return Vector2.RIGHT.rotated(front_pivot.global_rotation)

func show_idle() -> void:
	if body_state == "death":
		return
	body_state = "idle"
	body_time = 0.0
	helmet.visible = true
	set_collision_pose(false)
	_apply_frames()

func _process(delta: float) -> void:
	body_time += delta
	if body_state == "startup" and body_time >= 8.0 / BODY_FPS:
		body_state = "run"
		body_time -= 8.0 / BODY_FPS
	if arm_action != "":
		arm_time += delta
		var limit := reload_duration if arm_action == "reload" else 3.0 * FIRE_FRAME_TIME
		if arm_time >= limit:
			arm_action = ""
			arm_time = 0.0
	_apply_frames()

func _apply_frames() -> void:
	if not is_node_ready():
		return
	var row := 0
	var column := 0
	var sequence_frame := 0
	match body_state:
		"startup":
			column = mini(7, int(body_time * BODY_FPS))
		"run":
			row = 1
			sequence_frame = int(body_time * RUN_FPS) % RUN_FRAME_ORDER.size()
			column = RUN_FRAME_ORDER[sequence_frame]
		"jump":
			row = 2
			column = mini(7, int(body_time * BODY_FPS))
		"slide":
			row = 3
			column = mini(7, int(body_time * BODY_FPS))
		"death":
			row = 4
			column = mini(7, int(body_time * BODY_FPS))
	var animation_name: StringName = StringName(["idle", "run", "jump", "slide", "death"][row])
	if body.animation != animation_name:
		body.animation = animation_name
	body.frame = sequence_frame if row == 1 else column
	var body_baseline: int = RUN_CONTACT_BASELINES[column] if row == 1 else BODY_BASELINES[row]
	body.position = Vector2(0, BODY_CELL.y / 2.0 - body_baseline)
	if row < 4:
		var socket_x: float = SOCKET_X[row][column]
		var socket_top: int = SOCKET_TOP[row][column]
		helmet.position = Vector2(socket_x + HELMET_X_FROM_SOCKET - BODY_CELL.x / 2.0, socket_top + HELMET_BOTTOM_FROM_SOCKET_TOP - body_baseline)
		back_pivot.position = Vector2(socket_x - BODY_CELL.x / 2.0, socket_top + SOCKET_CENTER_FROM_TOP - body_baseline)
		front_pivot.position = back_pivot.position

	var sheet: Texture2D
	var arm_column := 0
	if arm_action == "reload":
		sheet = high_reload_sheet if primary_slot == 1 else low_reload_sheet
		arm_column = mini(7, int(arm_time / reload_duration * 8.0))
	else:
		sheet = high_fire_sheet if primary_slot == 1 else low_fire_sheet
		if arm_action == "fire":
			arm_column = mini(2, int(arm_time / FIRE_FRAME_TIME))
	back_arm.texture = sheet
	front_arm.texture = sheet
	back_arm.region_enabled = true
	front_arm.region_enabled = true
	# Same column, separate rows: background left arm first, front gun/arms last.
	back_arm.region_rect = Rect2(Vector2(arm_column * ARM_CELL.x, ARM_CELL.y), ARM_CELL)
	back_arm.position = -RELOAD_BACK_ROOT_SOURCE if arm_action == "reload" else -BACK_ARM_ROOT_SOURCE
	var front_root: Vector2 = RELOAD_FRONT_ROOT_SOURCE if arm_action == "reload" else ARM_ROOT_SOURCE
	var front_trim := HIGH_RECOVERY_LEFT_TRIM if primary_slot == 1 and arm_action == "fire" and arm_column == 2 else 0
	front_arm.position = -front_root + Vector2(front_trim, 0)
	front_arm.region_rect = Rect2(Vector2(arm_column * ARM_CELL.x + front_trim, 0), Vector2(ARM_CELL.x - front_trim, ARM_CELL.y))
	_update_muzzle()
