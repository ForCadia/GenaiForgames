# Project instructions

## Stack

- Godot **4.7.2.stable.official.ed1daf0bf**, GDScript, 2D scene nodes. Verified with local executable `--version` on 2026-10-04.
- No game runtime packages, JavaScript libraries, AI services, or API keys.
- Desktop retains Forward Plus. Web uses Godot Compatibility renderer and single-threaded native export. Matching **4.7.2.stable** export templates are required.

## Install, run, verify, export

Install Godot 4.7.2 and its matching export templates through Editor > Manage Export Templates. Open `project.godot`; F5 runs `main.tscn`. Command examples assume `godot` refers to that exact executable:

```powershell
godot --version
godot --path .
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/gameplay_smoke.gd -- --lab-test
godot --headless --path . --script res://tests/lab_b_smoke.gd -- --lab-test
godot --headless --path . --script res://tests/start_modes_smoke.gd -- --lab-test
godot --headless --path . --script res://tests/airtime_smoke.gd -- --lab-test
New-Item -ItemType Directory -Force build/web
godot --headless --path . --export-release Web build/web/index.html
python -m http.server 8000 --directory build/web
```

Open `http://localhost:8000` in a browser. Do not open `index.html` with `file://`. `Web` preset uses no threads and excludes test assets, private telemetry, temporary files and docs. Upload all exported files together. No Node.js or engine migration is required. See README for deployment.

This checkout currently has Web custom templates at ignored `tmp/web-templates/web_nothreads_debug.zip` and `web_nothreads_release.zip` (official 4.7.2 package). To reproduce them, run `python tools/fetch_web_templates.py`; the tool downloads only Web entries using HTTP byte ranges and needs Python's standard library. Alternatively install standard export templates and clear the Web preset's custom-template fields. Temporary downloads are not included in Git.

## Structure

- `main.gd`, `main.tscn`: simulation, campaign, collision, score, checkpoints, effects.
- `game_data.gd`: original authored defaults and timeline (four segments active, six defined).
- `Player*`, `player_visual.gd`, `player_hud.gd`: player artwork, shapes and HUD.
- Enemy scenes and scripts: turrets, laser gates, spikes, Boss and attacks.
- `lab_panel.gd`: live tuning UI; `lab_telemetry.gd`: local event records and JSON download.
- `start_screen.gd` / `ui/`: themed menu, HUD, controls and overlays; only decorative background scrolling before Start. `assets/fonts/`: Fusion Pixel (OFL) for the UI; Noto Sans SC remains available.
- `tests/`: existing checks plus Lab B regression verification; automated exports belong in ignored `tmp/`, never `telemetry/`.
- `telemetry/`: actual tester JSON files, manually copied from downloads/local archives.
- Markdown documents remain at project root. Keep existing source layout rather than moving everything into the assignment's illustrative `src/` tree.
- `tools/package_lab_b.py`: creates an independent submission bundle under ignored `tmp/`, including a source ZIP with hidden `.git`; never invents telemetry or results.

## Working rules

Read AGENTS.md, GDD.md and PROTOTYPE.md before changes. Preserve this demo, engine, assets, core loop and existing work. Avoid unrelated refactors and extra levels, menus or effects. Do not remove existing mechanics to guess the student's prototype question.

The student chooses the question, hypothesis, A/B values, thresholds and verdict. Never invent Lab A / Rep 3 decisions, testers, results, timings, or prior work. Missing content is explicitly pending. Change one test variable per measured iteration; hold other parameters constant between variants. Every gameplay number tuned during Lab B must be on the panel. Commit small, explicit changes. Complete and commit the Prototype Card before the first outside playtest; a placeholder does not satisfy this requirement.

No AI-service requests or API keys in game code. Telemetry is local only. Do not upload tester data automatically. A new tester archives/exports the previous session before resetting; do not erase archives. Panel/menu pauses are excluded from gameplay duration; retry latency is real elapsed time. Administrative resets must not count as player retries.

## Confirmed experiment and start screen

