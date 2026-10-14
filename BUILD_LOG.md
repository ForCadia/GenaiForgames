# Lab B — Build log

## 2026-10-14 — final student Keep choice and evidence-based Verdict

Tool: Codex / Python standard library / PowerShell. Prompt: final choice is Keep A; compare P04 Original B1 and B1playA1 honestly, note one paired tester, do not count the soon-after-death export as abandonment, do not backfill thresholds, and make continued challenge tuning Lab C's first step. Re-read source documents and raw exports, confirmed full parameter snapshots match, and recomputed counts/durations/three retry timing fields before editing.

Updated Variant Comparison with a detailed paired table and limited conclusion: B deaths/retries 2/2, A 4/3 with its final response right-censored about two seconds after death; captured median first-input delay B 0.8165 s vs A 0.367 s. A responses are faster descriptively, but increased willingness is not established. Differing exposure, B-before-A order and only P04 paired limit inference. Filled the final approximately one-page Verdict with the student's Keep A decision separate from those findings and the supplied less-exciting/relaxing feedback. Lab C retains A and tunes challenge intensity; no extra gameplay change or chosen tuning value added. Card now states numeric thresholds were not set before testing, without backdating completion. Raw JSON unchanged, no upload or rebuild. Time spent: TODO.

## 2026-10-14 — authorized 110% ideal-airtime implementation

Tool: Codex / Godot / PowerShell / Python standard library. Prompt: keep jump strength 720, change gravity from 1250 to 1250/1.1, synchronize defaults/panel/docs, validate actual effect and export Web without changing existing JSON. Implemented only the gravity gameplay change in game_data.gd; panel reads that constant and uses 0.01 increments, avoiding the former 25-unit quantization. Restore defaults and all named modes share the exact internal value. Revision lab-b-0.4 distinguishes new snapshots from historical 1250-gravity sessions.

Actual verification: added tests/airtime_smoke.gd calling the real player update at fixed 60/120 Hz with identical ground-to-ground jumps and no hostile objects. Initially fixed a GDScript inferred-type error; then discovered the test was still on the paused start screen, so simulated input did not jump. Corrected the test to start through the normal game flow, without modifying gameplay to satisfy it. At 60 Hz: old 1.183333 s / 213.402771 px, new 1.300000 s / 234.098480 px, ratio 1.09859155. At 120 Hz: old 1.166667 s / 210.364594 px, new 1.283333 s / 231.097107 px, ratio 1.10. These are engineering simulation measurements, not human results or browser timing. Lower gravity also increases peak height. Report stored only in ignored tmp/airtime-measurement.json.

Airtime, gameplay, Lab B controls, six start modes/A-B/session filtering, player HUD, spikes and Boss checks passed. Web release and ZIP regenerated successfully; only the ignored nested tmp-project warning appeared. Synced AGENTS/GDD/README/PROTOTYPE; historical trials and unknown results stay pending. Seven existing human JSON hashes unchanged. No automatic Duke upload or telemetry upload. Interactive browser verification of the new revision remains pending. Time spent: TODO.

## 2026-10-14 — student iteration decisions and airtime-target audit

Tool: Codex / Git / PowerShell / Python standard library. Prompt: update PROTOTYPE question to whether checkpoint respawn encourages retry, hypothesis yes, keep thresholds unconfirmed; document increased-speed trial reverted, higher-jump trial reverted, and retained slight airtime increase targeting 110% of default. Inspected current jump/gravity/scroll implementation, all available Git refs for the relevant source paths and seven supplied human session parameter snapshots before editing documentation.

Evidence: current defaults are jump_speed=720, gravity=1250, scroll_multiplier=1.5; initial baseline already has these values. Panel implementation preserves them, later history changes precision/presets/UI. No available committed trial/revert values or independent hang-time implementation found. Every supplied run_start still uses jump/gravity 720/1250; Slow alone has scroll 1.275. Student-reported revert/retain decisions were recorded, while unknown trial dates/values/reasons/results remain pending. The prior 755.14 manual-jump proposal is identified as a plan, not historical evidence. No measurement of +10% airtime exists in these exports.

Recorded ideal calculation separately from measurement: at fixed initial speed, T=2v/g gives baseline 1.152 s, 110% target 1.2672 s, gravity 1250/1.1 about 1136.364 (minus 9.09%). Minus 10% gravity would yield about +11.11% ideal airtime, and also affect height. No physics method selected, parameter changed, game rebuilt or deployed. Only PROTOTYPE.md and this log updated; raw JSON preserved. Time spent: TODO.

