# Project instructions

Language revision2026-11-01: Settings now provides 中文 / English, defaults to zh_CN and persists the language code in the existing settings.cfg. Runtime Translation resources accept both legacy English and Chinese source strings. Native control retranslation and deferred refresh preserve active menus, pause, profile, input name and currency; dynamic UI formats translate before interpolation. Catalog covers player menus, settings, mission selection, HUD/tutorials, results, build tree and Endless talents. Proper title branding and baked warning artwork remain assets. No gameplay numbers, telemetry or profile IDs changed. Language integration and existing settings smoke checks are the relevant checks; this source change does not automatically redeploy or replace the prior submission ZIP.

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


Latest procedural cape revision (2026-10-31): user authorizes first visual-only broad ribbon cape. player_visual.gd instantiates player_cape.gd,12-link fixed-step global Verlet mesh using generated transparent pixel red/ivory atlas, bone-white edge, wind/gravity/motion inertia, behind-body/ground constraints and pixel-snapped vertices. Separate scarf_red_pixel.png is pure red, positioned below neck and inserted before Helmet sibling (body < scarf < helmet < front arm), never weapon rotation. Cape z=-3; death settles cloth and hides separate scarf to preserve baked death head. Source Downloads unchanged. No gameplay/collider changes, no tests/import/game/captures. See PLAYER_CAPE.md.


Latest cape stiffness/layer revision (2026-10-31): user removes scarf and ivory backing; render red only. Cape z1 in front of body0, original back-arm/helmet/front-arm ordering at z2, guard3. Shape-rest springs, damping, reduced live gravity/flutter and two-link bend constraints make it thick/stiffer while leaving tail/death motion. Follow animated shoulder with visual ellipse exclusion for centerline and mesh edges; pin root attachment, no gameplay collider changes. Assets retained unused. No tests/import/game/captures.


Latest cape jump correction (2026-10-31): fix airborne-foot floor clipping by using true GD.GROUND_Y world floor for simulation/vertices. Carry all current/previous points with shoulder displacement and apply capped acceleration inertia, maintain rearward spacing/stable width normals, explicit triangles prevent invalid folded-quad triangulation. No changes to cloth size per jump or gameplay. User tests, no runtime checks.


Latest cape flutter tuning (2026-10-31): reduce constant backward wind, add prominent traveling angular waves/tail flutter, reduce damping and soften tail bending while keeping root braced. Preserve shoulder avoidance, triangle topology/world-floor fix, layers and red-only presentation. File-only, user tests.


Latest cape vertical inertia (2026-10-31): replace full-body translation with progressively lagging carry, distinguish actor body movement from animated shoulder socket. Filter body velocity; rise pulls tail down and fall lifts it via rest-angle/relative airflow, airborne decorative waves35%. Keep fixed root, dimensions, shoulder avoidance/world-floor/triangles. File edits only, user tests.


Latest cape run tuning (2026-10-31): calm run pose only—wave22%, flutter20%, damping retention0.93. Keep jump/fall inertia and airborne tuning unchanged. File-only, user tests.


Latest underarm ribbons (2026-10-31): user restores two narrow pure-red cloth strips with shared player_cape.gd simulation and separate atlas halves (assets/player/red_ribbons_pair.png, imagegen reference extraction). Front42px/rear36px lengths, narrower widths, underarm attachments and different phases; rear z-1 < body0 < front/main cape1 < arms/helmet2. No neck scarf/ivory restored. Inherit jump inertia, run damping/floor/shoulder constraints; no gameplay changes. File-only, user tests.


Latest user rollback (2026-10-31): remove both underarm ribbons from player_visual.gd; retain main red cape unchanged. Ribbon asset/configuration remain unused. No tests.


Latest aerial ranged enemy (2026-10-31): user authorizes aerial_rifleman.gd from Downloads/空中射击兵像素动画设定表.png, imagegen transparent assets/enemies/aerial_rifleman_8x6.png. Level03 and Endless only, enforced spawn API;3HP rifle1/AP2,40 threat,180score/4G,0.6s aim then3 orange320px/s shots at0.18s intervals, boost/reposition, exit after two bursts. Level03 replaces7 kamikaze events without increasing total; independent Endless profiles add10–22% nominal aerial share. Integrates shots/homing/piercing/grenade/shield/coins/cleanup/smart aim/demo AI. Level01/02/LAB/Boss unchanged. No tests/import/game/captures. See AERIAL_RIFLEMAN.md.


