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

- **F1** or the LAB B button opens/closes the tuning panel. Gameplay, enemy timers and animations pause while open. Scroll to reach all 12 sliders/number controls, cosmetic particle toggle and reset/export/session buttons.
- An edit takes effect immediately and starts a clean campaign attempt; JSON records an administrative parameter-change ending. Restore Defaults resets all values once. Do not count these resets as player retries.
- **T** exports JSON (unused by original controls); while typing a number, use the export button. Web downloads the session; desktop archives it under Godot `user://lab_b_telemetry` and opens the folder. Copy actual tester exports into `telemetry/`.
- **New tester** archives/exports first, retains old files and starts a new session. Check the download is saved before giving the game to the next tester. No network/AI telemetry calls.
- Retry uses one press of R / Space / Fire, including a press during the 0.35-second death animation. HUD shows runs started, median completed death/victory duration, retried failures/all failures, and retries within 10 seconds/all failures.
- A/B is **pending the student's question, hypothesis and values**. Existing 1/2/3 weapon keys remain. No two-variant experiment is claimed yet.

### Browser build and deployment

`build/web/` contains the native single-threaded Godot Web release (index.html, index.js, index.wasm, index.pck and supporting files). Match Godot version exactly; use Compatibility renderer for Web. Export instructions and checks are in AGENTS.md. This machine temporarily uses official Web templates fetched into ignored `tmp/web-templates`; another checkout should install the normal matching templates and clear Web custom-template paths in the editor, or recreate the local templates using `tools/fetch_web_templates.py`. Python is a tooling aid only, not a dependency players install.

Preview locally:

```powershell
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

Open http://127.0.0.1:8000. Host all files together using HTTPS; do not use file://. For itch.io, create an HTML game, ZIP the contents of build/web with index.html at the ZIP root, upload it and enable browser play; choose Restricted and supply the password if used. GitHub Pages can serve the same exported directory. Single-threaded export avoids requiring SharedArrayBuffer headers. Duke deployment was later supplied by the student and completed on 2026-10-04: https://people.duke.edu/~wz204/testdemo/.

After deployment, **open the live link in a private/incognito window**; check loading, failure, one-key retry, parameter controls and T download. Browser automation was unavailable in this session, so successful export and desktop Compatibility checks do not prove browser execution. Test the deployed build before inviting testers.

### Submission checklist

### Existing Duke upload workflow

The student supplied the existing Duke CIFS deployment method. The original script in `D:\Unity Project\My project` checks Unity-specific Build/TemplateData directories. Use this project's `deploy_duke.ps1` for Godot instead; it uploads exported files, verifies required-file hashes and does not build or delete old hosted directories.

```powershell
cd 'D:\GodotDemo\shoot-planes'
# First re-export the Web preset (Godot executable must be on PATH):
godot --headless --path . --export-release Web build/web/index.html
# Then upload; this replaces the current testdemo index.html:
.\deploy_duke.ps1
```

If Z: is unavailable, reconnect using the supplied command and enter the password interactively:

```powershell
net use Z: \\homedir.oit.duke.edu\users\w\wz204 /user:WIN\wz204 * /persistent:yes
```

Default target: `Z:\public_html\testdemo`; expected URL: https://people.duke.edu/~wz204/testdemo/. This Godot build was uploaded on 2026-10-04 after student confirmation; the default URL now returns the matching Godot homepage. To keep the existing Unity homepage, specify another destination such as `-DestinationPath 'Z:\public_html\everfront'` and use the corresponding URL. After uploading, Ctrl+F5 and test the live URL in an incognito window, including T download. The script has `-WhatIf` for a preview.

### Submission checklist (continued)

- Live browser URL (plus password for a restricted page).
- GitHub repository with instructor added, or project ZIP **including hidden .git**. Keep tmp/ and .godot/ out of the ZIP; if omitting tmp Web templates, clear those custom paths and use installed templates as described above.
- AGENTS.md, GDD.md, PROTOTYPE.md and BUILD_LOG.md; completed Prototype Card committed before first outside playtest.
- Three actual one-variable loops, one actual A/B comparison, six or more real testers including two outside class, and evidence-based approximately one-page Verdict last.
- Actual telemetry JSON files in telemetry/ (currently none).
- 60-90 second gameplay video as a link/upload (student recording pending).
- Telemetry operational and browser-checked before **October 8** class swap; Canvas due **October 14, 2026, 23:59** (confirm course timezone).