User-authorized mission expansion (2026-10-31): START GAME opens a selector for Level 01 (existing four-stage campaign), Level 02 Signal Breach, Level 03 Iron Citadel and Endless. New missions use campaign_data.gd with four authored stages plus the existing Boss; game_data.gd Level 01 timings remain unchanged. Endless cycles denser authored waves, has a Boss every fifth wave, carries score/inventory between waves, and restarts from wave one on death. Mission records and endless records are separate. Developer/Boss-test entries remain Level 01 with their original telemetry rules. See LEVEL_MODES.md. This explicit request authorizes the additional missions/menu despite the older scope restriction.

Latest settings revision (2026-10-31): main-menu SETTINGS and Esc → SETTINGS provide saved Master/Music/SFX volume, mute, desktop fullscreen/VSync, tutorials, reduced flash and death-camera motion toggles, plus sound preview/reset. HUD audio controls and M mute are removed. Settings are local-only in user://settings.cfg; --lab-test bypasses persistence. Music and SFX route through separate native buses and a -1 dB Master peak limiter; audio_mix.gd stores measured per-file gain calibration. Settings do not modify experiment parameters or telemetry.

Latest aiming revision (2026-10-31): shoulder aiming uses the VisualRoot coordinate space and solves the actual muzzle-offset barrel line toward the reticle, without the previous arm-angle clamp. Both arm layers follow the solved rotation, including high-weapon recoil tilt and trimmed-frame muzzle correction. Death heading is MISSION FAILED.

Latest presentation revision (2026-10-31): tutorial hints stay horizontally centered below the track, on CanvasLayer 90. Campaign progress always has five squares: four cyan stage squares and a red Boss square. Death first plays the complete animation, then pans/zooms the world canvas to the fallen character (1.35× over 1.2 seconds, horizontally centered at 62% of screen height), holds the completed framing for 0.5 seconds, then displays death UI; retry/title restore the normal world transform. The start-menu panel is 640 pixels wide with 400-pixel main buttons and stripe. Reload fill eases toward actual progress with a slow 1.2-second opacity pulse. These rules supersede earlier tutorial-position and immediate-post-animation UI descriptions.

Latest flow revision (2026-10-31): grenades use an accumulating integer inventory, carry across natural stage transitions and restore the checkpoint-entry count on checkpoint retry; new campaign runs reset to zero. The centered tutorial uses its own CanvasLayer 90 above other UI. Death UI waits for the full eight-frame animation (duration derived from SpriteFrames); early retry input remains buffered and the completed death UI is rendered before a requested retry. Run scale is calibrated to 0.68 using the original idle shoulder-to-floor distance. These rules supersede the earlier capacity-one and immediate-death-overlay descriptions below.

Latest readability revision (2026-10-31): tutorial hints sit below the track in the lower-left, with larger text and translucent shadowed backing. Lower-right weapon slots are grouped, gun icons elongated and the current slot marked with amber fill/underline. Helmet artwork scale is 0.88 and front gun artwork is 1.12 on x, with the shoulder anchor and actual muzzle position kept consistent. Grenade pickups have an amber diamond decal/arrow behind them. Start menu keeps its framed background.

Player run artwork revision (2026-10-31): `assets/player/run_olive_4x4.png` is the user-supplied Downloads/深橄榄装甲4×4精灵表.png (1254×1254). Run uses all 16 cells in row-major order, 22 fps, directly on start; the idle-to-run startup sequence is removed. Integer atlas boundaries alternate 314/313 pixels. Run body scale is 0.68; row baselines align feet and shoulder attachments. A run-only palette shader brings the brighter olive armor toward the original body colors while preserving steel and cyan. Collisions and gameplay movement are unchanged. The start menu uses its original framed theme; gameplay HUD remains frameless.

Latest user revision (2026-10-31): Boss red health is now 24. F consumes one picked-up grenade, flashes the screen, clears visible normal enemies/hazards and all hostile rounds, and deals one direct Boss health damage without removing armor. Each active segment and Boss entry provide one pickup opportunity; capacity remains one. UI panels are frameless, checkpoint text is larger and the weapon HUD is wider at lower right. These changes supersede the earlier Lab C values below and never alter historical telemetry.

