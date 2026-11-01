# 金币与三向构筑树

本次为用户授权的游戏成长系统，不改历史实验记录。普通三关和无尽模式启用；开发模式与 Boss 测试不应用购买效果、不产生金币，保留原始测试参数。

## 金币和结算

- 普通/轻型炮塔掉落 3 G，重型炮塔 7 G，无人机 4 G，Boss 35 G。金币落地随跑道移动，金币落地弹跳后默认飞向角色，不受距离限制，角色在空中也能追踪；拾取立即写入本地钱包。
- 通关时收取场上余下金币，奖励为整局击杀数 × 2，加第一/二/三关的 40/60/80 G 通关奖励。
- 无尽模式死亡时结算，奖励为整局击杀数 × 2，加已完成波数 × 3 G；Boss 波结束时收取场上余下金币。
- 击杀数包含 Boss、手雷击杀；子弹数只计真正射出的玩家枪弹。两个计数跨检查点重试累计；新开一局重置。普通死亡不额外结算奖励，已捡金币保留。返回标题不发通关奖励。
- 同一局结算仅发奖一次。每项升级只能购买一次，要求其所有前置节点已购买。不互斥，可逐步买满三条路线。
- 存档：`user://progression.cfg`。测试参数 `--lab-test` 使用内存钱包，不读写真实成长存档。

## 构筑路线

共 21 个节点，每向 7 个，三向各有两条分支，再汇合到终极节点。每向花费依序为 25、40、40、65、65、95、150 G，总计 480 G。

| 方向 | 前置节点 | 终极效果 |
| --- | --- | --- |
| 上方：回盾 | 能量上限、回盾延迟、恢复速度、耗尽锁定时间 | 恢复到原来的 50 能量/秒；未升级普通模式为 12.5/秒 |
| 左下：防护 | 拾取范围、击杀回能、开盾持续耗能、应急能量 | 可格挡致命伤来临前自动开盾，至少需要 7 能量且未锁定；右键按住手动接管，松开恢复自动 |
| 右下：武器 | 换弹、弹匣容量、射速、弹速 | 开火时根据准星目标护甲选枪：重甲穿甲枪，其余步枪；不抢占手雷槽，不自动换弹 |

用户后续修订：地刺现在也可触发自动盾牌，成功格挡会清除该组地刺；其他仍标记为不可格挡的伤害不变。护盾减耗仅影响持续开盾耗能，单次格挡仍消耗 7 能量。具体升级效果和位置集中在 `build_data.gd`。

重型炮塔激光从 700 加长到 1400 像素，光束、预警线、碰撞区域同步加长。

## 设计参考

参考持续成长游戏的能力分类和金币升级循环，未复制数值或技能树：

- [Deep Rock Galactic: Survivor — Meta Upgrades](https://deeprockgalactic.wiki.gg/wiki/Survivor%3AMeta_Upgrades)：持续升级、拾取距离、装填和射速等分支思路。
- [官方商店说明](https://store.steampowered.com/app/2321470/Deep_Rock_Galactic_Survivor/)：战斗资源与后续强化循环。

## 验证

Godot 编辑器导入、`tests/progression_smoke.gd`、`tests/campaign_modes_smoke.gd`、`tests/start_modes_smoke.gd`。新增测试覆盖购买前置/重复购买、金币拾取、结算去重、三种终极升级、手动盾牌接管、无能量死亡、重甲/裸露目标切枪和开发模式隔离。构筑树另在 960×720 原始画面截图检查。

## Follow-up revision

- 金币使用内置 image_gen 生成的透明像素素材 `assets/items/credit_coin.png`，提示词保存在同目录 `.source.md`。每个敌人散出最多五枚，分摊原有金币总值，抛射、落地反弹一次后可以拾取，不增加掉落总额。
- 自动切枪先检查目标当前所需穿甲（Boss 使用实时形态），再在可穿甲的武器中比较持续 DPS，包含弹匣、射速和换弹。准星方向没有目标时也重新比较 DPS，因此不会一直停留在穿甲枪。手雷槽和手动装填保留。
- 新存档初始 600 G。旧存档以 `test_grant_600_v1` 标记做一次补足至 600 G；超过 600 G 保留，已经购买的升级保留。标记保存后不会在每次启动时补发。
- Boss 从屏幕右侧外 220 像素以 250 像素/秒飞到作战位置，入场完成后启用攻击与受击；重试和无尽 Boss 波也使用同一入场。


## 默认金币回收修订

金币完成落地弹跳后以 720 像素/秒飞向角色，飞行阶段不再叠加世界滚动和重力，也不会因为在角色身后而丢失。下落时即便暂时移出画面，也保留到落地飞回。
原 magnet 节点改为“战斗回能”：击杀恢复 3 点护盾能量；sensor_two 改为“能量回收”：击杀回能再 +2，保留拾取距离 +16。内部 ID、价格和前置保持不变，所以旧存档已购买的节点直接生效，无需重买。回能只影响当前能量，不绕过护盾锁定，不超过能量上限。

Latest combat balance: shield base regeneration is now 6.25/s, intermediate regeneration bonuses are 3.125/s and 6.25/s, and the capstone is 25/s. Sustained drain is 1.5×, impact cost 18 and recharge delay is +0.5s. These supersede the earlier 12.5/50/7 descriptions above. Upgrade costs, prerequisite IDs and saved purchases are unchanged. See COMBAT_BALANCE.md.

智能切枪终极节点现在同时提供自动换弹：当前枪弹匣为空且最后一发冷却结束后，按正常换弹时间装填，不需要按 R。保留目标护甲/DPS 选枪与手雷选择，价格、前置、ID 和已购存档不变。tests/smart_weapon_smoke.gd 验证两把枪、正常换弹时长、未购买状态、手雷槽与 LAB 隔离。


Latest manual weapon priority (2026-10-31): manually selecting AP via slot2, Q or wheel sets a run-local AP lock. Smart selection cannot return to rifle while locked, even after armor breaks or aim leaves the enemy. Manually selecting rifle clears the lock and restores armor/DPS automation. Automatic AP selection never creates a manual lock. Grenade selection preserves the lock, auto-reload remains active, natural stage transitions preserve it; new runs/title clear it. No persistence or upgrade cost changes. No runtime tests.
