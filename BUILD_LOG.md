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


## 2026-10-04 ? dedicated everfront deployment

Student requested a new everfront folder instead of testdemo. Changed deploy_duke.ps1 default to Z:\public_html\everfront and updated the documented live URL. Uploaded the current build into that directory; deployment succeeded and required file hashes matched. The public everfront homepage matches local HTML and JS/WASM/PCK return HTTP 200. No files in testdemo were changed or deleted during this deployment. Time spent: pending student entry.

## 2026-10-04 — requested Web rebuild and Duke update

Tool: Codex / Godot / PowerShell. Prompt: rebuild Web and upload to Duke. First export failed because build/web was absent; created it and re-exported successfully. Recreated build/web.zip and uploaded to Z:\public_html\everfront; script reported success and verified required-file hashes. Public homepage matches local HTML, and JS/WASM/PCK return HTTP 200. Existing uncommitted project.godot edit and Windows PCK deletion were preserved. Browser gameplay/download verification remains manual. Time spent: pending student entry.



## 2026-10-04 ? Failed to fetch investigation and repair

Tool: Codex / PowerShell / existing Edge / Godot. User reported local Failed to fetch and confirmed double-clicking index.html (file://). Added start_web.ps1 to serve the current Web build over HTTP and open the correct URL. Identified and fixed a separate authoring error: custom web_release.zip was threaded while the preset disabled threads; fetched official web_nothreads templates, rebuilt and verified the generated JS no longer allocates shared WASM memory. Raw HTTP headers also showed Duke missing the WASM Content-Type; added additive .htaccess MIME rules and verified application/wasm after deployment. Upload hashes passed. Automated installation of a temporary browser library was rejected as potentially conflicting with project rules; used installed Edge instead. Browser screenshot showed complete resource download with no fetch error; a longer Edge headless capture timed out, so full interactive gameplay and JSON download remain unverified. No tester records or conclusions were created. Time spent: pending student entry.

## 2026-10-04 — preserve game aspect ratio

User screenshot showed wide-screen expansion beyond the fixed 960x720 gameplay UI/death overlay. Changed window/stretch/aspect from expand to keep so the authored 4:3 viewport scales uniformly with letterboxing. Verified Compatibility captures at 1600x900 and rebuilt the Web release. No gameplay numbers changed; existing user edits remain unstaged. Time spent: pending student entry.

## 2026-10-04 — confirmed A/B restart and three-mode start screen

AI tool: Codex, using PowerShell, Godot and repository edits. Key prompts: implement the student's confirmed checkpoint/campaign restart experiment; then add a start screen and replace the earlier four-preset proposal with 原版 / 慢速 / 快速换弹. Student reports completing prior browser verification and Duke deployment. This iteration prepares a fresh build for student upload; it does not redeploy or manufacture playtest evidence.

Actual work: checked project rules, design and existing restart/panel/telemetry code, and confirmed pre-experiment defaults against Git history. Added a static Godot start screen with six combinations, default A + 原版; frozen world and run telemetry until Start. Added panel return-to-start, F2/F3 mode switching and clean checkpoint/Boss/campaign restoration. Original twelve parameters remain; added one reload multiplier because the original reload durations were authored weapon constants rather than adjustable panel controls. 慢速 changes only scroll multiplier 1.5 → 1.275. 快速换弹 changes only reload multiplier 1 → 0.8 (rifle 1.2 → 0.96 s, piercer 1.8 → 1.44 s). Original values are restored in one batch, with one administrative reset for an in-run change. Manual changes are 自定义. Added local schema-2 raw events, per-variant failure/retry statistics, first retry-keypress timestamp and separate ready-to-play timestamp. Added the openly licensed Noto Sans SC font locally for Chinese labels. Updated assignment documents with confirmed question/hypothesis, empty thresholds/results and a manual third iteration plan.

Actual issues and repairs: PowerShell's text pipeline replaced Chinese literals with question marks during an early edit. A mode-label assertion caught the issue; repaired UTF-8 text with direct patches and reran checks. New start-menu pause meant older smoke scripts needed an explicit Start before testing gameplay. Narrowed the scroll widget step to 0.001 so 1.275 is represented exactly; restore widgets suppress signals to prevent multiple resets. Retry statistics join actual failed run IDs to retry events, so switching, changing parameters, returning and replacing a tester do not create false retries. A real failure abandoned through those actions remains in its version's denominator.

Actual verification: the new six-combination regression suite passed for original defaults, one-variable modes, real reload duration, start pause/input gate, ordinary/Boss A restoration, ordinary/Boss B campaign reset, buffered single-key retry within two seconds, separate animation wait, administrative outcome filtering, manual/default restoration, weapon slots, parseable JSON snapshots and new-session N/A statistics. Existing gameplay, Lab B, player HUD, shield, Boss, turret, laser gate, ground spikes and visual smoke checks all passed. Native Compatibility captures of the start screen and expanded panel passed and were visually inspected. Web release export completed; latest build and ZIP prepared using the existing single-threaded Web preset. The ignored tmp/github-upload nested-project warning is harmless; it is excluded from export. Automated JSON stays in tmp/, not telemetry/.

Remaining manual checks: test the new selectors, Start/Return clicks, fullscreen/window resizing and actual JSON download in a browser over HTTP; after uploading, check Duke in an incognito window. Automated/native checks are engineering checks, not external tester results. No real participants, measured iteration effects or verdict added. Complete and commit Keep / Pivot / Kill thresholds before the first external playtest.

Time spent: pending student entry.

