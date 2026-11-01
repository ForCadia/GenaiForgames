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