Current Lab C Boss revision (2026-10-30): red health is 12 (formerly 4); bombs, descending three-shot spread and three-wave upper-right barrage cycle in all play modes. The menu also has **Boss 战测试** for direct Boss entry and Boss-only retries/replays, with telemetry disabled. This user-authorized combat revision is separate from historical Lab B parameters/results below; do not rewrite old tester JSON.

Latest Lab C controls: hold A/D for backward/forward adjustment within ±90 px of default x=190; release returns smoothly to the default position, including in midair. Boss barrage has 8 normal-sized rounds per wave at 450 px/s. These settings are in game_data.gd; normal scroll speed and old telemetry remain unchanged.

User-authorized menu revision (2026-10-30, lab-b-0.5): the start screen has **开始游戏** and **开发模式**, without A/B or parameter selectors. Both start at A + Original. Ordinary play hides and disables lab UI, F1/F2/F3/T and telemetry recording/export. Development mode enables the existing panel, presets, variant switches and session tools. The 2026-10-31 UI revision changes Esc during play to Pause; Return to Title leaves the run. Death/victory Esc still returns to the menu. Ordinary play must not erase or add to retained developer sessions. Gameplay numbers remain the lab-b-0.4 baseline. Experimental controls described below apply only to development mode.

The student selected restart location as the A/B variable: A checkpoint (full Boss encounter on Boss death), B campaign entry on every death. F2/F3 and the existing panel select modes; preserve 1/2/3 weapons. All switches reset cleanly to campaign entry. Default is A + Original. The latest parameter choices are only Original / Slow / Fast Reload (plus Custom displayed after a manual panel edit). The earlier four presets are superseded.

Historical defaults are verified at commit 613233e. Student-authorized lab-b-0.4 changes only gravity from 1250 to 1250.0/1.1 (1136.363636...), preserving jump_speed=720 and other defaults. Panel gravity derives from game_data.gd and uses a 0.01 step; internal defaults retain full expression precision. Original now means this revised baseline. All three named modes share that gravity; Slow only changes scroll_multiplier 1.5→1.275, Fast Reload only changes reload_multiplier 1.0→0.8. Existing human JSON remains unchanged with historical gravity 1250: do not pool versions as identical settings. JSON experiment_preset remains a parameter_mode alias. No extra independent airtime mechanism was added.

Only Start creates a run while on the menu; gate held input/clicks before gameplay. Return records administrative_return_to_start and retains session/data. Preset and mode changes record administrative_parameter_change / administrative_variant_switch without fake failures/retries. The first retry event-dispatch time must be preserved during the animation lock; rapid rate uses failure_to_input_seconds. failure_to_restart_seconds separately measures when play is ready. Per-variant denominators are actual deaths, including abandoned deaths. Empty rates are null/N/A. See PROTOTYPE.md for score restoration and analysis definitions.

Parameter rounds use A; formal A/B uses Original with alternating tester orders. These are experiment preparations, not real iterations. Thresholds, tester records and results stay pending. Browser verification and the existing Duke deployment were completed by the student; this change prepares a new Web build/ZIP for the student to upload. Do not run the Duke upload script for this task.

Latest user-authorized progression revision (2026-10-31): normal missions/endless have physical gold drops, a persistent local wallet, cumulative run kills/shots, and one-time clear/endless-death bonuses. Main menu has a 21-node three-way build tree; top restores shield regeneration to 50/sec from the normal unupgraded 12.5/sec, lower-left auto-guards blockable lethal hits with energy and manual right-click priority, lower-right selects AP/rifle from the crosshair target armor during fire. Development/Boss test retain baseline stats and produce no currency. Heavy laser is 1400px including collision. See BUILD_TREE.md. These user-authorized gameplay additions do not alter historical Lab B data.
Latest follow-up (2026-10-31): credit coins use the generated transparent sprite and burst outward, fall and bounce before pickup, with unchanged drop value. Automatic weapon selection compares current armor requirements first and sustained DPS second, reevaluating after armor breaks and with no target. Profiles start with 600 G; existing wallets below 600 receive a one-time top-up, tracked by test_grant_600_v1. Boss enters from offscreen right before combat activation, including retries/endless waves.