Latest aerial rifleman motion/death/fire revision (2026-10-31): smooth kamikaze-style104x64 orbit, no self-destruction; visual128/hitbox48x80. Fixed left-down45° bullets480px/s, muzzle/visual aim lean aligned. Death first3 frames during fall, fourth onward and explosion sound only after world-ground contact, cleanup after final landing frame. Two bursts then exit, HP/threat/rewards/scope unchanged. No tests/import/game/captures.


Latest aerial shot polish (2026-10-31): only aerial bullets radius4/glow4; speed480/left-down45 unchanged. Flight tilt±2 degrees, eased26-degree attack lean, subtle bob. Calibrate each shoot frame muzzle from forward flash pixels, mirror and sprite.to_global transform; emit after movement/pose update. Others projectile sizes unchanged. No tests.


Latest aerial predictive aiming (2026-10-31): replace fixed45° with burst-locked player aim using filtered motion, travel-time prediction capped0.65s ×random0.45–0.8 plus±32x/±22y target error. All3 rounds retain direction; restrained target-directed visual bank and calibrated muzzle retained, speed480/radius4 unchanged. No tests.


Latest aerial corpse revision (2026-10-31): dead rifleman falls, then landing frames4–7 hold prone body, scroll left with track and disappear only once complete transformed sprite bounds exit left. Remove death timer despawn. Absolute z=-9 above track-10 below live actors; no collisions/rewards repeated. No tests.


Latest Endless Boss-clear flow (2026-10-31): keep1s Boss death display but update player motion/animation, track parallax and coins during intermission, clearing residual bullets. Removes deliberate frozen-world second before reward selection; no combat/timeline advance. Read-only log inspection, no tests/game/import/captures.


Latest Gunblade Mecha Boss (2026-10-31): user-authorized24HP independent MechaBoss.tscn/mecha_boss.gd, selectable inside existing DEV/BOSS entry alongside eye; retries keep choice, campaign/Endless remain eye. No consumable armor/stages/bar: core threshold references existinglight1, body existingAP-onlyheavy3 (user confirmed); shared health,1 damage, no core multiplier, segment core-priority and one actor-ID hit per bullet. Grenade existing1HP/clear. Six Downloads/boss sheets copied unchanged with real alpha; honor source filename frame orders (ground only1234; slash12345689-11-10-9-12-13-14-15-1; stab1345(active)671; lift excludes1/8, slash1 idle). Four attacks with separate prep/active/recovery, movement by code, facing left always/no jets, once-per-attack blockable sword contact/no body wall. Timings/speeds/heights in mecha_boss_data.gd; exportable frame metadata in mecha_boss_frames.gd. No runtime tests/import/game/captures. See MECHA_BOSS.md.


Latest retro asset replacement (2026-10-31): Downloads/复古像素射击游戏素材表.png (one file found) alpha-extracted via imagegen into assets/retro_shooter/sheet.png. World coins9-frame10fps atlas animation; HUD/menu/build coin icons use coin_icon.tres. retro_shooter_assets.gd supplies rifle-slug orange player/hostile rounds and red generic energy bolts. Preserve blue AP/cyan proc/heavy beams/dedicated Boss attacks, all mechanics and audio. Other board effects unused. No tests/import/game/captures; see RETRO_SHOOTER_ASSETS.md.


Latest mecha frame/timing/aim correction (2026-10-31): replace uniform atlas grid with actual transparent-gutter rectangles and per-frame clipped AtlasTextures/inset+coordinate margins. Source frame ordering unchanged. Accelerate action/recovery/death timing, raise charge/stab speeds to preserve distance. User overrides fixed-height air stab: lock player's end-of-prep position and lunge toward it, rotate around chest and use swept blade-axis segment hits, never mid-lunge tracking. Preserve0.9s stab prep and one shield contact per attack. No runtime tests/import/game/captures.