## 2026-10-14 — P04 Original-A follow-up export

Tool: Codex / Python standard library / PowerShell. Prompt: inspect the new Downloads JSON after the student said the B1 tester also played A1, with feedback that it felt less exciting and relaxing led to repeated deaths. Found B1playA1.json; parsed schema 2 / lab-b-0.2, verified every run is A / checkpoint / Original and its complete parameter dictionary matches B1. Preserved a byte-identical copy in telemetry/ and attributed it to existing P04, not a new tester.

Actual results: four started/completed runs, four deaths, three successful retries, no administrative endings or open runs. Completed-duration total 84.563511 s, mean 21.140878 s, median 16.049472 s. Recorded first-input delays 0.183/0.549/0.367 s; maximum input-to-ready 0.184 s. Last death was at 17:22:47 EDT and export 17:22:49, so the ten-second response window is incomplete; 3/4 retry rate is only the observed export-time value. Updated participant log, P04 B-then-A comparison, seven-session metrics and reported feedback; no population effect, preference verdict or refusal inferred. No raw JSON changes or uploads. Time spent: TODO.

## 2026-10-14 — student-confirmed participant mapping and feedback

Tool: Codex / repository document edits. Student provided notes for A1/A2/A3/B1/B2/B3 and replied yes to clarification that they are six different people and B2/B3 are outside class (A1/A2/A3/B1 had already been marked yes). Recorded six outside-class participants using notebook-only anonymous IDs P01–P06 in filename order, one row each. Added the supplied control/tutorial, jump/spike, overwhelming-content, experienced-player positive feedback and perceived-no-difference summaries. Unspecified details remain unrecorded rather than inferred; P06's comparison referent is unknown. No extra questionnaire created.

Updated Variant Comparison: A2/B2 and A3/B3 have matching settings but different players, so neither is the planned within-person comparison; A1/B1 also differ in parameters. Player experience is a possible confound, not an inferred result. No Keep/Pivot/Kill decision made. Preserved raw JSON and the calculated timing/count tables; verified hashes, six unique notebook rows and Verdict last. No gameplay change, upload or manufactured feedback. Time spent: TODO.

## 2026-10-14 — session-derived Playtest Log and comparison

AI tool: Codex / Python standard library / PowerShell. Prompt: populate Playtest Log from the six human JSON files, ask once for participant mapping/outside-class identity/observations/feedback, preserve raw records and distinguish input latency from game response. Read the JSON, telemetry/VALIDATION.md and existing project documents first. Asked the student for one row per actual person with their files and any existing notes; no new questionnaire created. Participant mapping has not yet been provided, so no six-person or within-person claim is made.

Actual work: converted recorded UTC timestamps to America/New_York EDT for October 14; extracted starts, death/victory completions, administrative endings, open runs, failure/retry/victory counts, completed-duration total/mean/median, per-run score gains, failure causes/checkpoints and three timing measures. Filled verified session evidence and an explicitly unresolved participant-table placeholder. Updated Variant Comparison by full parameter dictionaries: A2/B2 match Slow, A3/B3 match Fast Reload, but same-person attribution is pending; A1 Custom differs from B1 Original. Original-A death/victory evidence is absent. Actual outcomes total 24 completed runs, three administrative ends, two open final runs, 20 failures and 20 successful retries. All recorded input-to-ready intervals are at most 0.333 s; 18/20 death-to-ready intervals are <=2 s. A2/A3 each include a >2 s pre-input wait, so the <=10 s input rate is not used as proof of death-to-ready <=2 s.

Validation: all six raw JSON parsed; recomputed counts from event IDs, compared snapshots, verified display tables and retained Verdict as the final section. Fixed Windows pipeline substitution of non-ASCII separators by using unambiguous ASCII ranges/counts/thresholds in derived tables. Raw file SHA256 values checked against preserved originals; unchanged. No gameplay/build change, upload, manufactured feedback or final design decision. Player IDs, outside-class status, observations, feedback and confirmed exposure pairs remain pending. Time spent: TODO — not inferred.

## 2026-10-14 — real Downloads telemetry inspection

