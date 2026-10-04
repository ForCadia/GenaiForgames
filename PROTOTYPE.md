# Lab B — Prototype notebook

Deadline: **2026-10-14 23:59** (confirm course timezone). Telemetry must be ready before the October 8 classroom swap. The student reports previous browser verification and Duke deployment completed. The latest start/A-B build needs checks after upload. The settings below prepare experiments; they are not completed playtests.

## Prototype Card — thresholds still pending

**Before the first external playtest, confirm Keep / Pivot / Kill thresholds and commit the completed Card.** A development commit with blank thresholds does not satisfy that requirement. Do not retrospectively claim the Card preceded testing already performed.

| Field | Student decision / remaining entry |
|---|---|
| Focus | Willingness to retry after one-hit death |
| Question | 一击死亡后，玩家是否愿意立即重试？重启位置是否影响这种意愿？ |
| Hypothesis | 从当前检查点重启，比从整局开头重启更容易让玩家继续尝试。 |
| A / checkpoint | Current segment entry; Boss death restarts the full Boss encounter |
| B / campaign | Every death, including Boss, restarts segment 0 |
| Single A/B variable | Restart location; original parameters, enemies, art, failure screen, score rules and inputs held constant |
| Primary metric | Successful retries whose first input is within 10 s / actual failures of the corresponding variant |
| Secondary metrics | Total retry rate; failure-to-input / failure-to-ready time; median duration; tester-level willingness, confusion and quits |
| Keep threshold | **Student confirmation pending** |
| Pivot threshold | **Student confirmation pending** |
| Kill threshold | **Student confirmation pending** |
| A/B order | Same tester plays both; alternate A→B and B→A between testers; 原版 only |
| Completed Card commit hash / date | Pending completion and commit |

## Original baseline and three parameter modes

Defaults verified against game_data.gd, main.gd and lab_panel.gd at git commit **613233e**, before experimental presets. Baseline is copied from authored defaults at startup, never from current sliders. The existing twelve numbers remain; a single reload multiplier is added to the same panel.

| Parameter | 原版 | 慢速 | 快速换弹 |
|---|---:|---:|---:|
| jump_speed (px/s) | 720 | 720 | 720 |
| gravity (px/s²) | 1250 | 1250 | 1250 |
| stomp_speed (px/s) | 470 | 470 | 470 |
| slide_time (s) | 0.7 | 0.7 | 0.7 |
| guard_drain (/s) | 66.67 | 66.67 | 66.67 |
| guard_regen (/s) | 50 | 50 | 50 |
| guard_delay (s) | 0.75 | 0.75 | 0.75 |
| guard_lock (s) | 0.5 | 0.5 | 0.5 |
| rifle_cadence (s) | 0.105 | 0.105 | 0.105 |
| piercer_cadence (s) | 0.52 | 0.52 | 0.52 |
| scroll_multiplier | 1.5 | **1.275** | 1.5 |
| laser_gate_speed (px/s) | 315 | 315 | 315 |
| reload_multiplier | 1.0 | 1.0 | **0.8** |
| Cosmetic particles | On | On | On |

慢速 reduces scrolling world speed 15%: first segment 330→280.5 px/s; Boss 277.5→235.875 px/s. Event times and independently moving laser gate stay unchanged. 快速换弹 uses one independent multiplier: rifle 1.2→0.96 s, piercer 1.8→1.44 s, including animation and HUD progress. No other numbers or scoring rules change. The former Baseline / Loop 1 / Loop 2 / Loop 3 names are replaced by 原版 / 慢速 / 快速换弹; manual edits show 自定义. JSON experiment_preset is a compatibility alias of parameter_mode.

## Controls and session protocol

Default **A + 原版**. The start screen pauses world, enemies, timers and animations. No run exists or accumulates time until clicking 开始游戏. That button applies the chosen complete combination once and starts at campaign entry. There are six combinations; held inputs and the start click are gated until release.

F1 opens the existing panel; F2 selects A, F3 selects B; 1/2/3 retain weapon slots. R / Space / Fire retries directly without returning to the menu and retains the current named mode or custom values. A mode switch restarts from campaign entry with administrative_variant_switch. A parameter selection/edit causes exactly one administrative_parameter_change reset; selecting the same A/B mode is a no-op.

返回开始界面 ends an active run with administrative_return_to_start, retains session/data and remembers the last selected options. Starting again applies the selected full named mode, not leftover custom sliders. For 自定义, the menu remembers the last named selection and states that starting will reapply it. New tester archives/exports the old session and returns to the menu with zero runs in a new session; downloads must be saved and checked before handing over. Automated artifacts stay in ignored tmp/, never telemetry/.

## Restoration and measurement definitions

A restores the checkpoint entry's cumulative score, kill counters, ammo, active weapon and scroll distance. It resets player position/movement/guard, reload/fire/slide/lock timers, enemy/projectile collections and timeline. Grenades and temporary effects clear as in the original flow. Boss health, armor, attack sequence and attacks reset in full.

