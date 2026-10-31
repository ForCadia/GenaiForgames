extends RefCounted

# Nodes use a common root, fork within each arm, and rejoin before the capstone.
const NODES := {
	"cell": {"name":"扩容电池", "cost":25, "parents":["core"], "branch":"regen", "pos":Vector2(430,194), "text":"护盾能量上限 +15", "effects":{"capacity":15.0}},
	"recharge_delay": {"name":"快速回充", "cost":40, "parents":["cell"], "branch":"regen", "pos":Vector2(330,146), "text":"护盾恢复等待缩短 0.15 秒", "effects":{"regen_delay":-0.15}},
	"regen_one": {"name":"回收线圈", "cost":40, "parents":["cell"], "branch":"regen", "pos":Vector2(530,146), "text":"护盾恢复 +3.125 能量/秒", "effects":{"regen":6.25}},
	"cell_two": {"name":"储能阵列", "cost":65, "parents":["recharge_delay"], "branch":"regen", "pos":Vector2(300,100), "text":"护盾能量上限再 +15", "effects":{"capacity":15.0}},
	"regen_two": {"name":"再生线圈", "cost":65, "parents":["regen_one"], "branch":"regen", "pos":Vector2(560,100), "text":"护盾恢复再 +6.25 能量/秒", "effects":{"regen":12.5}},
	"stabilizer": {"name":"稳定电路", "cost":95, "parents":["cell_two","regen_two"], "branch":"regen", "pos":Vector2(430,76), "text":"护盾耗尽后的锁定时间缩短 0.20 秒", "effects":{"guard_lock":-0.20}},
	"fast_regen": {"name":"终极·高速回盾", "cost":150, "parents":["stabilizer"], "branch":"regen", "pos":Vector2(430,20), "text":"护盾恢复提升至 25 能量/秒", "effects":{}},
	"sensor": {"name":"拾取感应", "cost":25, "parents":["core"], "branch":"defense", "pos":Vector2(330,300), "text":"金币拾取距离 +16 像素", "effects":{"pickup":16.0}},
	"magnet": {"name":"战斗回能", "cost":40, "parents":["sensor"], "branch":"defense", "pos":Vector2(200,315), "text":"每击败一个敌人恢复 3 点护盾能量", "effects":{"kill_energy":3.0}},
	"guard_eff": {"name":"节能护盾", "cost":40, "parents":["sensor"], "branch":"defense", "pos":Vector2(340,365), "text":"开盾持续耗能降低 10%", "effects":{"drain":-0.10}},
	"sensor_two": {"name":"能量回收", "cost":65, "parents":["magnet"], "branch":"defense", "pos":Vector2(125,370), "text":"击杀回能再 +2，金币拾取距离再 +16", "effects":{"pickup":16.0,"kill_energy":2.0}},
	"guard_eff_two": {"name":"能量整流", "cost":65, "parents":["guard_eff"], "branch":"defense", "pos":Vector2(260,405), "text":"开盾持续耗能再降低 10%", "effects":{"drain":-0.10}},
	"guard_reserve": {"name":"应急储备", "cost":95, "parents":["sensor_two","guard_eff_two"], "branch":"defense", "pos":Vector2(145,420), "text":"护盾能量上限再 +20", "effects":{"capacity":20.0}},
	"auto_guard": {"name":"终极·自动护盾", "cost":150, "parents":["guard_reserve"], "branch":"defense", "pos":Vector2(70,465), "text":"可格挡致命命中前自动开盾；需至少 7 能量，右键手动优先", "effects":{}},
	"loader": {"name":"供弹优化", "cost":25, "parents":["core"], "branch":"offense", "pos":Vector2(530,300), "text":"换弹时间缩短 8%", "effects":{"reload":-0.08}},
	"magazine": {"name":"扩展弹匣", "cost":40, "parents":["loader"], "branch":"offense", "pos":Vector2(660,315), "text":"步枪弹匣 +4，穿甲枪弹匣 +1", "effects":{"rifle_mag":4.0,"piercer_mag":1.0}},
	"fire_rate": {"name":"扳机调校", "cost":40, "parents":["loader"], "branch":"offense", "pos":Vector2(520,365), "text":"射击间隔缩短 6%", "effects":{"cadence":-0.06}},
	"magazine_two": {"name":"弹仓改造", "cost":65, "parents":["magazine"], "branch":"offense", "pos":Vector2(735,370), "text":"步枪弹匣再 +4，穿甲枪弹匣再 +1", "effects":{"rifle_mag":4.0,"piercer_mag":1.0}},
	"projectile": {"name":"弹道加速", "cost":65, "parents":["fire_rate"], "branch":"offense", "pos":Vector2(600,405), "text":"玩家子弹飞行速度提高 10%", "effects":{"projectile":0.10}},
	"loader_two": {"name":"联动供弹", "cost":95, "parents":["magazine_two","projectile"], "branch":"offense", "pos":Vector2(715,420), "text":"换弹时间再缩短 8%", "effects":{"reload":-0.08}},
	"auto_weapon": {"name":"终极·智能切枪", "cost":150, "parents":["loader_two"], "branch":"offense", "pos":Vector2(790,465), "text":"按目标护甲与 DPS 智能切枪；弹匣打空自动换弹，保留手雷选择", "effects":{}},
}
const COIN_VALUES := {"unarmored":3, "light":3, "heavy":7, "flyer":4, "boss":35}
const BASE_REGEN := 12.5
const ORIGINAL_REGEN := 50.0
const ROOT_POSITION := Vector2(430,250)
