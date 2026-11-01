extends RefCounted

# Run-only rewards; never written to progression profiles.
const POOL := {
	"loader":{"name":"快速供弹","text":"换弹时间 -8%（最多5层）","effects":{"reload":-0.08}},
	"trigger":{"name":"火力超频","text":"射击间隔 -6%（最多5层）","effects":{"cadence":-0.06}},
	"magazine":{"name":"弹仓扩充","text":"步枪弹匣 +4，穿甲弹匣 +1（最多5层）","effects":{"rifle_mag":4.0,"piercer_mag":1.0}},
	"battery":{"name":"备用电池","text":"护盾能量上限 +20（最多5层）","effects":{"capacity":20.0}},
	"recovery":{"name":"回充线圈","text":"护盾每秒恢复 +3（最多5层）","effects":{"regen":6.0}},
	"recycle":{"name":"击杀回能","text":"每次击杀恢复2点护盾能量（最多5层）","effects":{"kill_energy":2.0}},
	"efficient":{"name":"节能立场","text":"持续开盾消耗 -8%（最多5层）","effects":{"drain":-0.08}},
	"grenade":{"name":"爆破补给","text":"立即获得2枚手雷，可重复选择","effects":{},"repeatable":true},
	"ballistics":{"name":"弹道强化","text":"子弹速度 +5%，可重复选择","effects":{"projectile":0.05},"repeatable":true},
	"ammo":{"name":"弹药补给","text":"立即装满两把武器，获得1枚手雷，可重复选择","effects":{},"repeatable":true},
}

static func roll(ranks: Dictionary) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var pool: Array[String] = []
	for id in POOL:
		if POOL[id].get("repeatable",false) or int(ranks.get(id,0)) < 5: pool.append(id)
	var choices: Array[String] = []
	for unused in range(3):
		var index := rng.randi_range(0,pool.size()-1)
		choices.append(pool[index])
		pool.remove_at(index)
	return choices
