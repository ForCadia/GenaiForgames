# Lab B — Build log

## 2026-10-04 — existing Duke deployment adaptation

Tool: Codex / PowerShell. Key prompt: student supplied “Unity 重新 Build → PowerShell 运行上传脚本” and the Duke CIFS destination.

Read the existing Unity deployment script. It requires Unity Build/TemplateData directories and deletes those destination entries, so it cannot upload the Godot Web export. Added a separate Godot-specific `deploy_duke.ps1` in this project, copying exported files and verifying SHA256 hashes. Updated deployment instructions to prioritize the supplied Duke host. No remote upload or deletion was performed. Z: was not available in this session. Time spent: pending student entry.

## 2026-10-04 — inspection and baseline

Tool: Codex; PowerShell; Godot 4.7.2; Git.

Key prompt: “先检查项目，再分阶段修改…不要重新做游戏…不要替我编造测试者、试玩数据、迭代效果或最终结论。” Follow-up: “Lab_B_Playable_Prototype (Final) 桌面上参考这个文件”.

Actual work: inspected README, project/export configuration, main loop, game data, actors and existing tests. Confirmed engine version by executable output. Found four active campaign segments (six defined), existing one-hit death/checkpoint retry, no existing AGENTS/GDD and no `.git`. Initialized Git and committed the existing project baseline; no previous history was available. Read all six pages of the supplied PDF.

Actual issues: console launcher in Downloads had no adjacent main executable; used the actual Desktop engine executable. Initial baseline headless check reported user-log/certificate access errors but gameplay smoke passed. After interruption, default sandbox process startup failed; authorized escalated commands worked. PDF reading lacked installed packages; installed pypdf into ignored `tmp/pdf-reader`. Windows output encoding failed on PDF bullet characters; configured UTF-8 output and read the full text.

Time spent: pending student entry (do not infer elapsed effort from tool timestamps).

## 2026-10-04 — measurement and tuning implementation

Tool: Codex; PowerShell/Python for exact edits; Godot for validation.

Key prompt: “在现有 demo 上实现…至少 8 个…参数必须实际影响游戏…telemetry…本地…需要我决定的部分先留待填写。”

Actual changes: added 12 live gameplay parameters, reset controls, existing cosmetic particle toggle, collapsible panel, local telemetry with run/session IDs and parameter snapshots, JSON export and session archive/reset. Buffered one retry press during the existing 0.35-second death animation lock. Added a single-threaded native Web export preset with Web-only Compatibility renderer. Created assignment documents with explicitly pending design decisions and empty evidence slots. No A/B experiment selected or enabled yet.

Actual issues/fixes: the full parameter list would exceed the viewport height; placed it in a fixed-height scroll container. Panel pauses timer-driven enemies and animations as well as the simulation, and waits for gameplay input release on close. Restoring defaults must produce one administrative reset; reset widgets with signals suppressed.

Validation: original gameplay aim/armor/transitions, shield, Boss, turret, laser gate, ground spikes and player HUD checks passed. New Lab B checks passed for 12 controls, live gameplay effects, UI input isolation, buffered retry, JSON fields and session separation. Expanded jump verification initially used a zero time step and failed because the grounded reset clears velocity; changed the test to a real 0.01-second step and it passed. Compatibility rendered panel/death captures passed and the panel screenshot was inspected. Native Web release export succeeded with official 4.7.2 templates; fetched just Web entries from the official 1.28 GB archive using HTTP ranges. Browser automation initialization exited unexpectedly twice, so browser loading, download and live-link verification remain unverified. A/B switching remains intentionally unimplemented pending student decisions. No external playtests performed. Automated checks are engineering verification, not Loop Log evidence.

Time spent: pending student entry.


## 2026-10-04 ? Duke upload completed

Tool: Codex / PowerShell / Godot. Student confirmed replacing testdemo and reconnected Z:.

Re-exported the current Godot Web build successfully, then ran deploy_duke.ps1. It reported Deployment succeeded and verified SHA256 hashes for index.html, index.js, index.wasm and index.pck. Public HTTP verification: homepage 200 and content identical to local HTML; JS, WASM and PCK all returned 200. WASM Content-Type was application/wasm. Live URL: https://people.duke.edu/~wz204/testdemo/. Existing Unity subdirectories were not deleted. Initial upload waited on network access before succeeding. Browser play and JSON download still require incognito verification; no playtest evidence was created. Time spent: pending student entry.
