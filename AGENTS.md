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
- `start_screen.gd`: static start screen; no run or simulation before Start. `assets/fonts/`: Noto Sans SC and OFL license for consistent Chinese labels in Web.
- `tests/`: existing checks plus Lab B regression verification; automated exports belong in ignored `tmp/`, never `telemetry/`.
- `telemetry/`: actual tester JSON files, manually copied from downloads/local archives.
- Markdown documents remain at project root. Keep existing source layout rather than moving everything into the assignment's illustrative `src/` tree.

## Working rules

Read AGENTS.md, GDD.md and PROTOTYPE.md before changes. Preserve this demo, engine, assets, core loop and existing work. Avoid unrelated refactors and extra levels, menus or effects. Do not remove existing mechanics to guess the student's prototype question.

The student chooses the question, hypothesis, A/B values, thresholds and verdict. Never invent Lab A / Rep 3 decisions, testers, results, timings, or prior work. Missing content is explicitly pending. Change one test variable per measured iteration; hold other parameters constant between variants. Every gameplay number tuned during Lab B must be on the panel. Commit small, explicit changes. Complete and commit the Prototype Card before the first outside playtest; a placeholder does not satisfy this requirement.

No AI-service requests or API keys in game code. Telemetry is local only. Do not upload tester data automatically. A new tester archives/exports the previous session before resetting; do not erase archives. Panel/menu pauses are excluded from gameplay duration; retry latency is real elapsed time. Administrative resets must not count as player retries.

## Confirmed experiment and start screen

The student selected restart location as the A/B variable: A checkpoint (full Boss encounter on Boss death), B campaign entry on every death. F2/F3 and the existing panel select modes; preserve 1/2/3 weapons. All switches reset cleanly to campaign entry. Default is A + 原版. The latest parameter choices are only 原版 / 慢速 / 快速换弹 (plus 自定义 displayed after a manual panel edit). The earlier four presets are superseded.

Original defaults are verified at commit 613233e and against game_data.gd. Preserve all existing 12 numbers and their defaults; the added reload_multiplier defaults to 1.0. 慢速 changes only scroll_multiplier 1.5→1.275. 快速换弹 changes only reload_multiplier 1.0→0.8. Keep panel selections, menu labels and telemetry parameter_mode consistent. JSON experiment_preset is an alias using the same names.

Only Start creates a run while on the menu; gate held input/clicks before gameplay. Return records administrative_return_to_start and retains session/data. Preset and mode changes record administrative_parameter_change / administrative_variant_switch without fake failures/retries. The first retry event-dispatch time must be preserved during the animation lock; rapid rate uses failure_to_input_seconds. failure_to_restart_seconds separately measures when play is ready. Per-variant denominators are actual deaths, including abandoned deaths. Empty rates are null/N/A. See PROTOTYPE.md for score restoration and analysis definitions.

Parameter rounds use A; formal A/B uses 原版 with alternating tester orders. These are experiment preparations, not real iterations. Thresholds, tester records and results stay pending. Browser verification and the existing Duke deployment were completed by the student; this change prepares a new Web build/ZIP for the student to upload. Do not run the Duke upload script for this task.
