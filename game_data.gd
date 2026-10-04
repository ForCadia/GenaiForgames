class_name GameData
extends RefCounted

# All gameplay tuning lives here so the prototype can be balanced without
# touching the state-machine code.
const VIEW_SIZE := Vector2(960.0, 720.0)
const GROUND_Y := 632.0
const PLAYER_X := 190.0
const CAMPAIGN_SEGMENT_COUNT := 4

const PLAYER := {
	"gravity": 1250.0,
	"jump_speed": 720.0,
	"standing_half_width": 19.0,
	"standing_height": 92.0,
	"crouching_half_width": 27.0,
	"crouching_height": 36.0,
	"stomp_speed": 470.0,
	"obstacle_bounce": 210.0,
}

# Multiplies segment duration and event timestamps. Lower values make the
# campaign advance faster without having to rewrite every authored pattern.
const SEGMENT_PACE := 0.72
const SCROLL_MULTIPLIER := 1.5

const GUARD := {
	"maximum": 100.0,
	"drain_per_second": 66.67,
	"regen_delay": 0.75,
	"regen_per_second": 50.0,
	"break_lockout": 0.5,
}

const WEAPONS := [
	{
		"id": "rifle", "name": "ASSAULT RIFLE", "magazine": 24,
		"cadence": 0.105, "penetration": 1, "reload": 1.2,
		"projectile_speed": 1020.0, "color": Color("63e6f2")
	},
	{
		"id": "piercer", "name": "PIERCER", "magazine": 5,
		"cadence": 0.52, "penetration": 3, "reload": 1.8,
		"projectile_speed": 1280.0, "color": Color("ffcf70")
	},
]

const SCORE := {
	"unarmored": 100,
	"light": 200,
	"heavy": 300,
	"flyer": 100,
	"boss": 2000,
}

const GRENADE := {"radius": 520.0}

# Six compact prototype segments. Events are seconds from segment start.
# Each segment is independently replayable from its checkpoint.
const SEGMENTS := [
	{
		"title": "01 // MOVEMENT DRILL", "duration": 20.0, "scroll": 220.0,
		"hint": "SPACE / A: JUMP   •   STOMP ENEMIES FROM ABOVE",
		"events": [
			{"at": 1.8, "kind": "enemy", "type": "unarmored", "y": 0.0},
			{"at": 5.1, "kind": "low_obstacle"},
			{"at": 8.0, "kind": "enemy", "type": "unarmored", "y": 0.0},
			{"at": 11.0, "kind": "enemy", "type": "unarmored", "y": 0.0},
			{"at": 15.0, "kind": "low_obstacle"},
			{"at": 17.5, "kind": "enemy", "type": "unarmored", "y": 0.0},
		]
	},
	{
		"title": "02 // CROUCH & FIRE", "duration": 20.0, "scroll": 225.0,
		"hint": "S / CTRL: CROUCH UNDER HIGH FIRE",
		"events": [
			{"at": 1.5, "kind": "high_barrage"},
			{"at": 10.2, "kind": "high_barrage"},
		]
	},
	{
		"title": "03 // LIGHT ARMOR", "duration": 21.0, "scroll": 235.0,
		"hint": "Q / Y: SWITCH WEAPONS   •   PIERCER BREAKS ARMOR",
		"events": [
			{"at": 1.5, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 5.0, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 11.0, "kind": "enemy", "type": "light", "y": -125.0},
			{"at": 15.0, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 18.0, "kind": "high_barrage"},
		]
	},
	{
		"title": "04 // HEAVY ARMOR", "duration": 22.0, "scroll": 240.0,
		"hint": "RIFLE RICOCHETS   •   PIERCER BREAKS RED HEAVY ARMOR",
		"events": [
			{"at": 1.8, "kind": "enemy", "type": "heavy", "y": 0.0},
			{"at": 6.5, "kind": "enemy", "type": "unarmored", "y": 0.0},
			{"at": 9.0, "kind": "enemy", "type": "heavy", "y": 0.0},
			{"at": 12.5, "kind": "high_barrage"},
			{"at": 16.0, "kind": "enemy", "type": "heavy", "y": 0.0},
			{"at": 19.0, "kind": "low_obstacle"},
		]
	},
	{
		"title": "05 // RETURN VECTOR", "duration": 23.0, "scroll": 250.0,
		"hint": "PICK UP CYAN GRENADE   •   E / RB: ONE-SHOT CLEAR",
		"events": [
			{"at": 3.8, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 8.5, "kind": "low_obstacle"},
			{"at": 13.0, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 20.0, "kind": "low_obstacle"},
		]
	},
	{
		"title": "06 // COMBINED ARMS", "duration": 25.0, "scroll": 265.0,
		"hint": "JUMP • CROUCH • GUARD • RELOAD • CHOOSE YOUR TARGETS",
		"events": [
			{"at": 1.0, "kind": "enemy", "type": "unarmored", "y": 0.0},
			{"at": 5.0, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 7.4, "kind": "high_barrage"},
			{"at": 9.8, "kind": "enemy", "type": "heavy", "y": 0.0},
			{"at": 12.2, "kind": "low_obstacle"},
			{"at": 15.3, "kind": "enemy", "type": "light", "y": 0.0},
			{"at": 18.0, "kind": "high_barrage"},
			{"at": 20.0, "kind": "enemy", "type": "heavy", "y": 0.0},
		]
	},
]

const ENEMIES := {
	"unarmored": {"armor": 0, "hp": 1, "radius": 25.0, "local_speed": 0.0},
	"light": {"armor": 1, "hp": 1, "radius": 28.0, "local_speed": -55.0},
	"heavy": {"armor": 3, "hp": 1, "radius": 38.0, "local_speed": 28.0},
	"flyer": {"armor": 0, "hp": 1, "radius": 27.0, "local_speed": 25.0},
}

const BOSS := {
	"armor_per_cycle": 2,
	"health": 4,
	"attack_interval": 2.5,
	"telegraph_time": 0.72,
	"loop_interval": 7.0,
	"scroll": 185.0,
}
