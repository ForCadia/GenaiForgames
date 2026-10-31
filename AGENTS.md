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