Latest noncombat UI revision (2026-10-31): user prioritized noncombat UI. Menus/overlays use menu_style.gd locally; gameplay HUD retains its existing theme/layout. Main panel remains 640px, main buttons are now 440px, wallet is part of the build-tree entry. Mission rows contain descriptions; controls are Action/Keyboard/Controller; both Settings entry points share a 640px panel with explicit ON/OFF states and scroll guidance. Build-tree presentation derives from the data topology in its UI script without editing gameplay data. Death retains its framed MISSION FAILED area and prior animation/camera delay, with Retry focused; victory uses performance/reward columns and focuses Next Mission when available. See NONCOMBAT_UI.md. These latest UI rules supersede older button-width/presentation details only.

User rollback (2026-10-31): restore the build-tree presentation before the noncombat UI pass: data-authored node positions, branch-colored borders, previous node sizing and horizontal bottom details/actions. Keep the new UI for all other pages. Upgrade/currency data and persistence are unchanged.

Latest attract-mode/shield revision (2026-10-31): user explicitly authorizes a simulated battle behind the title/menu rather than decorative scrolling only. ui/menu_demo.gd uses an isolated visual player and turret sprites, scripted movement/jumps/fire/reloads/explosions and cosmetic rounds; no input, live-run actors, score, coins, saved records or telemetry are used. It advances while the menu pauses gameplay, and clears immediately on Start. Menu music requests the normal looping track from first entry; desktop plays immediately, browser audio may await its native interaction unlock. Ground spikes are now blockable: auto-guard can trigger at contact with energy, consumes the normal 7 energy and clears that spike group; manual guard still clears them. This supersedes previous exclusions of ground spikes from auto-guard; track impact and other explicitly unblockable hits retain their rules.

Latest live-demo revision (2026-10-31): user replaces the scripted/cosmetic attract animation with the real game. ui/menu_demo.gd now instantiates main.tscn in a separate SubViewport/World2D with attract_mode and AI-only inputs. It uses real timelines, enemies, collision, armor, damage, Boss, death/retry and mission progression; no cosmetic combat simulation, invulnerability or accelerated timelines. Main ready avoids recursive menu demos, uses an in-memory profile, the parent's settings object, silent background audio and no leaderboard persistence/telemetry. Ordinary controls and gameplay remain unchanged. See MENU_DEMO.md. This supersedes the earlier visual-only demo description.

Latest coin/title revision (2026-10-31): coins home to the player by default at 720px/s after landing/bouncing, without a range upgrade; homing ignores world scroll/gravity and follows airborne players. Old magnet/sensor_two IDs now grant +3/+2 shield energy per kill respectively (sensor_two retains +16 pickup reach), with unchanged prices/prerequisites and owned-save compatibility. Main title panel moves +60px right, -48px up; other menu subpages stay centered.

Latest title placement (2026-10-31): title panel is anchored visually to the upper-right with 24px top/right margins on the logical canvas, superseding the earlier relative offset. Full-sized subpages remain centered.

Latest player-mode revision (2026-10-31): main Development entry preserves the existing wallet/upgrades and opens all missions, separate from LAB tuning. Guest visits start at 0G/no upgrades/mission one; continue within the visit retains progress, New Guest or re-entry after leaving clears it. Named entry loads/creates a local per-name profile, starts new names at 0G and saves wallet/upgrades/unlocks/records separately. Guest/named unlock 01 -> 02 -> 03 -> Endless through Boss clears, enforced in UI and start API. Names are normalized/case-insensitive hashed IDs; no online service. Historical lab/telemetry and the 600G development profile remain separate. See PLAYER_MODES.md.

Latest navigation revision (2026-10-31): title page only selects Guest/Development/name save plus settings/controls; no build-tree entry or wallet there. After selecting a profile, the mission selector has a prominent full-width amber Build Upgrade button with that profile's wallet and available-upgrade count. Build-tree Back/Esc returns to that selector, preserving the selected profile.

