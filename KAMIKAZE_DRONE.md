# 自爆无人机接入

## 素材

- 用户原始文件：`C:/Users/lenovo/Downloads/自爆无人机像素动画设计表.png`，保留原样。
- 该图是含文字、属性建议、概念图的设计表，不能直接当作规则 flipbook。
- 使用内置 image_gen 参考原图整理为 `assets/enemies/kamikaze_drone_8x6.png`，1448×1086 RGBA，8列×6行，每格181×181，背景透明，无说明文字。
- 行顺序与有效帧数：idle6、fly8、detect6、charge8、hurt4、explode8；各行多余透明格不播放。
- 飞行/冲刺图在游戏中水平翻转，向左面向玩家；冲刺图的机身偏移与碰撞框保持对齐。

## 玩法

新增独立敌人 `kamikaze_drone.gd`，不替换激光墙无人机。飞入后发现玩家，预警0.42秒，锁定当时玩家位置，以500px/s冲刺，在接触/接近目标时自爆，爆炸半径48px。

- 为当前一击死亡体系设2点敌方生命：步枪两次命中，穿甲枪一次命中。没有直接照搬设计表中15–30 HP/40–60伤害的建议。
- 保留受击、预警、冲刺和完整爆炸动画。爆炸接近玩家时可用手动/自动盾牌格挡，使用既有能量规则。
- 盾牌接触击毁或手雷清除不产生额外伤害；普通射击在近距离击毁时仍需躲避爆炸。
- 玩家击败计150分、4G，纳入整局击杀与结算；无人机自行撞击/自爆不白送击杀奖励。
- 复用无人机环境声与敌人爆炸声；菜单背景局仍静音。
- 普通三关各阶段新增一次此敌人事件，无尽波次也加入；原有事件不删除。原game_data.gd时间线未修改，LAB调用不注入新敌人，历史遥测不改。
- 已接入子弹、手雷、盾牌、自动选枪、清场/重试、阶段等待和真实菜单背景自动操作。

## 交付状态

仅修改文件、查看素材与静态代码；按用户要求，未运行游戏、导入命令、自动检查或截图。实际帧对齐、碰撞范围、节奏和难度交给用户试玩。

## 内置 image_gen 原始提示词

> Convert the LEFT animation sequences of this supplied Kamikaze Drone pixel-art design sheet into a production-ready TRANSPARENT SPRITE SHEET for a Godot game. Output ONLY a perfectly regular grid of EIGHT COLUMNS by SIX ROWS, identical cell sizes, no grid lines, no text, no labels, no concept illustration, no attribute table, no background. Keep the same olive industrial flying robot with red central eye, square side pods and orange downward thruster. It faces LEFT, toward the player's side, in flight and charge frames. Row1 idle hovering 6 frames then 2 EMPTY transparent cells; Row2 flying 8 frames; Row3 detecting/arming with red warning marks 6 frames then 2 EMPTY transparent cells; Row4 charging to the LEFT, orange trail extending RIGHT, 8 frames; Row5 damage/sparks 4 frames then 4 EMPTY transparent cells; Row6 explosion 8 frames expanding fireball then fading smoke. Preserve distinct poses and the original pixel-art design as closely as possible. Center the DRONE BODY at exactly the same pivot within every non-explosion cell, constant body size across rows, with ample room for thrusters, motion trail and explosion. No frames may touch another cell. Transparent exterior INCLUDING space around smoke/fire, no dark rectangles. Layout strictly 8 by 6, preferably 1536 by 1152 pixels. Do not add variants.

飞行修订：出生高度改为 y=300/340；进入上方区域后盘旋1.4秒，椭圆半径48×28像素，再预警0.42秒向下俯冲。目标高度限制在自身下方至少100px，因此玩家跳高时也不会反向往上冲；冲刺图跟随俯冲方向旋转。生命、分数、金币、爆炸判定不变。只改文件，未运行游戏或测试。

放大与平滑修订：动画显示格从84增至112px（约放大1/3），对应机身碰撞54×44；出生高度改为220/250。盘旋半径104×64，时长2.6秒；从椭圆底部以向左切线进入，轨道速度加位置纠偏，再通过连续速度转向，避免直接设置轨道位置。预警减速、俯冲加速、机身转角和动画挂点均做连续插值。爆炸范围48、生命/奖励与俯冲最高500px/s不变。只改文件，未运行游戏或测试。

出现范围修订：自爆无人机仅加入第二、三关和无尽，第一关不再注入，恢复原始刷怪时间线。第二、三关及无尽的敌人/障碍事件各增加一组错峰增援，包含自爆无人机，整体战斗事件数至少翻倍；手雷拾取不翻倍。只改文件，未运行测试。
