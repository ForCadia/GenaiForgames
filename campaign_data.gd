extends RefCounted
const GD := preload("res://game_data.gd")
const LEVELS := [
	{"name":"FRONTLINE","description":"第一关 · 前线突围｜四阶段与 Boss","tint":Color.WHITE},
	{"name":"SIGNAL BREACH","description":"第二关 · 信号封锁｜轻型火力、空袭与激光封锁","tint":Color(0.78,0.94,1.0)},
	{"name":"IRON CITADEL","description":"第三关 · 钢铁堡垒｜重甲阵地与空地协同","tint":Color(1.0,0.82,0.72)},
]
# Hand-authored phase rosters. Tokens: L light turret, H heavy turret,
# D kamikaze, G laser gate, S spikes. These are not Level01 duplicates.
const LEVEL_TWO := [
	{"title":"01 // AIRSPACE BREACH","duration":24.0,"scroll":220.0,
	"hint":"CLEAR THE AIR / SLIDE THE LASER GATES","keys":["1","S"],"beats":[
		[1.2,"L"],[2.4,"D"],[3.6,"L"],[5.0,"G"],[6.8,"L"],[8.0,"D"],
		[9.2,"H"],[10.6,"L"],[12.0,"G"],[13.8,"D"],[15.0,"L"],[16.2,"L"],
		[18.0,"G"],[19.5,"D"],[21.0,"H"],[22.5,"L"]]},
	{"title":"02 // HUNTER SWARM","duration":25.0,"scroll":225.0,
	"hint":"READ THE ORBIT / JUMP THEN REPOSITION","keys":["SPACE","A","D"],"beats":[
		[1.0,"D"],[2.1,"L"],[3.2,"D"],[4.0,"S"],[5.1,"L"],[6.2,"L"],
		[7.5,"D"],[9.0,"G"],[10.4,"L"],[11.6,"H"],[12.8,"D"],[14.0,"L"],
		[15.0,"S"],[16.4,"L"],[18.0,"G"],[19.6,"D"],[21.2,"L"],[23.0,"G"]]},
	{"title":"03 // RELAY CROSSFIRE","duration":26.0,"scroll":235.0,
	"hint":"BREAK THE ANCHOR / WATCH THE AIRSPACE","keys":["2","1","R"],"beats":[
		[1.0,"H"],[2.5,"L"],[3.7,"D"],[5.0,"G"],[6.5,"L"],[7.7,"D"],
		[9.0,"H"],[10.5,"L"],[12.0,"G"],[13.2,"D"],[14.5,"L"],[15.8,"D"],
		[17.0,"S"],[18.3,"H"],[19.6,"L"],[21.0,"D"],[22.3,"G"],[24.0,"L"]]},
	{"title":"04 // SIGNAL BLACKOUT","duration":27.0,"scroll":240.0,
	"hint":"AIR RAID / SAVE A GRENADE FOR THE PINCH","keys":["F","2","S"],"beats":[
		[1.0,"L"],[2.1,"D"],[3.2,"G"],[4.4,"L"],[5.6,"H"],[6.8,"D"],
		[8.0,"L"],[9.2,"D"],[10.5,"G"],[11.8,"L"],[13.0,"H"],[14.2,"D"],
		[15.4,"L"],[16.8,"S"],[18.0,"D"],[19.3,"G"],[20.7,"L"],[22.1,"H"],
		[23.5,"D"],[25.0,"L"]]},
]
const LEVEL_THREE := [
	{"title":"01 // ARMOR SPEARHEAD","duration":25.0,"scroll":230.0,
	"hint":"PIERCER FIRST / RIFLE ON EXPOSED TARGETS","keys":["2","1","R"],"beats":[
		[1.0,"H"],[2.0,"L"],[3.1,"H"],[4.2,"D"],[5.3,"H"],[6.4,"G"],
		[7.7,"H"],[8.8,"L"],[9.9,"H"],[11.0,"D"],[12.1,"H"],[13.2,"S"],
		[14.6,"L"],[15.7,"H"],[16.8,"H"],[18.0,"G"],[19.4,"D"],[20.6,"H"],
		[21.8,"L"],[23.0,"H"]]},
	{"title":"02 // FORTRESS BATTERIES","duration":26.0,"scroll":235.0,
	"hint":"RELOAD BETWEEN BATTERIES / KEEP YOUR SHIELD","keys":["R","RMB","2"],"beats":[
		[0.9,"H"],[1.9,"H"],[3.0,"L"],[4.0,"G"],[5.2,"H"],[6.3,"D"],
		[7.4,"H"],[8.5,"L"],[9.6,"H"],[10.7,"S"],[12.0,"H"],[13.1,"D"],
		[14.2,"H"],[15.3,"G"],[16.6,"L"],[17.7,"H"],[18.8,"H"],[19.9,"D"],
		[21.0,"G"],[22.3,"H"],[23.4,"L"],[24.6,"H"]]},
	{"title":"03 // COMBINED ARMS","duration":27.0,"scroll":240.0,
	"hint":"SPLIT YOUR AIM / AIR RAID ABOVE THE ARMOR","keys":["1","2","F"],"beats":[
		[1.0,"H"],[2.1,"D"],[3.2,"H"],[4.3,"L"],[5.4,"H"],[6.5,"G"],
		[7.8,"H"],[8.9,"D"],[10.0,"H"],[11.1,"H"],[12.2,"S"],[13.6,"L"],
		[14.7,"H"],[15.8,"D"],[16.9,"H"],[18.0,"G"],[19.3,"H"],[20.4,"H"],
		[21.5,"D"],[22.6,"L"],[23.7,"H"],[25.0,"H"]]},
	{"title":"04 // CITADEL LOCKDOWN","duration":28.0,"scroll":245.0,
	"hint":"SIEGE LINE / CLEAR THE COLLAPSE WITH A GRENADE","keys":["2","F","RMB"],"beats":[
		[0.8,"H"],[1.8,"L"],[2.8,"H"],[3.8,"D"],[4.8,"H"],[5.8,"G"],
		[7.0,"H"],[8.0,"H"],[9.0,"D"],[10.0,"L"],[11.0,"H"],[12.0,"S"],
		[13.3,"H"],[14.3,"D"],[15.3,"H"],[16.3,"L"],[17.3,"H"],[18.3,"G"],
		[19.6,"H"],[20.6,"D"],[21.6,"H"],[22.6,"L"],[23.6,"H"],[25.0,"H"]]},
]