Mecha atlas repack (2026-10-31): all six action sheets now use transparent `_spaced.png` assets, with full blade clearance and individually measured frame regions. Original sheets and user-authored frame selection/order are retained. All 56 source regions have an empty two-pixel outer border in the asset inspection. Per-sheet body scale, source-space hit masks, core anchors and per-frame muzzle coordinates are recalibrated for the new source sizes; death anchors use the neutral body center. Attack timing and gameplay rules are unchanged. No Godot run, import, export or runtime tests were performed, per user instruction.


Mecha entrance/effects revision (2026-10-31): user now authorizes backpack propulsion, superseding the original no-jet-flame request for this Boss. Mecha enters by descending from above the screen, plays landing poses and a brief safe recovery before its existing attack loop. Procedural pixel-style orange friction sparks travel left while grounded; cyan backpack exhaust follows the transformed sprite during airborne states, with a spark burst on touchdown. Cosmetic effects have no hitboxes or damage and clear on reset/death/disabled combat. Values are centralized in mecha_boss_data.gd. Changes were inspected as source only; no engine run or tests, per user request.


Mecha melee readability revision (2026-10-31): larger backpack exhaust and leftward ground sparks. Ground slash and aerial thrust display red swept-area telegraphs before execution; thrust direction locks at preparation start so the warning gives a usable dodge window. Windup poses play in the final 0.20 seconds of the unchanged preparation window; charge holds slash source frame 9, and execution/recovery/fire/lift/landing animations are faster. Cosmetic oversized red crescent uses the user Downloads neon effects atlas, retained unchanged as assets/vfx/neon_effects_source.png; shader removes its black background at render time. Damage still uses existing swept blade shapes and one contact per attack. No game, import or tests were run.


Mecha presentation update: normalize alive action-sheet scale using helmet-to-core span against ground idle, instead of total leg-dependent body height, correcting smaller aerial fire/thrust appearance. Ground melee cosmetic is now a thin red line across its swept path, expanding rapidly and contracting back to thin; the crescent is removed from ground melee. Slash preparation adds a red/white cross attached to per-pose sword-hand source anchors. Aerial straight thrust trail, HP/armor/damage and timings remain unchanged. Source changes only; no runtime verification per user instruction.


Backpack/scale follow-up: replace chest-relative exhaust offset with eight per-frame, full-sheet backpack outlet landmarks for lift, aerial fire and thrust. Convert through each frame region and actual sprite transform; exhaust points outwards right/down and only emits for sheets with known backpack anchors. No exhaust is guessed for ground slash poses. Narrow nozzle to18px, retain85px flame length. Per-sheet fixed helmet-width calibration (46 world pixels) now supersedes helmet-to-core normalization, avoiding torso/leg pose-dependent scale changes. Death uses matching helmet calibration too. Values/landmarks are centralized in mecha_boss_data.gd. Source/image inspection only; no game or tests.


Mecha core collision correction: replace the tiny core circle with a66x48 chest box, offset(-30,-23) from the red core in unrotated world-size units and transformed with the current sprite. Core is checked first; overlapping front arm/gun body pixels at that chest-height approach lane no longer consume incoming bullets on an earlier physics tick. Body armor remains outside the chest lane. Both smart targeting and shot damage use the same core predicate; shared HP, penetration thresholds and one hit per projectile remain unchanged. Source-only inspection, no game/tests.


Latest user armor rule: mecha chest and body both require the existing heavy-armor penetration threshold3; rifle/penetration1 ricochets everywhere. This explicitly supersedes the original light-armor core exception. Core keeps its chest-sized hitbox, but the previous front-arm approach lane is removed now that core/body requirements match. Shared HP, no armor depletion/bar, grenade direct damage and one hit per projectile remain unchanged. Smart targeting reads the same threshold. No runtime tests.


Mecha mission integration (2026-10-31): campaign Level03 now ends with the gunblade mecha; Levels01/02 retain the eye. Endless Boss encounters remain every fifth wave, alternating mecha at5/15/25 and eye at10/20/30. Explicit Boss-test selection still overrides mission selection; historical LAB remains on eye. Mecha current cadence is normal: Endless easy multiplies preparation/recovery waits by1.5, hard by0.75, normal1.0. Fixed combat animation/damage/HP/projectile and movement speeds stay unchanged. Campaign03 and Boss test always use normal, independent of last selected Endless difficulty. Telegraph cross progress follows the adjusted windup. Existing retry, shared kill/reward, grenade and Boss HUD paths dispatch to selected Boss. Source inspection only, no engine/tests per user.