Latest developer-entry placement (2026-10-31): the normal Development profile entry is grouped at bottom-right with LAB tuning and Boss test, removed from the main mode/load panel.

Latest armor/shield balance (2026-10-31): normal combat/Boss test now use 18 armor points per Boss layer, 36 total, separate cyan HUD bar; AP penetration3 removes3 per shot, six hits per layer. Rifle does no armor damage; red health stays24 and grenade behavior remains. Shield sustained drain is1.5x, hit cost18, recharge delay+0.5s and regen/regen-upgrade effects0.5x (base6.25/s, capstone25/s). Zero energy immediately ends guard and starts break lock. Historical LAB keeps original shield values and armor_per_layer3, old telemetry unchanged. See COMBAT_BALANCE.md and combat_balance.gd.

Latest Boss appearance revision (2026-10-31): Boss armor appearance now follows remaining armor: above75% intact outer idle, at75% outer crack frame, at50% outer detach transition then inner form, at25% inner crack frame, at0% inner detach transition then weak point. Reuses atlas columns6/7 for cracks/detachment, preserves attack animations and combat values.

Latest smart-weapon capstone revision (2026-10-31): auto_weapon now also reloads an empty selected gun automatically after its last-shot cadence, using normal reload duration. Armor/DPS target selection is unchanged; grenade selection is not interrupted. Node ID/cost/prerequisites and existing purchases remain valid; historical LAB does not apply the capstone.

Latest UI audio revision (2026-10-31): both new Downloads sounds are for buttons, not coins. UIAudio uses ui_click.wav (first isolated 0.10–0.62s excerpt of buttonpress_needrevise.wav) for valid presses and ui_error.wav (error_01 source) for disabled/rejected actions; central BaseButton binding avoids duplicates, hover remains silent, SFX/Master settings apply while paused. Coin sound is pending a separate user asset. See UI_SFX.md.

Latest coin audio revision (2026-10-31): actual coin pickup now plays assets/sfx/coin_pickup.wav from the user's coin_misc_05 file when credit succeeds. SFX-controlled, 80ms minimum gap prevents stacked pickup bursts, attract demo remains silent; button sounds remain separate.

Latest button-click revision (2026-10-31): replace normal click with the user's iphone_button_wake_up source, trimming its leading silence (0.414–0.860s excerpt). UIAudio now plays on button_down, not release, with no normal-click throttling or rejection cooldown suppressing new valid presses. Button actions themselves retain their original activation semantics.

Latest title artwork revision (2026-10-31): title-only panel is now the user's sci-fi monitor frame with image_gen-removed transparent exterior (assets/ui_title_terminal.png), NinePatch display at704px outer width, top/right24px margins, 528px screen content and height adapting to Guest/name-error rows. Original buttons/profile flow and real background game are retained; selector/build/settings keep their prior panels. See TITLE_TERMINAL.md for source and edit prompt.

Latest title correction (2026-10-31): use the standing terminal artwork for the title at upper-right; flat screen frame supplies backgrounds for subsequent selector/build/settings/controls pages. User explicitly requests file changes only, leaving all testing to them; do not run games, automated checks or capture scripts unless asked.

Latest terminal placement (2026-10-31): title monitor retains its existing upper-right origin and width; pedestal extends from the monitor's lower edge to the viewport bottom without a bottom gap. The pedestal atlas omits transparent rows beneath the actual feet. User handles testing; no runtime/capture checks for this change.

Latest title offset (2026-10-31): move the title terminal another24px right and120px up: artwork origin is now (viewport_width-640,-96), positioning the actual display/controls in the upper-right rather than reserving top margin for the antenna. Pedestal still reaches the viewport bottom. File-only change, no tests.

Latest pedestal revision (2026-10-31): replace the vertically stretched support with regenerated ui_title_terminal_pedestal_v2.png. Render with one uniform scale using its native aspect ratio, align feet to viewport bottom/right and occlude surplus upper mounts behind the unchanged monitor. No runtime tests/captures, per user.

