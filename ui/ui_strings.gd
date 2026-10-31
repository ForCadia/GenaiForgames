class_name UIStrings
extends RefCounted

const TITLE := "EVERFRONT"
const SUBTITLE := "THE FRONT NEVER STOPS"
const START := "START GAME"
const CONTROLS := "CONTROLS"
const SETTINGS := "SETTINGS"
const QUIT := "QUIT"
const BACK := "BACK"
const RESUME := "RESUME"
const RETURN_TITLE := "RETURN TO TITLE"
const DEVELOPER := "开发模式"
const BOSS_TEST := "Boss 战测试"
const VERSION := "v0.1  /  ENTER TO SELECT MISSION"
const PAUSED := "PAUSED"
const RETRY := "RETRY [R]"
const REDEPLOY := "REDEPLOY [R]"
const DEATH := "MISSION FAILED"
const VICTORY := "MISSION COMPLETE"
const RELOADING := "RELOADING"
const TEST_RUN := "TEST RUN / NOT RANKED"
const WEAK_POINT := "WEAK POINT EXPOSED"
const BOSS_NAME := "SENTINEL"
const ARMOR_BREAK := "ARMOR BREAK"
const WEAPONS := ["ASSAULT RIFLE", "PIERCER", "GRENADE"]
const STAGES := ["MOVEMENT DRILL", "CROUCH & FIRE", "LIGHT ARMOR", "HEAVY ARMOR"]
const TUTORIALS := ["JUMP / STOMP ENEMIES FROM ABOVE", "SLIDE UNDER LASER WALLS", "SWITCH WEAPONS / BREAK ARMOR", "PIERCER BREAKS HEAVY ARMOR"]
const TUTORIAL_KEYS := [["SPACE", "W"], ["S", "CTRL"], ["1", "2", "Q"], ["2", "R"]]
const CONTROLS_ROWS := [
	["A / D", "--", "HOLD TO MOVE / RELEASE TO RETURN"],
	["SPACE / W", "A / CROSS", "JUMP"], ["S / CTRL", "LEFT STICK DOWN", "CROUCH / SLIDE"],
	["MOUSE", "RIGHT STICK", "AIM"], ["LMB", "RT / R2", "FIRE"], ["RMB", "LT / L2", "GUARD"],
	["1 / 2 / 3", "--", "WEAPON SLOTS"], ["Q / WHEEL", "Y / TRIANGLE", "CYCLE WEAPON"],
	["R", "X / SQUARE", "RELOAD"], ["F", "RB / R1", "SCREEN-CLEAR GRENADE"], ["ESC", "--", "PAUSE / BACK"],
]
const CAUSES := {"GROUND SPIKES":"Hit ground spikes","HOSTILE FIRE":"Hit by enemy fire", "BOSS HIGH PARTICLE":"Hit by Boss energy fire", "BOSS BOMB":"Caught in a Boss bomb blast", "HEAVY TURRET LASER":"Hit by a heavy turret laser", "TURRET COLLISION":"Collided with a turret", "GROUND SPIKES // UNBLOCKABLE":"Hit ground spikes", "LASER GATE":"Hit a laser wall"}

static func death_cause(raw: String) -> String:
	return CAUSES.get(raw, raw.replace("_", " ").capitalize())
