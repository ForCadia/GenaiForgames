extends RefCounted

# Independent Endless encounter pool. No campaign stages or timelines are read.
const TYPES := ["unarmored", "light", "heavy", "kamikaze", "aerial", "gate", "spikes"]
const PROFILES := [
	{"name":"MIXED ASSAULT", "weights":[12.0,23.0,20.0,17.0,12.0,10.0,6.0]},
	{"name":"AIR RAID", "weights":[8.0,16.0,12.0,28.0,22.0,9.0,5.0]},
	{"name":"ARMORED SIEGE", "weights":[8.0,18.0,38.0,12.0,10.0,9.0,5.0]},
	{"name":"FIRELINE", "weights":[16.0,29.0,16.0,10.0,15.0,9.0,5.0]},
]

static func generate_wave(wave: int, difficulty: String = "normal") -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var profile: Dictionary = PROFILES[rng.randi_range(0,PROFILES.size()-1)]
	# Roll a fresh ratio, then turn it into quotas so small waves retain variety.
	var weights: Array[float] = []
	var weight_sum := 0.0
	for weight in profile.weights:
		var rolled := float(weight)*rng.randf_range(0.7,1.3)
		weights.append(rolled)
		weight_sum += rolled
	var normal_count := int({"easy":18,"normal":22,"hard":28}.get(difficulty,22)) + mini(10,int(maxi(0,wave-1)/5)*2)
	var quotas: Array[int] = []
	var assigned := 0
	for weight in weights:
		var count := int(floor(weight/weight_sum*normal_count))
		quotas.append(count)
		assigned += count
	while assigned < normal_count:
		var roll := rng.randf()*weight_sum
		for index in range(weights.size()):
			roll -= weights[index]
			if roll <= 0.0:
				quotas[index] += 1
				assigned += 1
				break
	var roster: Array[String] = []
	for index in range(TYPES.size()):
		var count: int = quotas[index]
		for unused in range(count): roster.append(TYPES[index])
	# Local RNG also controls order; do not consume gameplay's global RNG.
	for index in range(roster.size()-1,0,-1):
		var other := rng.randi_range(0,index)
		var previous: String = roster[index]
		roster[index] = roster[other]
		roster[other] = previous
	var spacing := maxf(0.7,1.0-float(maxi(0,wave-1))*0.025)
	var duration := 28.0*spacing*float({"easy":1.25,"normal":1.0,"hard":0.75}.get(difficulty,1.0))
	var events: Array = [{"at":0.7,"kind":"grenade"}]
	var interval := (duration-3.0)/float(roster.size())
	for index in range(roster.size()):
		var at := 1.4+(float(index)+rng.randf_range(0.1,0.9))*interval
		var enemy_type: String = roster[index]
		if enemy_type == "gate": events.append({"at":at,"kind":"high_barrage"})
		elif enemy_type == "spikes": events.append({"at":at,"kind":"low_obstacle"})
		else: events.append({"at":at,"kind":"enemy","type":enemy_type})
	return {"title":"WAVE %02d // %s" % [wave,profile.name],
		"duration":duration,"scroll":230.0,"events":events,
		"hint":"READ THE WAVE / ADAPT YOUR WEAPON","keys":["1","2","F"]}