Latest heavy pressure cost: heavy turret now reserves75 points (formerly50), independent of kill score. Applies wherever shared threat budget is enabled. An event costing more than the configured cap may spawn alone on an empty field, preventing easy Endless cap50 from permanently blocking its75-point heavy event; no additional combat event fits until that reservation releases. Other limits/costs/rewards unchanged. Source edits only, no runtime tests.


Level03 roster rebalance: heavy turrets reduced to4/4/4/5 across four authored stages (17 total); removed heavy slots replaced with light turrets, aerial riflemen and occasional kamikazes at the same authored times. Remaining heavies are spaced through each stage; no adjacent heavy-heavy beats. Event counts, durations, scroll,75-point heavy cost and mecha Boss unchanged. Level01/02 and independent Endless rosters untouched. Source-only edit, no engine/tests.


Endless Boss growth: tier=floor((wave-1)/5). Both Bosses gain25% of base HP per tier, uncapped, and multiply attack downtime by0.9^tier with a0.5 floor; selected easy/normal/hard downtime modifier stacks. Wave05 base24HP,10=30,15=36,20=42. Eye scales idle/recovery but preserves telegraph/barrage timings. Mecha preserves at least0.5s for its longer preparation windows and0.12s shorter waits. HP bars use encounter maximum, not base24. Damage, armor, bullet/charge speeds unchanged; campaign, Boss test and historical LAB use baseline growth. Source-only inspection, no runtime tests.


Boss opening presentation: new boss_intro state keeps the player running on an empty track while a built-in-imagegen pixel warning banner slides in (1.5s), Boss enters (until2.8s), camera focuses at1.5x (0.8s), holds0.8s with Boss name, and returns0.7s before combat. Total5.1s. Both eye and mecha supported, including Boss tests/retries/Endless; historical LAB skips intro. No combat inputs, damage, ammo/resource use or run-duration during the intro; current airborne player lands naturally. Pause/Esc supported, world clear cancels/restores camera; camera motion follows existing motion toggle, warning pulse follows reduced-flash option. mecha entrance completes without starting attacks, then combat begins after camera restoration. Asset/prompt retained in assets/vfx/boss_warning_banner.*. Source inspection only; no game/import/tests.


IRON BASTION prototype user-authorized2026-11-01: independent modular tracked fortress in Boss test selector only, retaining Eye/Gunblade and current campaign/endless assignments. Cover sits over red hull core. Cannon8HP/launcher8HP/cover6HP use AP3; exposed core24HP uses light1. Destroying cover exposes core regardless of weapon survival; destroyed weapons stop firing and leave harmless wrecks. Cannon uses authored up-left35-degree ballistic shots; launcher fires six spaced locked-lane missiles. Grenade clears internal rounds and deals existing1 direct Boss HP. Source hull and launcher preserved, imagegen cutout/removal variants used; no new runtime service. Shared mechanical actor accessor routes intro, shots, guard, HP sparks/death/retry to selected Boss; existing public is_mecha_boss retains its specific meaning. No game/import/export/tests per user. See IRON_BOSS.md.


Boss audio follow-up2026-11-01: new user Downloads sword_fire01, fire-3-rpg and cannon-shot are converted into boss_melee_sword.wav, iron_missile_fire.wav and iron_cannon_fire.wav. Gunblade slash/thrust emit the sword cue once on execution-state entry, never during warning or every frame. Iron cannon uses the first cannon report only (source0.12..5.1s; second report excluded), launcher one RPG cue per pair of missiles. Leading silence trimmed, PCM conversion preattenuated8dB to avoid clipping, active-segment RMS measured offline and calibrated through audio_mix.gd; missile target gets3dB extra overlap headroom. Existing SFX bus/settings/limiter/pause/title cleanup remain. Source manifest assets/sfx/boss_new_audio.source.json records files, trim and gains. No game/import/tests or runtime audition.