Latest title simplification (2026-10-31): user removes the stand entirely; title renders the monitor/head only at its existing upper-right placement. Pedestal drawing/loading/layout removed; asset files retained unused. No runtime testing.

Latest enemy addition (2026-10-31): user-supplied kamikaze drone design sheet converted with image_gen to transparent assets/enemies/kamikaze_drone_8x6.png. kamikaze_drone.gd implements idle/fly/detect/charge/hurt/explode, 0.42s warning, locked-direction500px/s charge,48px blast,2HP (AP one-shot),150score/4G for player kills. Integrated shots/shield/grenade/coins/cleanup/smart weapon/menu bot; normal campaigns/endless gain one event per stage, historical LAB timeline remains unchanged. User performs tests; no runtime checks run. See KAMIKAZE_DRONE.md.

Latest kamikaze flight revision (2026-10-31): raise spawn y to300/340, orbit in the upper area for1.4s (48x28px ellipse), then use the existing0.42s detect warning and lock a downward dive. Charge artwork rotates with its trajectory. Other damage/reward values unchanged. File-only edit, user tests.

Latest kamikaze readability/motion revision (2026-10-31): visual cell112px (was84), body hitbox54x44, spawn y220/250, orbit104x64 for2.6s. Continuous smoothed velocity follows ellipse tangent/correction, decelerates for warning and accelerates into dive; sprite rotation/socket offset ease between poses. No runtime tests per user.

Latest encounter scope/pressure revision (2026-10-31): kamikaze drones only appear in Level02/03 and Endless; Level01 returns the original GD event list with no injected drone, and historical LAB remains unchanged. Level02/03 and Endless duplicate every enemy/hazard event (including kamikaze) with spaced reinforcements, yielding at least double combat-event count within unchanged authored duration. Grenade opportunities, scroll speed and Boss stats are unchanged. No runtime tests per user.

Latest Endless difficulty revision (2026-10-31): add Easy/Normal/Hard selector on mission page. Current intensified Endless is Normal unchanged (2 combat-event copies); Easy uses1 copy, Hard3, while grenade pickups, wave spacing progression and every-fifth-wave Boss cadence/stats remain. HUD shows difficulty; best score/wave records are separated, Normal retains existing keys. Unlocking Endless opens all three. File-only edit, no tests.

Latest Hard multiplier (2026-10-31): Endless Hard now uses6 combat-event copies versus Normal2, i.e.3x Normal spawn count; supersedes previous1.5x setting. Easy/Normal and other values unchanged. No tests.


Latest encounter authoring revision (2026-10-31): Level02/03 now use independently authored phase rosters, replacing generic duplicated-event pressure. Level02 emphasizes light turrets/kamikazes/laser gates; Level03 emphasizes heavy armor and combined arms. Level01 and historical LAB remain original. Endless retains campaign phases: one phase per wave, Level02 phases on waves1–4, Boss5, Level03 phases6–9, Boss10, then repeat with existing spacing progression. Easy approximately halves each event type, Normal uses authored roster, Hard triples Normal combat events; grenades/Boss stats unchanged. Supersedes earlier copy-count descriptions. User tests; do not run game/import/tests/captures.


Latest independent Endless revision (2026-10-31): user rejects all campaign-derived Endless templates. endless_data.gd now generates independent random wave rosters from dedicated weighted profiles (mixed/air/armor/fireline), randomized ratios/order/timing and22–32 Normal combat-event budgets. Easy approximately half, Hard3x; one grenade, every-fifth-wave Boss and capped wave pacing retained. campaign_data.gd delegates Endless generation without referencing any campaign stage. Supersedes phase-to-wave mapping only; all campaigns unchanged. No game/import/tests/captures per user.


Latest pressure-budget revision (2026-10-31): user adds active threat cap to Level02/03 AND Endless. threat_budget.gd defines cap100, light/unarmored25, heavy50, kamikaze35, gate40, spikes25 and0.6s minimum release gap. main.gd reserves incoming actors, delays over-budget events without dropping them and waits for event dispatch before transition; harmless dead actors release points, damaging drone explosions retain reservation. Hard total3x retained; same cap. Level01/LAB/Boss unchanged. File edits only; user tests.


