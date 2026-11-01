extends RefCounted

# Encounter pressure points, independent of kill score/currency.
const LIMIT := 100
const SPAWN_GAP := 0.6
const COSTS := {"unarmored":25,"light":25,"heavy":50,"kamikaze":35}
const GATE_COST := 40
const SPIKES_COST := 25

static func event_cost(event: Dictionary) -> int:
	match event.kind:
		"enemy": return int(COSTS.get(event.get("type","light"),25))
		"high_barrage": return GATE_COST
		"low_obstacle": return SPIKES_COST
	return 0