B restores campaign entry: segment 0, score/kill counters/distance zero, rifle selected, magazines 24/5, full guard, no grenade or old objects. Both modes have the same death feedback and 0.35 s animation lock. Resource restoration follows the selected starting point; cumulative A/B scores are not comparable attempt metrics. run_start includes start_score; run_end includes cumulative score and score_delta for interpretation.

Duration counts active simulation seconds, excluding the start screen, panel pauses and input-release gate. Median uses death/victory durations; no observations show N/A. checkpoint_reached identifies progression inside a run without creating a new run.

retry_requested records the first gameplay input dispatch time, including during the death lock. retry separately records failure_to_input_seconds, failure_to_restart_seconds and input_to_restart_seconds. Willingness uses **input** time; animation waiting is not hesitation. UTC timestamps and monotonic milliseconds are retained. Input time means engine event dispatch, not an inaccessible hardware timestamp.

Per-variant denominator = actual run_end events with failure=true. Numerator = unique failed runs followed by a successful retry. Rapid numerator requires first input ≤10 s. Administrative resets, victories and tester changes are excluded. A real death abandoned by switching/returning remains a failure with no retry. Allow the intended response window before exporting.

Summaries are session-wide across parameter modes. Formal A/B should stay 原版; if mixed, filter raw events by parameter_mode and identical snapshots. Rates are run-based, not percentages of people. Person-level willingness requires one row per tester/session and an explicit person denominator. Missing rates are null in JSON / N/A on HUD.

Every event includes session_id, run_id, timestamp, version, variant, restart_mode, parameter_mode, experiment_preset alias, segment/checkpoint, Boss flag and full parameter snapshot. Administrative change events include new choices while the ending attempt retains its old snapshot. All raw events remain available.

## Loop Log — prepared, not completed iterations

Parameter experiments use **A only**, start from 原版, change one number and keep the panel closed during play. Use fresh testers across rounds. Results and keep/revert decisions remain blank.

| Loop / actual date | Baseline → planned value | Reason / expected effect, not observed | Actual sessions / JSON | Actual metric / sample size / result | Keep / revert |
|---|---|---|---|---|---|
| 1 / | scroll_multiplier 1.5→1.275; 慢速 | Reduce scrolling pressure 15%; expect more reaction time and possibly more retries | | | |
| 2 / | reload_multiplier 1.0→0.8; 快速换弹 | Reduce reload downtime 20%; expect fewer empty-weapon delays and possibly more retries | | | |
| 3 / | Manual jump_speed 720→755.14; gravity 1250 unchanged | Earlier jump experiment retained as a manual option. Ideal h=v²/(2g): 207.36→approximately 228.0946 px (~10%); expect easier spike clearance | | | |

Third manual loop: select 原版, keep A, change only Jump speed to 755.14; HUD/JSON show 自定义. Frame-stepped physics means the 10% height change is approximate. Three parameter modes are not three actual iterations. After real testing, record dates, measured results, sample sizes and actual files.

## A/B Comparison — actual results pending

**原版 only**, same tester tries both variants. Alternate A→B and B→A across testers. Begin each exposure at campaign entry; use Return to start to select the other variant within the same session, or F2/F3 for a clean reset. Observe equal durations (three minutes per exposure follows the assignment protocol), watch silently, then ask “What were you trying to do?” Export before the next tester.

| Measure | A / Checkpoint actual | B / Campaign actual | Difference / notes |
|---|---|---|---|
| Testers / sessions / exposure order counts | | | |
| Actual failures | | | |
| Successful retries / rate | | | |
| Input ≤10 s / rapid retry rate | | | |
| Typical failure-to-input / failure-to-ready | | | |
| Median completed run duration | | | |
| Person-level willingness / denominator | | | |
| Confusion, quits, order effects | | | |
| Actual JSON references | | | |
| Preferred mode, margin and uncertainty | | | |

## Playtest Log

At least six actual testers, at least two outside the course. These are empty slots, not claimed participants. Use different testers across parameter rounds; within A/B each tester experiences both modes. Save actual JSON exports in telemetry/.

| Tester ID | In course? (≥2 outside required) | Actual date / round / A-B order / parameter mode | Observation / stuck location | Confusion / answer | Retry / quit behavior | Session ID / actual JSON |
|---|---|---|---|---|---|---|
| Pending 1 | | | | | | |
| Pending 2 | | | | | | |
| Pending 3 | | | | | | |
| Pending 4 | | | | | | |
| Pending 5 | | | | | | |
| Pending 6 | | | | | | |

## Verdict

**Pending real evidence and student judgment.** After testing, write approximately one page stating Keep / Pivot / Kill, compare actual metrics with the precommitted thresholds, cite sample sizes and JSON, connect observations to metrics, discuss uncertainty and state the first Lab C change. No pre-test conclusion is written. Keep this section last.
