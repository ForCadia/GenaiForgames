# Final Lab B requirement-by-requirement review - 2026-10-14

Statuses: 通过 = directly checked file/code/test; 用户确认 = student confirmation; 证据不足 = absent/limited evidence or unmet requirement, even when honestly disclosed; 不适用 = not required or an allowed alternative. This checklist does not certify full compliance.

Assignment reference actually read in full: C:/Users/lenovo/Downloads/Lab_B_Playable_Prototype (Final).pdf, six pages, SHA256 8d456d777a7f39f19fde0594e19d66dd0040e6fe5e14fc0fe6bec43ef11e15c5. The specifically named (Final)(1).pdf was not found; do not assert version equivalence.

| Requirement / PDF page | Status | Actual basis |
|---|---|---|
| Exact requested assignment PDF | 证据不足 | Searched Desktop/OneDrive/Downloads/Videos/Documents and supplied E drive folder. (Final)(1).pdf not found. Full available six-page (Final).pdf read; requested-version equivalence not assumed. |
| Live browser link (pp.1,2,5) | 通过 | https://people.duke.edu/~wz204/everfront/; current HTML/JS/WASM/PCK HTTP 200 and SHA256 equal local build in this review. |
| No installation / private-window check (pp.1,5,6) | 用户确认 | Student explicitly confirmed latest incognito gameplay, restart and JSON download completed. Not replaced by assistant HTTP or video inference; no repeat requested. |
| Main verb / core loop / fail state (p.1) | 通过 | Aim/fire within existing jump/guard shooter, one-hit death, stage/Boss progression; current main.gd and fresh gameplay/HUD/Boss/spike checks passed. |
| One-key instant retry <=2 s (p.1) | 通过 | Buffered R/Space/Fire through 0.35 s death lock; fresh lab_b and start_modes checks pass. User-confirmed browser retry. Separate input-to-ready measurement; ten-second willingness is not used as restart proof. |
| Score or progress signal (p.1) | 通过 | HUD score, kills, segment and Boss state; player_hud/gameplay checks passed. |
| At least eight effective live parameters (pp.1,2,5) | 通过 | 13 numerical SPECS including gravity=1250/1.1, jump 720, scroll and reload; fresh lab_b_smoke tests each control/live effects/default restoration. |
| Every tuned number exposed (p.2) | 证据不足 | Known implemented numbers are on panel; historical raised-speed/raised-height trial values absent, so completeness for unknown historical edits cannot be proven. |
| Juice count and switches (pp.1,2) | 通过 | Existing decorative particles use particles_enabled CheckButton and _emit gate; hostile Boss projectiles are gameplay, not a cosmetic toggle. No new shake/juice added. |
| Telemetry schema/download (pp.2,4) | 通过 | run_start/run_end/retry, duration/score/cause/x/y plus versions/modes/snapshots; seven files parse, fresh telemetry/session tests passed. User confirmed actual download. |
| Local telemetry, no network/library/AI calls (pp.4,6) | 通过 | GDScript local FileAccess and JavaScriptBridge download only; current source search found no runtime HTTP/AI service/key calls. No game runtime package added. |
| telemetry/ real exports (pp.2,5) | 通过 | Seven originals A1/A2/A3/B1/B2/B3/B1playA1; each byte-identical to Downloads and original recorded hash; no generated smoke events substituted. |
| Telemetry ready before Oct 8 swap (p.5) | 证据不足 | Oct 4 feature/test commits and logs exist; no separate classroom-swap export or observation supplied to establish actual Oct 8 use. |
| Four root Markdown documents (pp.2,3) | 通过 | AGENTS/GDD/PROTOTYPE/BUILD_LOG present; source ZIP and standalone requested documents verified. |
| Actual stack/version/run/build (pp.2,3,6) | 通过 | Executable --version freshly confirms Godot 4.7.2.stable.official.ed1daf0bf; AGENTS pins exact engine/templates, headless checks, native Web export and HTTP preview. |
| Source layout illustration / Node suggestion (p.2) | 不适用 | Godot existing layout retained; PDF allows stack choice and src is illustrative. No TypeScript/Node migration necessary. |
| Coding assistant reads/works in folder (pp.2,3) | 通过 | Codex reads actual AGENTS/GDD/PROTOTYPE and source, runs engine checks; BUILD_LOG records work and failures. |
| Lab A / Rep 3 design and sprint source (pp.1,2) | 通过 | Original Lab A and W4 full GDD/two-week sprint PDFs/DOCX archived unchanged; detailed GDD summary separates historical plan/current code and hypothetical critique. |
| Prototype Card question/hypothesis/metrics (p.3) | 通过 | Student question checkpoint respawn/retry, hypothesis yes, raw-event metrics and definitions present. |
| Numeric Keep/Pivot/Kill and pre-test Card commit (p.3) | 证据不足 | Numeric thresholds not set before testing; available initial commits contain placeholders. Explicit disclosure is not fulfillment; no backdated repair. |
| Three single-number measured loops (pp.3,6) | 证据不足 | Three rows exist; developer speed and higher-jump trials reverted for feel, but exact trial values/dates and quantified replay effects not recorded. Gravity iteration has fresh fixed-step engineering measurement, not human outcome. |
| A/B in same build and switch event (pp.3,5) | 通过 | Restart mode checkpoint/campaign in main.gd; F2/F3 and panel record variant_switch. Fresh six-combination/ordinary/Boss reset checks pass. |
| Suggested 1/2 variant controls (pp.3,5) | 不适用 | 1/2/3 already weapons; compatible F2/F3 implement the actual runtime switch, preserving core inputs. |
| One same-person Variant Comparison (p.3) | 通过 | P04 B1 then B1playA1, identical historical Original snapshots. Table and limited finding present; n=1, unequal exposure and final censored response disclosed, no forced winner. |
| Six testers / two outside class (pp.3,4) | 用户确认 | Student explicitly confirmed P01-P06 are six different humans, all outside class; each has a row with original references and supplied feedback. |
| Standard three-minute session / silent watch / one question (p.4) | 证据不足 | Record ranges are shorter than three minutes; exact standard-session procedure/question not established by supplied evidence. Existing real notes retained; no new response fabricated. |
| Different testers in parameter rounds (p.4) | 证据不足 | Six distinct participants confirmed, but allocation/chronology for the two historical reverted trials is unavailable. The intentional P04 A/B repeat is separately documented. |
| Verdict last / about one page / Lab C (pp.2,3,6) | 通过 | 580-word final section: student Keep A, hypothesis not proven, right-censoring not abandonment, Lab C challenge tuning; no invented pre-test threshold. |
| Build-log dates/tool/prompt/failures (pp.3,6) | 通过 | Actual recorded operations and source-attributed past work present, including this review; not invented prior commits/events. |
| Build-log approximate elapsed effort (p.6) | 证据不足 | Unprovided timings remain TODO; tool timestamps are not made-up effort estimates. |
| Live AI / API keys (p.6) | 通过 | No runtime AI or API-key calls found; historical mood references and offline assistant use are separately disclosed. |
| Own work / CC0 assets / no purchased game templates (pp.1,6) | 证据不足 | Original source disclosures and Noto OFL license retained; full current sprite/audio permissions/origin not proven. Do not equate disclosure with CC0/compliance. |
| Out-of-scope menus/art/content (pp.1,2) | 证据不足 | Existing static mode-selection start screen exceeds literal restart-only menu scope; non-greybox art lacks complete provenance. No new unrelated system/level added in this review; no silent scope pass. |
| 60-90 s final video (p.5) | 证据不足 | Student explicitly chose the existing long recording. EverFront-demo.mp4 is included unchanged, full decode verified; duration 99.31 s exceeds the 90 s maximum by 9.31 s. Choice does not change the PDF duration rule; no editing performed. |
| Project ZIP including hidden .git (p.5) | 通过 | Fresh working-copy ZIP includes full original history, latest four root docs, design_sources and seven JSON; verified after log update. Caches/tmp/generated builds excluded from working files. |
| Instructor repository access (p.5) | 不适用 | Using allowed source ZIP with hidden .git submission option; repository link may be supplemental. No instructor invite performed or claimed. |
| Separate PROTOTYPE/BUILD_LOG/JSON (p.5) | 通过 | Standalone final documents and telemetry directory match project source; relative telemetry references work. |
| Canvas deadline / submission (pp.1,5) | 不适用 | PDF due Oct 14 at 11:59 pm. Prepared locally only; no Canvas upload/submit authorized or performed. |
| Rubric grade / winner claims (pp.5,6) | 不适用 | No numeric grade predicted. Build checks and user confirmations do not erase evidence/iteration gaps. |

