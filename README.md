# GenaiForgames

Current project: EverFront (Godot). Live build: https://people.duke.edu/~wz204/everfront/

# THE FRONT NEVER STOPS — Godot prototype

A single-level 2D side-view shooting runner prototype built for Godot 4.7. The player stays on the left while the world scrolls right-to-left. The player and four-layer backdrop use imported pixel art; enemies, obstacles, effects, and HUD still use procedural geometry.

## Run

Open this folder in Godot 4.7 and press **F6/F5**, or run from a terminal with a Godot executable on PATH:

```powershell
godot --path .
```

The main scene is `main.tscn`.

## Backdrop assets

`main.tscn` contains editor-visible `Parallax2D` nodes for `background.png`, `middlelayer.png`, and `track.png`. Each scrolling layer uses its original 1672-pixel-wide image followed by a horizontally mirrored copy, making a seamless 3344-pixel loop without stretching or changing the source file. The scrolling distance ratios are 0.15, 0.55, and 1.35 respectively. The moon is no longer shown; its original `background-moon.png` and the earlier derived overlay remain untouched but unused. A scene-authored `Ground/CollisionShape2D` has its top edge at Y=620, matching the player's logical foot position and the track artwork.

## Laser gate

The legacy `high_barrage` timeline events now instantiate the editor-previewable `LaserGateEnemy.tscn` instead of four geometric projectiles. The gate still enters at X=990 and moves left at 315 px/s. Its source `lazerdrone.png` is actually 1774x887 rather than the specified 2304x1152, and its rows spill across an even 6x3 grid. `tests/generate_laser_gate_atlas.gd` repacks those existing pixels into `laser_gate_atlas.png` with 296x296 cells, leaving the original untouched and the four unused Hit cells transparent; `tests/generate_laser_gate_frames.gd` writes the three SpriteFrames animations. No rescaling is performed. Both drone hit areas share one exported HP value, defaulting to one hit; the laser damage shape is separate and turns off as soon as Hit begins.

## Controls

| Action | Keyboard / mouse | Controller |
|---|---|---|
| Jump | Space / W | A / Cross |
| Crouch | S / Ctrl | Left stick down |
| Aim | Mouse | Right stick |
| Fire | Left mouse | RT / R2 |
| Guard | Right mouse | LT / L2 |
| Switch weapon | Q / mouse wheel | Y / Triangle |
| Direct weapon slots | 1 rifle / 2 piercer / 3 grenade | — |
| Reload | R | X / Square |
| Grenade | E | RB / R1 |

After death, press R, Space, or Fire to restart the current segment checkpoint. Boss deaths restart the complete boss encounter.

## Prototype notes

- `body(2).png` is the active 8×5 body flipbook, with uniform 256×256 cells. Run plays at 14 FPS; startup, jump, slide and death remain at 12 FPS. Each animation row uses one fixed foot baseline; individual frames are never recentered from their alpha bounds, so authored motion remains intact without crop jitter. Its prominent upper circle is an arm socket, not a head: the complete source frame remains intact, both arm layers attach to that measured socket, and `helmet_game.png` sits slightly behind and above it while aiming toward the cursor. The original `body.png` and helmet assets remain untouched.
- The arm sheets remain 192×204 per cell. Their front and rear rows share a shoulder pivot, with calibrated reload offsets. The complete visual rig is at 0.5 scale; standing and sliding hurtboxes exclude the weapon. Shots spawn from the transformed muzzle in the visible gun direction. The HIGH recovery frame still crops muzzle-flash spill from its preceding cell.
- `PLAYER_CAN_DIE` in `main.gd` is `true`; the normal death and checkpoint retry flow is enabled. `tests/capture_visual.gd` saves running-game and magnified pose screenshots for visual checks.
- Six authored 20–25 second patterns run at a `0.72` prototype pace multiplier; world scrolling is additionally multiplied by `1.5`.
- Assault rifle and piercer have finite magazines and infinite reserve ammunition.
- Light armor takes one armor break plus one body hit. Heavy armor ricochets rifle rounds and requires the piercer to break its armor; there is no weakpoint bypass.
- The fifth segment contains the one-use grenade pickup.
- Boss armor must be broken with the piercer or a passing explosive track barrel. Once armor is gone, a hit on the boss body removes one of four health sections, then its armor resets.
- Audio and remaining placeholder art use color, particle, text, recoil, armor-break, guard, and death feedback.

## High-priority balancing checks

