extends RefCounted

const GD := preload("res://game_data.gd")
const LEVELS := [
	{"name": "FRONTLINE", "description": "第一关 · 前线突围｜现有四阶段与 Boss", "tint": Color.WHITE},
	{"name": "SIGNAL BREACH", "description": "第二关 · 信号封锁｜激光墙与交错火力", "tint": Color(0.78, 0.94, 1.0)},
	{"name": "IRON CITADEL", "description": "第三关 · 钢铁堡垒｜重装敌人与混合障碍", "tint": Color(1.0, 0.82, 0.72)},
]

const LEVEL_TWO := [
	{"title": "01 // SIGNAL JAM", "duration": 24.0, "scroll": 220.0,
	 "hint": "SLIDE BENEATH THE LASER WALLS", "keys": ["S", "CTRL"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.4, "kind": "high_barrage"},
		{"at": 6.8, "kind": "enemy", "type": "unarmored"}, {"at": 10.5, "kind": "high_barrage"},
		{"at": 17.0, "kind": "enemy", "type": "light"}, {"at": 21.0, "kind": "enemy", "type": "unarmored"}]},
	{"title": "02 // LOW CLEARANCE", "duration": 25.0, "scroll": 225.0,
	 "hint": "JUMP THE SPIKES / SLIDE THE LASERS", "keys": ["SPACE", "S"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.8, "kind": "low_obstacle"},
		{"at": 6.0, "kind": "enemy", "type": "light"}, {"at": 10.5, "kind": "high_barrage"},
		{"at": 16.0, "kind": "enemy", "type": "unarmored"}, {"at": 21.0, "kind": "low_obstacle"}]},
	{"title": "03 // CROSSFIRE", "duration": 26.0, "scroll": 235.0,
	 "hint": "USE PIERCER / KEEP A RELOAD WINDOW", "keys": ["2", "R"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.8, "kind": "enemy", "type": "heavy"},
		{"at": 6.5, "kind": "enemy", "type": "light"}, {"at": 11.0, "kind": "high_barrage"},
		{"at": 17.0, "kind": "enemy", "type": "heavy"}, {"at": 22.0, "kind": "enemy", "type": "light"}]},
	{"title": "04 // RELAY BREACH", "duration": 27.0, "scroll": 240.0,
	 "hint": "SAVE A GRENADE FOR COMBINED THREATS", "keys": ["F", "2"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.5, "kind": "high_barrage"},
		{"at": 7.5, "kind": "enemy", "type": "heavy"}, {"at": 12.0, "kind": "low_obstacle"},
		{"at": 17.0, "kind": "high_barrage"}, {"at": 22.0, "kind": "enemy", "type": "heavy"}]},
]

const LEVEL_THREE := [
	{"title": "01 // ARMORED COLUMN", "duration": 25.0, "scroll": 230.0,
	 "hint": "BREAK HEAVY ARMOR WITH THE PIERCER", "keys": ["2", "R"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.8, "kind": "enemy", "type": "heavy"},
		{"at": 6.5, "kind": "enemy", "type": "unarmored"}, {"at": 11.0, "kind": "enemy", "type": "heavy"},
		{"at": 17.0, "kind": "low_obstacle"}, {"at": 22.0, "kind": "enemy", "type": "heavy"}]},
	{"title": "02 // LASER CORRIDOR", "duration": 26.0, "scroll": 235.0,
	 "hint": "READ THE NEXT HAZARD BEFORE YOU JUMP", "keys": ["SPACE", "S"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.5, "kind": "high_barrage"},
		{"at": 7.0, "kind": "enemy", "type": "light"}, {"at": 11.0, "kind": "low_obstacle"},
		{"at": 16.0, "kind": "high_barrage"}, {"at": 22.0, "kind": "enemy", "type": "light"}]},
	{"title": "03 // SIEGE PLATFORM", "duration": 27.0, "scroll": 240.0,
	 "hint": "GUARD DURING RELOAD / WATCH THE TRACK", "keys": ["RMB", "R"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.8, "kind": "enemy", "type": "heavy"},
		{"at": 6.0, "kind": "low_obstacle"}, {"at": 10.5, "kind": "enemy", "type": "heavy"},
		{"at": 15.0, "kind": "high_barrage"}, {"at": 21.0, "kind": "enemy", "type": "heavy"},
		{"at": 24.0, "kind": "enemy", "type": "light"}]},
	{"title": "04 // FINAL APPROACH", "duration": 28.0, "scroll": 245.0,
	 "hint": "CLEAR THE SCREEN WHEN PATTERNS OVERLAP", "keys": ["F", "2"], "events": [
		{"at": 0.7, "kind": "grenade"}, {"at": 1.6, "kind": "high_barrage"},
		{"at": 7.0, "kind": "enemy", "type": "heavy"}, {"at": 11.5, "kind": "enemy", "type": "light"},
		{"at": 16.0, "kind": "low_obstacle"}, {"at": 20.0, "kind": "high_barrage"},
		{"at": 25.0, "kind": "enemy", "type": "heavy"}]},
]

static func segments(level: int, include_drones := true) -> Array:
	var result: Array
	match level:
		1: result = LEVEL_TWO.duplicate(true)
		2: result = LEVEL_THREE.duplicate(true)
		_: result = GD.SEGMENTS.slice(0,GD.CAMPAIGN_SEGMENT_COUNT).duplicate(true)
	# Level 01 keeps the original authored events, including normal play.
	if level > 0 and include_drones:
		for stage in result:
			_add_drone(stage)
			_increase_pressure(stage)
	return result

static func _add_drone(stage: Dictionary) -> void:
	stage.events.append({"at":minf(8.5,float(stage.duration)*0.55),"kind":"enemy","type":"kamikaze"})
	stage.events.sort_custom(func(a: Dictionary,b: Dictionary): return float(a.at)<float(b.at))

static func _increase_pressure(stage: Dictionary, copies := 2) -> void:
	# Double combat/hazard spawns inside the existing stage duration.
	# Space the follow-up hazards farther apart than enemy reinforcements.
	var original: Array = stage.events.duplicate(true)
	for event in original:
		if event.kind not in ["enemy","high_barrage","low_obstacle"]: continue
		for copy_index in range(1,copies):
			var reinforcement: Dictionary = event.duplicate(true)
			var delay := (0.9 if event.kind == "enemy" else 1.35)*copy_index
			reinforcement.at = minf(float(event.at)+delay,float(stage.duration)-0.2)
			stage.events.append(reinforcement)
	stage.events.sort_custom(func(a: Dictionary,b: Dictionary): return float(a.at)<float(b.at))

static func endless_wave(wave: int, difficulty := "normal") -> Dictionary:
	var patterns: Array = LEVEL_TWO + LEVEL_THREE
	var data: Dictionary = patterns[(wave - 1) % patterns.size()].duplicate(true)
	_add_drone(data)
	_increase_pressure(data,1 if difficulty == "easy" else (6 if difficulty == "hard" else 2))
	# Increase density gradually, capped at 30%; world and projectile speeds stay authored.
	var spacing := maxf(0.7, 1.0 - float(wave - 1) * 0.025)
	data.duration *= spacing
	for event in data.events: event.at *= spacing
	return data