static func _make_stage(spec: Dictionary, include_drones := true) -> Dictionary:
	var events: Array = [{"at":0.7,"kind":"grenade"}]
	for beat in spec.beats:
		var token: String = beat[1]
		if token == "D" and not include_drones: continue
		var event := {"at":float(beat[0])}
		match token:
			"G": event.kind = "high_barrage"
			"S": event.kind = "low_obstacle"
			_:
				event.kind = "enemy"
				event.type = "heavy" if token == "H" else ("kamikaze" if token == "D" else "light")
		events.append(event)
	return {"title":spec.title,"duration":spec.duration,"scroll":spec.scroll,
		"hint":spec.hint,"keys":spec.keys.duplicate(),"events":events}

static func segments(level: int, include_drones := true) -> Array:
	if level <= 0: return GD.SEGMENTS.slice(0,GD.CAMPAIGN_SEGMENT_COUNT).duplicate(true)
	var result: Array = []
	for spec in (LEVEL_TWO if level == 1 else LEVEL_THREE): result.append(_make_stage(spec,include_drones))
	return result

static func _apply_wave_difficulty(data: Dictionary, difficulty: String) -> void:
	var events: Array = []
	var seen: Dictionary = {}
	for event in data.events:
		if event.kind == "grenade":
			events.append(event)
			continue
		if difficulty == "easy":
			# Keep alternating members of each type so the mix stays recognizable.
			var type_key: String = str(event.get("type",event.kind))
			var count := int(seen.get(type_key,0))
			seen[type_key] = count+1
			if count % 2 == 0: events.append(event)
		else:
			events.append(event)
			if difficulty == "hard":
				for followup in range(1,3):
					var extra: Dictionary = event.duplicate(true)
					var gap := 0.6 if event.kind == "enemy" else 0.3
					extra.at = minf(float(event.at)+gap*followup,float(data.duration)-0.2)
					events.append(extra)
	data.events = events
	data.events.sort_custom(func(a: Dictionary,b: Dictionary): return float(a.at)<float(b.at))

static func endless_wave(wave: int, difficulty := "normal") -> Dictionary:
	# A campaign phase is one wave; each group of four is followed by a Boss.
	# Waves1-4 = Level02 phases,6-9 = Level03 phases,11-14 loop onward.
	var phases: Array = LEVEL_TWO+LEVEL_THREE
	var phase_index := maxi(0,(wave-1)-int(wave/5)) % phases.size()
	var data := _make_stage(phases[phase_index])
	_apply_wave_difficulty(data,difficulty)
	var spacing := maxf(0.7,1.0-float(wave-1)*0.025)
	data.duration *= spacing
	for event in data.events: event.at *= spacing
	data.title = "WAVE %02d // %s" % [wave,str(data.title).get_slice("//",1).strip_edges()]
	return data
