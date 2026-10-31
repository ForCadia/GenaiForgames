extends RefCounted

const A_MAX_DEATHS := 2
const B_MAX_DEATHS := 5

static func calculate(deaths: int) -> String:
	if deaths == 0: return "S"
	if deaths <= A_MAX_DEATHS: return "A"
	if deaths <= B_MAX_DEATHS: return "B"
	return "C"