Tool: Codex / Python standard library / PowerShell. Prompt: inspect Downloads JSON; student explicitly clarified the six A/B files are human-played records. Parsed A1/A2/A3/B1/B2/B3, checked required fields, counted actual failures/retries and examined snapshots and retry destinations. Preserved byte-identical copies in telemetry/ with hashes and a validation report; no raw events or tester labels changed, no upload performed. All six parse and contain failure/retry events. Found suffix 2=Slow and 3=Fast Reload, contrary to the prior requested numbering; A1 contains three parameter edits and Custom failures, so it cannot serve as clean Original-A. B1/B2 have an open final run. Six sessions do not identify six people. Added an evidence note without inventing questionnaire responses, tester identities or final judgment. Actual failure/retry counts: A1 4/4, A2 2/2, A3 8/8, B1 2/2, B2 3/3, B3 1/1; all first inputs within 10 seconds. These observations do not replace a controlled comparison. Time spent: TODO.

## 2026-10-14 — submission audit and independent bundle

AI tool: Codex; PowerShell/Python, Git and local Godot 4.7.2. Key prompt: inspect Lab B requirements first, consolidate student questions, repair only essential technical issues and prepare a separate submission directory. Read AGENTS.md, GDD.md, PROTOTYPE.md, BUILD_LOG.md and restart/tuning/telemetry source before edits. Student replied "keep existing", reconfirming design; no new thresholds, tester facts, JSON paths, original GDD, video or verdict were supplied.

Evidence audit: all four documents exist; telemetry/ contains only README, with zero real JSON. Available Prototype Card history is 1b50804 and 8d0bc3e (2026-10-04); both retain pending thresholds. No complete pre-playtest Card commit was found, and first external test date is unknown. Three loops and comparison/tester/verdict structures exist but actual results are empty. Do not backdate or claim these requirements completed. Remote main was b74aace when queried; the local English UI revision 7fcb40b and this audit are newer. Existing user README/project.godot changes and missing Windows PCK were preserved.

Actual modifications: synchronized document labels with Original / Slow / Fast Reload / Custom while retaining the student's question/hypothesis and empty results. Added explicit Git-evidence gap and missing-material checklist. Assigned telemetry revision lab-b-0.3 and clarified that duration excludes menu, panel and input-release gates; no gameplay numbers changed. Repaired an intermittently failing engineering test: a SceneTree frame-time timer could finish before the intended 30 ms real wait, whereas retry latency uses monotonic wall time. The assertion now waits for that same clock; no artificial delay was added to gameplay. Added tools/package_lab_b.py for a fresh independent bundle, working-copy source ZIP including hidden .git, deployable Web files, docs, actual telemetry directory and hash manifest. Automated JSON is not packaged as real playtest data.

Actual verification: engine --version confirmed 4.7.2.stable.official.ed1daf0bf. Gameplay, Lab B panel/live parameters, six start combinations/A-B/administrative filtering, player HUD, Boss, shield, turrets, laser gates, ground spikes and visuals all passed (10 smoke scripts). Independently parsed JSON and checked required fields, current revision, retry times and raw-event A/B denominators; Web resource sizes and ZIP integrity passed. Native Compatibility start/panel capture passed; inspected the English UI. Web release export succeeded with the existing no-thread templates; only the ignored nested tmp project warning appeared. No runtime HTTP/AI service calls found in game scripts. These checks are engineering evidence, not human testing or three completed loops.

Delivery status: new build/bundle remains local in this task; existing Duke workflow retained. Earlier today the English build was uploaded and public HTML/PCK hashes matched, but this audit's lab-b-0.3 build has not been deployed. A fresh interactive browser check, actual JSON download, real six-person tests/loops/comparison, original Lab A/Rep 3, video, thresholds and verdict remain TODO. No new tester data, historical dates/commits or verdict invented. No network upload of telemetry performed. Time spent: TODO — student entry; not inferred.

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

## 2026-10-04 — user-authorized Duke and GitHub refresh

Tool: Codex / PowerShell / Git. Prompt: refresh Duke website and GitHub files. This latest instruction authorizes deployment after the earlier build-only task. Ran the existing deploy_duke.ps1 against the latest Web build; it reported Deployment succeeded for Z:\public_html\everfront and verified required-file hashes. Pushed the committed start-screen, A/B, parameter-mode and documentation changes to origin/main without force. Preserved the student's uncommitted project.godot edit and Windows PCK deletion. No private telemetry was uploaded and no external playtest evidence was created. Interactive browser behavior and JSON downloads require checking the refreshed release in an incognito window. Time spent: pending student entry.


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

