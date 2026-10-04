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
New-Item -ItemType Directory -Force build/web
godot --headless --path . --export-release Web build/web/index.html
python -m http.server 8000 --directory build/web
```

Open `http://localhost:8000` in a browser. Do not open `index.html` with `file://`. `Web` preset uses no threads and excludes test assets, private telemetry, temporary files and docs. Upload all exported files together. No Node.js or engine migration is required. See README for deployment.

This checkout currently has Web custom templates at ignored `tmp/web-templates/web_debug.zip` and `web_release.zip` (official 4.7.2 package). To reproduce them, run `python tools/fetch_web_templates.py`; the tool downloads only Web entries using HTTP byte ranges and needs Python's standard library. Alternatively install standard export templates and clear the Web preset's custom-template fields. Temporary downloads are not included in Git.

## Structure

- `main.gd`, `main.tscn`: simulation, campaign, collision, score, checkpoints, effects.
- `game_data.gd`: original authored defaults and timeline (four segments active, six defined).
- `Player*`, `player_visual.gd`, `player_hud.gd`: player artwork, shapes and HUD.
- Enemy scenes and scripts: turrets, laser gates, spikes, Boss and attacks.
- `lab_panel.gd`: live tuning UI; `lab_telemetry.gd`: local event records and JSON download.
- `tests/`: existing checks plus Lab B regression verification; automated exports belong in ignored `tmp/`, never `telemetry/`.
- `telemetry/`: actual tester JSON files, manually copied from downloads/local archives.
- Markdown documents remain at project root. Keep existing source layout rather than moving everything into the assignment's illustrative `src/` tree.

## Working rules

Read AGENTS.md, GDD.md and PROTOTYPE.md before changes. Preserve this demo, engine, assets, core loop and existing work. Avoid unrelated refactors and extra levels, menus or effects. Do not remove existing mechanics to guess the student's prototype question.

The student chooses the question, hypothesis, A/B values, thresholds and verdict. Never invent Lab A / Rep 3 decisions, testers, results, timings, or prior work. Missing content is explicitly pending. Change one test variable per measured iteration; hold other parameters constant between variants. Every gameplay number tuned during Lab B must be on the panel. Commit small, explicit changes. Complete and commit the Prototype Card before the first outside playtest; a placeholder does not satisfy this requirement.

No AI-service requests or API keys in game code. Telemetry is local only. Do not upload tester data automatically. A new tester archives/exports the previous session before resetting; do not erase archives. Panel pauses are excluded from gameplay duration; retry latency is real elapsed time. Administrative resets must not count as player retries. A/B is pending student confirmation; do not create two identical options and call them an experiment.
