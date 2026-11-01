extends RefCounted

# Encounter pressure points, independent of kill score/currency.
const LIMIT := 100
const SPAWN_GAP := 0.6
const COSTS := {"unarmored":25,"light":25,"heavy":50,"kamikaze":35,"aerial":40}
const GATE_COST := 40
const SPIKES_COST := 25

static func event_cost(event: Dictionary) -> int:
	match event.kind:
		"enemy": return int(COSTS.get(event.get("type","light"),25))
		"high_barrage": return GATE_COST
		"low_obstacle": return SPIKES_COST
	return 0

static func endless_limit(difficulty: String) -> int:
	return int({"easy":50,"normal":100,"hard":150}.get(difficulty,100))

static func endless_gap(difficulty: String) -> float:
	return float({"easy":0.9,"normal":0.6,"hard":0.4}.get(difficulty,0.6))