Iron layout correction from user annotated hull: hull scale0.45 (formerly0.25), home x670, roof mortar mount(-40,-390) behind hull at z-1, central-wall launcher mount(8,-286) at z1, core cover mount(-127,-157) at z2. Uniform cover scale0.37 replaces unequal0.20/0.30 stretch; full red core column is covered. Core/cover/hull collision boxes recalibrated to the enlarged art, and sprite-space muzzle anchors follow the new transforms automatically. Approximate body spans x370..969, highest cannon y98, track y632 on960x720 canvas. Faster entrance fits the intro window; Iron focus uses whole-fortress center and1.05zoom to avoid cropping the enlarged assembly. No runtime tests.


Iron correction2026-11-01: user clarifies do NOT shrink mortar; keep scale0.36 and shift mount right to(25,-390). Main cannon uses individual source regions/anchors, including firing frame x700..1536 to retain leftward flash beyond the nominal grid; muzzle uses matching frame source coordinates. Former rocket module now deploys1 aerial rifleman and1 kamikaze per cycle,0.55s apart, capped at3 live air supports. Destroying its8HP module stops deployment; existing air enemy physics, hit/guard/kill/grenade behavior reused. Spawn API supports optional explicit origin, normal campaign spawn defaults unchanged. Rifleman can orbit forward of the bay with per-instance anchor; Boss death removes summoned actors and their rounds. Mortar shell and explosion now use user neon-effects atlas sprites instead of placeholder circles, black background keyed only on Iron own draw material. Existing source art and HP unchanged. No game/import/tests.


Iron simplification2026-11-01: shift home x670->790 so rear hull intentionally extends offscreen. Remove visible rocket/hangar and front core-cover sprites and their hit regions; retained source files are unused/hidden, core exposed immediately. Air deployment remains independent of a destructible hangar; same cap/roster. HUD now shows cannon HP and exposed core, no phantom cover/hangar HP. Replace broad hull rectangle with source-alpha collision; front core lane remains unobstructed. Summoned flyers draw at z6 in front of Boss z4; before shot resolution collect active flyer body boxes and yield Boss collision for forward aim rays intersecting these foreground enemies, preventing hull from consuming their rounds. Normal campaign targets unaffected. No engine/tests.


Iron reverse/pixel atlas update2026-11-01: user adds Downloads reversing hull8-frame sheet; original saved as reverse_source.png. Built-in imagegen repacks hull8 and cannon4 into isolated transparent pixel atlases; all12 measured source regions have zero opaque pixels along2px border. Hull loops10fps with fixed per-frame track baseline/chassis anchor; cannon ready/fire/smoke/recover uses matching fixed base anchors. Scale recalibration retains approx600px hull width and prior cannon footprint rather than shrinking when source images shrink. Sprite-local pixel shader gives consistent ~2.25world-pixel grain and nearest sampling, no color grading/hue/brightness changes; warm bone-white/charcoal/red palette retained. Source metadata/core anchor and firing muzzle recalibrated; source-alpha collision follows current atlas frame, preserving foreground flyer priority. Death cannon retains original atlas with matching pixel sampling. No game/import/export/tests. See assets/boss_iron/animation_repack.source.md.


Latest user artwork replacement2026-11-01: use supplied four-frame pixel mortar-v2 and four-frame fortress reverse atlases directly, copied unchanged as cannon_pixel_user_v2.png/reverse_pixel_user_4.png. Both loop/frame counts now derive from loaded arrays (hull4, cannon4). Cannon source rows split at actual transparent gutter y532 rather than512, preventing base bleed; all8 source frame borders have0 opaque pixels. Recomputed frame base/core anchors and muzzle positions. Hull retains600px approximate width; mortar base footprint grows from about168px to235px (about40% larger), mount lowered into rear roof to keep muzzle flash onscreen, still behind hull. Wreck scale follows enlarged live cannon. User hues/brightness retained; no imagegen transformation of these supplied replacements. No runtime tests.


