# Three missions and endless mode — 2026-10-31

The main menu's START GAME button opens SELECT MISSION. All three missions and ENDLESS MODE are available immediately. Back/Esc returns to the title. Opening the selector does not start a run; selecting a mission starts it with the existing held-input gate.

| Mode | Content |
|---|---|
| Level 01 — Frontline | Existing four stages and Boss, with original event data retained |
| Level 02 — Signal Breach | Four new timelines: Signal Jam, Low Clearance, Crossfire, Relay Breach; laser walls and staggered turret pressure; cooler background tint |
| Level 03 — Iron Citadel | Four new timelines: Armored Column, Laser Corridor, Siege Platform, Final Approach; heavy turret and mixed-hazard encounters; warmer background tint |
| Endless | Survive repeating authored patterns; a Boss every fifth wave; normal-wave event spacing gradually reaches a 30% reduction cap; no final victory state |

New missions reuse the existing environment, music, enemies, Boss and attacks. They are new encounter arrangements, not new map artwork or Boss assets. Movement, firearms, grenade behavior and Boss health remain the existing authored defaults. Each regular stage and Boss encounter supplies a grenade opportunity. HUD identifies the mission or wave and retains the four-stage-plus-Boss progress blocks.

Ordinary mission deaths retry the selected mission's checkpoint and restore checkpoint resources. A campaign reset restarts that selected mission. Victory offers NEXT MISSION where available, REDEPLOY for the same mission, or Return to Title. Selecting another mission or starting a new run clears score/time/inventory for that run.

Endless carries score and grenades between waves. Clearing a Boss awards its score, holds a one-second protected transition, then starts the next wave. Death records score and wave and retries from wave one with fresh resources. No endless checkpoint farming or repeated victory dialog occurs. Records are separate per mission and for endless, and the old Level 01 best-score key is retained. Record saving loads the existing ConfigFile before changing keys so other records survive. Results are captured when the run ends even if retry input was already buffered.

Development and Boss-test entry points always use Level 01; new missions/endless do not enable telemetry or modify retained developer sessions. Existing historical tester JSON is unchanged. `campaign_data.gd` owns the new timelines and endless spacing rule; `game_data.gd` remains the baseline.

The UI gallery includes LevelSelect, Level2, Level3 and Endless pages. `tests/campaign_modes_smoke.gd` covers timeline ordering, selection, checkpoint identity, the fifth-wave Boss, sixth-wave continuation, fresh endless retries and developer isolation. Godot editor script import, campaign_modes_smoke and start_modes_smoke passed. The existing start-mode suite reported a non-fatal ObjectDB shutdown cleanup warning; no script/assertion failures occurred. Gameplay balancing and full runs remain for the user's manual testing. No package was rebuilt.

Latest pressure revision: Level01 keeps the original GD timelines without kamikaze injection. Level02/03 and Endless add kamikazes and double enemy/hazard spawns with0.9s enemy or1.35s hazard follow-ups (authored timeline time, before the existing pace/Endless spacing). Original duration, scroll and Boss values remain. This supersedes earlier unchanged-pressure descriptions for later missions only; no runtime tests performed.

无尽难度：选关页增加简单/普通/困难选择，默认普通。当前加强版即普通（每组2份敌人/障碍）；简单1份，困难3份，即简单约普通一半、困难约普通1.5倍刷怪。沿用逐波间隔加压、每五波Boss和原Boss数值；手雷不翻倍。难度随本轮重试保留，成绩与最高波数分别记录，普通保留原记录键。无尽解锁后一起开放。只改文件，未运行测试。

困难倍率更新：困难现在为普通刷怪量的3倍（原始事件6份，普通2份）；覆盖此前1.5倍说明。简单和普通不变。未运行测试。


## Latest encounter redesign — campaign phases as waves (2026-10-31)

This supersedes the older duplicate-event pressure implementation and old stage names above. Level01 and historical LAB retain their original timelines. Level02/03 now use independent hand-authored event rosters in campaign_data.gd, rather than copying Level01 or duplicating each campaign event.

- Level02: Airspace Breach, Hunter Swarm, Relay Crossfire, Signal Blackout. Light turret fire, kamikaze air raids and laser gates dominate, with occasional heavy anchors and spikes.
- Level03: Armor Spearhead, Fortress Batteries, Combined Arms, Citadel Lockdown. Heavy turrets dominate, with mixed airborne pressure, light turrets and fewer track hazards.
- Each ordinary campaign phase is one Endless wave. Waves1–4 use the four Level02 phases; wave5 is Boss; waves6–9 use the four Level03 phases; wave10 is Boss. This ten-wave sequence then repeats with the existing gradually reduced timing interval (30% cap).
- Normal uses the authored roster. Easy keeps alternating events within each enemy/hazard type (approximately half). Hard uses exactly three copies per Normal combat event, staggered in time. Grenade supplies and Boss stats do not scale with difficulty.
- Stage durations and scroll values remain as previously authored. Mission descriptions now reflect the distinct encounter mixes.

Only files were edited. No game, imports, captures or tests were run; manual acceptance is left to the user.


## Independent randomized Endless — 2026-10-31

Supersedes the campaign-phase mapping above. Endless now uses endless_data.gd exclusively for its normal waves. It never reads Level01/02/03 encounter data. Each wave randomly selects a dedicated mixed/air-raid/armor/fireline profile, varies its type weights by 0.7–1.3, derives type quotas and shuffles spawn order with jittered times. The pool includes unarmored/light/heavy enemies, kamikazes, laser gates and spikes. Normal begins with22 combat events, rising by2 per five waves to32. Easy approximately halves type quotas; Hard triples them. Waves start at28 seconds with the existing30% interval reduction cap. One grenade supply remains per wave; Boss still appears every fifth wave with unchanged stats. New runs roll new waves; campaign encounters are unchanged. No runtime tests/imports/captures performed.


## Active threat budget — 2026-10-31

Level02, Level03 and Endless share an active pressure cap of100 points, separate from kill score and rewards. Light/unarmored turret25, heavy50, kamikaze35, laser gate40, spikes group25. Offscreen incoming actors reserve points immediately. Dead turrets/destroyed gates release points immediately; kamikaze explosions retain their reservation until finished because they can still hurt. Actors leaving the world also release points. Due events exceeding the cap wait in timeline order, with at least0.6 seconds between combat spawns to prevent backlog bursts. Supplies cost0. The stage waits until the delayed event queue has been dispatched before beginning its normal cleanup/transition. Hard keeps3x total events but shares the same active cap. Level01, historical LAB and Boss are unchanged. No game/import/tests/captures run.