1. Jump clearance over low obstacles and stomp timing at 60/120/144 Hz.
2. Standing versus crouching collision against high barrages and hanging obstacles.
3. Guard drain (1.5 s), 0.75 s recovery delay, and 0.5 s break lockout.
4. Piercer armor-breaking against heavy enemies and the boss, followed by body hits.
5. Every segment and boss death restoring a clean, repeatable checkpoint state.


## Lab B additions (2026-10-04)

Verified engine: **4.7.2.stable.official.ed1daf0bf**. Existing gameplay and art remain. The current active campaign has **four segments followed by Boss**; six timeline segments are defined, so older six-segment/grenade notes above do not describe the full active path.

- First choose A/B and 原版 / 慢速 / 快速换弹 on the static start screen, then click **开始游戏 / START**. Default is **A + 原版**. World, timers and run telemetry stay paused until Start. Each start applies the selected complete combination once and starts at campaign entry; held keys and clicks cannot fire through the menu.
- **F1** or the LAB B button opens/closes the existing tuning panel. The original 12 controls remain; a single **Reload time multiplier** is added. Gameplay, enemy timers and animations pause while open. Scroll to reach all controls, particle toggle and return/reset/export/session buttons.
- An edit takes effect immediately and starts a clean campaign attempt; JSON records an administrative parameter-change ending. Restore Defaults resets all values once. Do not count these resets as player retries.
- **T** exports JSON (unused by original controls); while typing a number, use the export button. Web downloads the session; desktop archives it under Godot `user://lab_b_telemetry` and opens the folder. Copy actual tester exports into `telemetry/`.
- **New tester** archives/exports first, retains old files and returns to the menu with a new session and zero runs. Check the download is saved before handing over. No network/AI telemetry calls. **返回开始界面** retains the existing session/data; an active run ends as administrative_return_to_start.
- Retry uses one press of R / Space / Fire, including during the 0.35-second death animation, and retains the current combination. HUD shows the combination, runs started, median duration, and separate A/B failures/retries/rates. No observations show N/A. Rapid rate uses the first retry keypress within 10 seconds, not the end of the animation; raw JSON also records failure-to-ready and input-to-ready delays.
- **F2 = A / Checkpoint**, **F3 = B / Campaign**, also selectable in the panel. A restores segment entry (full Boss battle on Boss death); B always restores campaign entry. A restores checkpoint score/kill counters/ammo/weapon/scroll distance; B starts with zero score/counters/distance, rifle and 24/5 ammo. All temporary threats/player timers clear. Same failures, score-award rules and controls. Switching mode while playing produces administrative_variant_switch and resets the campaign; it is not a retry. Existing 1/2/3 weapon keys remain.

### Parameter modes and test procedure

Original baseline verified from game constants and git 613233e; it is never captured from temporary sliders. All twelve original defaults remain. Added reload multiplier defaults to 1.0. See PROTOTYPE.md for the full parameter table.

| Mode | Only change from 原版 | Effective example |
|---|---|---|
| 原版 | None | scroll multiplier 1.5; rifle/piercer reload 1.2/1.8 s |
| 慢速 | scroll multiplier 1.5→1.275 (−15%) | first-segment scroll 330→280.5 px/s; event times and independent gate speed unchanged |
| 快速换弹 | reload multiplier 1.0→0.8 (−20%) | rifle/piercer reload 0.96/1.44 s; animation and HUD use the same duration |

These three modes combine with A/B to give six choices. The panel uses the same names; a selection changes the full snapshot with exactly one administrative_parameter_change reset. Manual edits display 自定义. Selecting 原版 restores all original values. Returning to the start screen remembers the last named choice; Start reapplies it, including after custom edits. Former Baseline / Loop presets are superseded.

For parameter rounds, fix **A** and begin each single-variable test from 原版; keep the panel closed while testers play. Third manual iteration can use jump speed 720→755.14 with gravity 1250 unchanged (ideal jump height approximately +10%); it is not a fourth preset. Formal A/B uses **原版 only**, the same tester tries both, and tester orders alternate A→B / B→A. Presets do not count as real measured iterations. Complete thresholds and commit the Prototype Card before the first external playtest.

JSON schema 2 retains raw events with variant, restart_mode, parameter_mode, experiment_preset (same-name compatibility alias), segment/checkpoint, full parameters and session/run IDs. run_start includes start_score; run_end includes score_delta. retry_requested preserves first input time; retry includes failure_to_input_seconds / failure_to_restart_seconds / input_to_restart_seconds. Per-mode rates count unique retried deaths / actual deaths of that mode; administrative endings and tester resets are excluded, but an actual death abandoned without retry remains in the denominator. HUD totals span parameter modes in one session; filter raw records or keep formal A/B entirely 原版. These are run percentages, not participant percentages.

