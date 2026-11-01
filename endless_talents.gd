extends RefCounted

# Run-only rewards; never written to progression profiles.
const POOL := {
	"split":{"name":"分裂弹头","text":"每层额外发射1发散射弹，不额外耗弹，可持续叠加","effects":{"multishot":1.0},"repeatable":true},
	"third_fan":{"name":"三拍齐射","text":"每第3次开火追加1发散射弹，可持续叠加","effects":{"third_fan":1.0},"repeatable":true},
	"third_ap":{"name":"三拍破甲","text":"每第3次开火的全部子弹至少具有3点穿甲（限1层）","effects":{"third_ap":1.0},"max_rank":1},
	"third_energy":{"name":"三拍充能","text":"每第3次开火恢复4点护盾能量（最多3层）","effects":{"third_energy":4.0},"max_rank":3},
	"hit_saving":{"name":"缓冲护盾","text":"每次格挡命中消耗减少3能量（最多3层）","effects":{"hit_saving":3.0},"max_rank":3},
	"reload_energy":{"name":"换弹电容","text":"完成一次正常换弹恢复10点护盾能量（最多3层）","effects":{"reload_energy":10.0},"max_rank":3},
	"kill_grenade":{"name":"爆破回收","text":"每累计击杀8个敌人获得1枚手雷（限1层）","effects":{"kill_grenade":1.0},"max_rank":1},
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
		if POOL[id].get("repeatable",false) or int(ranks.get(id,0)) < int(POOL[id].get("max_rank",5)): pool.append(id)
	var choices: Array[String] = []
	for unused in range(3):
		var index := rng.randi_range(0,pool.size()-1)
		choices.append(pool[index])
		pool.remove_at(index)
	return choices
