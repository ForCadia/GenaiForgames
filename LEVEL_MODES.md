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


## Endless roguelite rewards and difficulty pacing — 2026-10-31

Supersedes earlier Endless half/triple total-count and universal100-cap rules. All difficulties now use the same22–32 combat-event budget for a given wave; randomized composition still varies per run. Easy/Normal/Hard active caps are50/100/150, minimum spawn gaps0.9/0.6/0.4s and planned wave duration factors1.25/1.0/0.75 respectively. Budget queues may extend the actual wave. Level02/03 retain100 cap and0.6s gap. Boss every fifth wave remains unchanged.

Every cleared Endless wave, including Boss waves, pauses gameplay and offers three distinct random run-only talents before advancing. The pool includes reload speed, fire cadence, magazines, shield capacity/regen/kill recovery/efficiency, projectile speed and grenade/ammo supplies. Ordinary stat talents cap at5 ranks; supply and projectile options remain repeatable so three options always exist. Reload/cadence/drain reductions are bounded to avoid zero/negative values when combined with purchased build upgrades. Talents accumulate only in memory, clear on new run/retry/title and never modify purchased upgrades, saved wallets or campaign balance. Choice inputs are gated before combat resumes; title demo picks automatically. No game/import/tests/captures were run; user tests manually.


Latest Endless entry UI: mission selector now shows three direct-start buttons labeled 简单无尽 / 普通无尽 / 困难无尽 in one row, each displaying its pressure cap. Removed the separate Endless start row and difficulty toggles. All three use the same existing Endless unlock requirement. No gameplay values changed; no runtime tests.


Latest UI simplification: Endless section shows only ENDLESS and 简单无尽 / 普通无尽 / 困难无尽 entry labels, without budget numbers or rules copy. Upper-center temporary combat notices and phase banners are hidden; progress/Boss HUD and lower tutorial remain. Gameplay unchanged. File-only edits, no tests.


## Expanded Endless combat synergies — 2026-10-31

Existing fire-rate, magazine and shield-stat talents remain. New run-only choices:

| Talent | Effect | Rank limit |
|---|---|---|
| Split rounds | +2 symmetric extra rounds per trigger, one ammunition consumed; retains center aim | 2 |
| Third-shot volley | Every third trigger adds2 more rounds; stacks with split | 2 |
| Third-shot AP | Every third trigger gives all its rounds at least3 armor penetration | 1 |
| Third-shot charging | Every third trigger restores4 shield energy per rank | 3 |
| Buffer shield | Reduce block hit cost by3 per rank, minimum6 energy | 3 |
| Reload capacitor | A completed normal reload restores10 shield energy per rank | 3 |
| Explosive recycling | Every eighth cumulative run kill grants one grenade | 1 |

Trigger cadence is shared across guns and waves, independent of the number of spawned bullets; extra bullets cannot recursively trigger rewards. Split/volley ranks combine up to9 rounds on a third trigger at maximum ranks. All rounds use normal hit/armor checks. Shot statistics count actual emitted bullets. A new run or return to title clears trigger cadence and talents. Reward descriptions wrap within taller choice buttons. Campaigns gain none of these talents.

Design reference: SYNTHETIK developer updates (https://www.synthetikgame.com/updates), for ammunition/weapon/shield item synergies; these particular numeric rules are authored for EverFront, not copied as game facts. No game/import/tests/captures were run.


## Running-track talent selection — 2026-10-31

Supersedes the frozen black-overlay reward UI. At each Endless clear, bank remaining coins and clear combat actors/rounds, then keep a safe empty track scrolling with player movement/jump and animation active. No timeline/spawn/combat time advances while choosing. Three square monitor cards use the existing ui_title_terminal.png artwork with preserved corner sizes; hanging supports descend from the top with staggered0.65s entrance. No full-screen shade or input-capturing background. Cards show the generated transparent upgrade-chip icon, name/rank and wrapped effect text. Selection applies one reward and retracts all screens over0.55s before spawning the next wave; duplicate selections are gated. The user can still Esc to title. Empty track persists until selection, no auto timeout. User tests; no runtime/import/capture checks.


Latest tuning/presentation: Endless per-wave budgets now start Easy18/Normal22/Hard28, each gains2 per five waves capped at+10 (28/32/38). Pressure caps50/100/150 and existing spawn pacing remain; replaces equal-count rule without restoring3x Hard. Split and third-trigger volley now add exactly1 round per rank and can be selected repeatedly without rank cap. Center round remains aimed; extras alternate above/below and fan angles approach28 degrees. Reward cards remove rectangular yellow focus outline, use monitor brightness for focus/hover, replace plain cable bars with the existing generated mechanical pedestal leg used as an inverted overhead mount with uniform aspect ratio, and enlarge title/effect/rank text to22/18/15. No tests/import/game/captures run.


Latest Endless talents — homing and target piercing: homing is a single-rank fully guided upgrade (supersedes the initial graded proposal). Each round retains a live target, directly steers at unchanged speed toward its real hurtbox center, switches when unavailable/already hit, and resolves contact distance without orbiting. Laser gates use an emitter hitbox rather than the empty middle. Piercing has four ranks, granting1/2/3/4 additional enemy passes (up to2/3/4/5 unique targets including the first). Target piercing never raises armor penetration. All split/third-shot rounds inherit both talents. Hit IDs exclude repeated damage/retargeting to an already-hit actor; same-frame crossed actors resolve in travel order, Boss counts as one unique actor. Hostile projectiles are not homing targets. Run talents still clear on restart/title; no permanent tree/currency changes. File-only edits; no runtime tests.


Latest homing balance: four ranks now guide one actual emitted projectile per5/4/3/2 rounds. This counts split/volley rounds individually, so an entire volley does not become guided at once. Non-proc rounds remain ballistic; proc rounds retain full guidance. Homing cadence is run-local and clears on restart/title. Talent cards now state effects only, without rule explanations/rank-cap prose; homing card describes its next-rank interval. No runtime tests.


Latest enemy addition: aerial riflemen appear only in Level03 and Endless. Level03 swaps7 kamikaze events for riflemen; total roster length unchanged. Endless incorporates their own weights (mixed12%, air22%, armor10%, fire15%), keeping difficulty counts/pressure caps unchanged. Their40-point cost limits simultaneous pressure. See AERIAL_RIFLEMAN.md. No runtime testing.


Latest Endless Boss-clear correction: the existing1s death showcase previously updated only a countdown, freezing track/player motion. Intermission now continues player motion/airborne physics, animation, parallax and coin movement while clearing player/hostile rounds; no combat or spawning resumes until talent choice. Existing death showcase/reward cadence retained. Inspected current runtime log: no related script errors recorded; no game/tests run.


Mecha mission integration (2026-10-31): campaign Level03 now ends with the gunblade mecha; Levels01/02 retain the eye. Endless Boss encounters remain every fifth wave, alternating mecha at5/15/25 and eye at10/20/30. Explicit Boss-test selection still overrides mission selection; historical LAB remains on eye. Mecha current cadence is normal: Endless easy multiplies preparation/recovery waits by1.5, hard by0.75, normal1.0. Fixed combat animation/damage/HP/projectile and movement speeds stay unchanged. Campaign03 and Boss test always use normal, independent of last selected Endless difficulty. Telegraph cross progress follows the adjusted windup. Existing retry, shared kill/reward, grenade and Boss HUD paths dispatch to selected Boss. Source inspection only, no engine/tests per user.