Latest Endless roguelite revision (2026-10-31): every Endless wave clear (Boss included) opens run-only three-choice talents via endless_talents.gd and ui/endless_reward.gd, freezes gameplay until selected, then advances with input-release gate. Bonuses combine with meta stats with bounded reload/cadence/drain reductions; ranks5 except repeatable supplies/projectile. No persistence; retry/new run/title clears talents. Endless difficulties now share22–32 total combat-event budgets; Easy/Normal/Hard cap50/100/150 with spawn gaps0.9/0.6/0.4 and duration factors1.25/1/0.75. Supersedes previous half/triple total counts and universal100 Endless cap. Level02/03 remain100 and Boss cadence/stats unchanged. Only edit files, no tests/import/game/captures.


Latest Endless entry UI (2026-10-31): mission page replaces Endless-plus-difficulty-toggle flow with three direct-start buttons: 简单无尽 / 普通无尽 / 困难无尽, showing50/100/150 caps. Common Endless unlock requirement preserved; campaigns and gameplay unchanged. File-only, user tests.


Latest UI simplification (2026-10-31): Endless selector contains only ENDLESS plus 简单无尽 / 普通无尽 / 困难无尽; remove visible50/100/150 and rules copy. Hide HUD upper-center banner/toast messages during combat, retaining progress/Boss HUD/tutorial. No gameplay changes or runtime tests.


Latest smart weapon/manual priority and Endless synergies (2026-10-31): manual AP selection locks smart switching until manual rifle selection; auto-selected AP does not lock. Q/wheel follow same rule, grenade preserves lock, auto reload remains. Natural transitions preserve lock; new run/title clears it. Endless adds2-round split (rank2), every-third-trigger extra pair(rank2), AP>=3(rank1), shield+4(rank3), block cost-3(rank3, floor6), completed reload shield+10(rank3), every8 run kills grenade+1(rank1). Existing fire rate/magazine/shield talents retained. Trigger count once per actual firing action, extra projectiles never recurse; shot stats count emitted rounds. User tests; no runtime checks.


Latest Endless reward presentation (2026-10-31): user replaces paused black overlay with empty moving track plus three square hanging monitors. main talent/talent_exit states update player motion and parallax only; clear enemies/rounds at wave clear, no next wave until selection/retraction. ui/endless_reward.gd uses existing flat terminal NinePatch art with scaled borders, generated transparent assets/items/endless_upgrade_chip.png, staggered descent/retraction; no blackout. Mouse/key/gamepad card selection and Esc title remain; input gate on next wave. Supersedes frozen reward UI descriptions. No game/import/tests/captures.


Latest Endless count/card tuning (2026-10-31): Easy/Normal/Hard total starts18/22/28 and grows+2 per five waves to+10; caps50/100/150/pacing retained. Split/third_fan each+1 round/rank, repeatable uncapped; alternating spread preserves center aim. Reward UI removes yellow focus rectangle, highlights monitor brightness; existing pedestal_v2 leg atlas at native aspect rotated as overhead mount replaces plain rods. Fonts22 title/18 description/15 rank. User tests; file edits only.


Latest Endless homing/piercing revision (2026-10-31): user changes homing to single-rank complete tracking, no graded steering. main rounds snapshot homing/pierce rank, steer toward actual valid hurtbox/emitter center and switch when target gone/hit, preserve speed and avoid overshoot orbit. Piercing ranks1–4 allow that many extra unique actors, independent of armor penetration, deduplicate per-round hits and support same-frame multiple hits. All extra projectiles inherit effects. No permanent tree changes, no tests/import/game/captures.


Latest homing nerf/copy (2026-10-31): homing now max4 ranks; every5/4/3/2 actual emitted rounds grants one fully guided round. Count multishot rounds individually, never entire volley at once; reset counter with run/title. Reward text directly states effects, removes explanation/cap/repeat prose; homing card shows next-rank interval. File-only, no tests.