## Actual desktop submission contents

EverFront-project-with-git.zip; standalone PROTOTYPE.md and BUILD_LOG.md; telemetry/ with seven original JSON plus provenance notes; this checklist; SUBMIT.txt; MANIFEST.json and FINAL_VERIFICATION.txt. EverFront-demo.mp4 is the student-selected 99.31-second original; VIDEO_INFO.txt records the duration and unchanged copy. It is not claimed to meet the 60-90 second rule. Source ZIP includes design_sources/ and the four root Markdown files; temporary caches/video tools, .godot and unrelated generated builds are excluded. User pending project.godot edits are preserved as the current working-copy source, with Git history intact.

## Resolved user confirmation

The student confirms latest incognito gameplay, single-key restart and JSON download passed. Earlier assistant browser-tool failure is historical only; no repeat is requested. No new interactive test is claimed by the assistant.

## Remaining gaps are not fulfilled merely by disclosure

Requested (Final)(1) assignment reference not found; chosen long video exceeds the duration maximum; pre-test numeric thresholds/Card timing incomplete; first two trial values/dates/measured results missing; standard three-minute protocol and parameter-round history not established; some build-log elapsed-effort entries unknown; asset provenance/CC0 and strict scope compliance incomplete. P04's n=1 paired comparison is present but weak; the final A death is right-censored, not abandonment. Student Keep A remains a design decision rather than proven superiority.

No gameplay changed; no original file edited; no Canvas submission performed.