### Browser build and deployment

`build/web/` contains the native single-threaded Godot Web release (index.html, index.js, index.wasm, index.pck and supporting files). Match Godot version exactly; use Compatibility renderer for Web. Export instructions and checks are in AGENTS.md. This machine temporarily uses official Web templates fetched into ignored `tmp/web-templates`; another checkout should install the normal matching templates and clear Web custom-template paths in the editor, or recreate the local templates using `tools/fetch_web_templates.py`. Python is a tooling aid only, not a dependency players install.

Preview locally:

```powershell
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

Open http://127.0.0.1:8000. Host all files together using HTTPS; do not use file://. For itch.io, create an HTML game, ZIP the contents of build/web with index.html at the ZIP root, upload it and enable browser play; choose Restricted and supply the password if used. GitHub Pages can serve the same exported directory. Single-threaded export avoids requiring SharedArrayBuffer headers. Duke deployment was later supplied by the student and completed on 2026-10-04: https://people.duke.edu/~wz204/everfront/.

The student reports earlier browser checks and Duke deployment completed. After uploading this new build, **open the live link in a private/incognito window** and check the new menu, six combinations, F2/F3, one-key retry and T download. This task prepares the local Web build/ZIP; it does not upload a new Duke release. Headless game checks and desktop Compatibility captures do not verify browser UI/download interaction.

### Submission checklist

### Existing Duke upload workflow

The student supplied the existing Duke CIFS deployment method. The original script in `D:\Unity Project\My project` checks Unity-specific Build/TemplateData directories. Use this project's `deploy_duke.ps1` for Godot instead; it uploads exported files, verifies required-file hashes and does not build or delete old hosted directories.

```powershell
cd 'D:\GodotDemo\shoot-planes'
# First re-export the Web preset (Godot executable must be on PATH):
godot --headless --path . --export-release Web build/web/index.html
# Then upload; this uploads to the dedicated everfront directory:
.\deploy_duke.ps1
```

If Z: is unavailable, reconnect using the supplied command and enter the password interactively:

```powershell
net use Z: \\homedir.oit.duke.edu\users\w\wz204 /user:WIN\wz204 * /persistent:yes
```

Default target: `Z:\public_html\everfront`; expected URL: https://people.duke.edu/~wz204/everfront/. This Godot build was uploaded on 2026-10-04 after student confirmation; the game now uses its dedicated everfront directory. The default destination is now the dedicated everfront directory; normal uploads do not target testdemo. After uploading, Ctrl+F5 and test the live URL in an incognito window, including T download. The script has `-WhatIf` for a preview.

### Submission checklist (continued)

- Live browser URL (plus password for a restricted page).
- GitHub repository with instructor added, or project ZIP **including hidden .git**. Keep tmp/ and .godot/ out of the ZIP; if omitting tmp Web templates, clear those custom paths and use installed templates as described above.
- AGENTS.md, GDD.md, PROTOTYPE.md and BUILD_LOG.md; completed Prototype Card committed before first outside playtest.
- Three actual one-variable loops, one actual A/B comparison, six or more real testers including two outside class, and evidence-based approximately one-page Verdict last.
- Actual telemetry JSON files in telemetry/ (currently none).
- 60-90 second gameplay video as a link/upload (student recording pending).
- Telemetry operational and browser-checked before **October 8** class swap; Canvas due **October 14, 2026, 23:59** (confirm course timezone).


### Local Failed to fetch troubleshooting

Do not double-click `build/web/index.html`: `file://` prevents the engine from fetching WASM/PCK. Start the local HTTP preview from the project root:

```powershell
.\start_web.ps1
```

It opens http://127.0.0.1:8000/ and reuses only a server whose homepage matches this build; use `-Port 8001` if another project occupies the port. Python is needed only for this local development preview. Online players install nothing.

The Web custom templates must be **web_nothreads_debug.zip / web_nothreads_release.zip**, matching `variant/thread_support=false`. The initial custom templates were threaded despite that setting; corrected on 2026-10-04. The Duke deploy script installs the WASM/PCK MIME rules from `tools/duke.htaccess` without discarding existing rules. The WASM header must be `Content-Type: application/wasm`. Use a private window after updates.