Iron motion/layer follow-up2026-11-01: lower the assembled Boss18px via root ground offset (player track/ballistic landing ground remain unchanged). Shared four-frame chassis bounce0/-2/+1/-1px and measured roof-height deltas drive cannon mounting every hull tick, including idle/intro and wreck; barrel firing animation remains separate. Remove the arbitrary prepare-circle drawn over the cannon. Shell/explosion atlas rendering moves to a dedicated world Node2D at rear-cannon layer z-1, drawn above cannon but behind hull, so effects no longer paint through front armor. Actual muzzle, core/hull contact and intro focus follow assembly transforms; no HP/timing or palette changes. No game/import/tests.


Iron destruction simplification2026-11-01: stop using cannon/hangar destruction flipbooks. Destroyed cannon hides and triggers3 staggered cosmetic atlas bursts; Boss death freezes hull, triggers7 distributed bursts, then hides hull after1.1s. Existing neon atlas effects rendered in a separate world layer over hull, with no damage or UI overlay. Reset clears bursts and restores sprites. Mortar projectile grows32x24->56x42 and collision radius9->16, keeping trajectory and ground explosion radius unchanged. Source destruction PNGs retained but not preloaded/played. No engine/tests.


Iron HP/fragmentation revision2026-11-01: user asks+1x health, interpreted as double: exposed core24->48, cannon8->16. Mortar shell detonation (ground or direct/shield contact) emits8 discrete shrapnel rounds into the upward hemisphere,300px/s, gravity180, radius5, lifetime1.6s. One fragment generation per parent shell, no chain fragmentation; pending fragments join on next update to avoid mutating collision iteration. Every fragment uses swept guard/player hit and consumes contact once; grenade/reset/death clear both live/pending rounds. Atlas red slugs represent fragments, separate from large mortar orb. Landing marker and blast radius unchanged; no engine/tests.


Latest Iron shared HP rule2026-11-01: core and mortar hits both reduce the same48HP Boss pool. Cannon no longer takes separate module HP damage, hides or explodes independently; remains active until whole Boss defeat. Its internal availability sentinel remains positive until full death, and HUD removes the separate cannon count. Core threshold1 and cannon threshold3 remain; solid inert hull ricochet remains. Entire Boss still uses7 cosmetic death bursts; fragmentation shells retained. This supersedes earlier16HP destructible cannon. No engine/tests.


Latest Boss roster2026-11-01: reduce mortar fragments8->4 (upward angles-155/-115/-65/-25deg). Campaign01 eye,02 IRON BASTION,03 gunblade; Endless rotates eye at5,Iron at10,gunblade at15 then repeats every15waves. Explicit Boss tests still override; historical LAB unchanged. Iron uses shared48HP baseline and existing Endless five-wave HP/aggression growth plus selected difficulty; campaign02 remains normal baseline. Active-kind dispatch now recognizes Iron beyond test mode, including foreground flyers, summons, HUD, intro, grenade/death/reset and targeting. Boss hit message denominator uses actual encounter maximum. No engine/tests.


Lab C delivery preparation2026-11-01: supplied Final(1)DOCX read. Added style guide, source-aware asset log, retrospective18stage log, visually reviewed two-page report, sound list and151word no-voice rationale. Unknown user tiers/cost/time and browser acceptance not invented. Settings gains cosmetic hit/pickup/failure particle toggle; F10 Master mute, no HUD slider/M. Two independently decoded60.0s Ogg loops use0.25s endpoint crossfade; original full MP3s retained. Additional Windows/Web export was rejected by automatic review pending explicit new permission; no runtime game checks performed. Documentation excluded from runtime export. No Canvas or Duke upload.

Lab C follow-up2026-11-01: user explicitly authorizes current recording, two-browser audio checks and Windows/Web exports; reports tool/plan "gpt pro6.1sol", actual fees/time still NR. Fresh exports succeed. Real Level01 simulation captured75sec with existing AI controls, no invulnerability/timeline acceleration, isolated --lab-test/in-memory profile. Settings regression passes. Web Sample playback yielded zero game signal despite a working oscillator probe; Web default override0 uses engine Stream mixing, restoring measured music and F10 mute/unmute. Desktop remains unchanged. Duke destination supplied as people.duke.edu/~wz204/godotgame/; no upload/push performed. Full results in docs/BROWSER_AUDIO_CHECK.md.
