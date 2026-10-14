# Lab B — Prototype notebook

Deadline: **2026-10-14 23:59** (confirm course timezone). Telemetry must be ready before the October 8 classroom swap. The student reports previous browser verification and Duke deployment completed. The latest start/A-B build needs checks after upload. The settings below prepare experiments; they are not completed playtests.

## Prototype Card — thresholds still pending

**Before the first external playtest, confirm Keep / Pivot / Kill thresholds and commit the completed Card.** A development commit with blank thresholds does not satisfy that requirement. Do not retrospectively claim the Card preceded testing already performed.

| Field | Student decision / remaining entry |
|---|---|
| Focus | Willingness to retry after one-hit death |
| Question | 检查点重生是否会让玩家更愿意重试？ |
| Hypothesis | 会。（学生确认；尚非测试结论。） |
| A / checkpoint | Current segment entry; Boss death restarts the full Boss encounter |
| B / campaign | Every death, including Boss, restarts segment 0 |
| Single A/B variable | Restart location; original parameters, enemies, art, failure screen, score rules and inputs held constant |
| Primary metric | Successful retries whose first input is within 10 s / actual failures of the corresponding variant |
| Secondary metrics | Total retry rate; failure-to-input / failure-to-ready time; median duration; tester-level willingness, confusion and quits |
| Keep threshold | Not set before testing; no retrospective numeric threshold. Final student design choice: Keep A. |
| Pivot threshold | Not set before testing; no retrospective numeric threshold. |
| Kill threshold | Not set before testing; no retrospective numeric threshold. |
| A/B order | Same tester plays both; alternate A→B and B→A between testers; Original only |
| Completed Card commit hash / date | No complete pre-test Card with numeric thresholds found; this post-test decision does not repair that timing gap. |

## Original baseline and three parameter modes

Submission audit on **2026-10-14**: the student reconfirmed the existing question/hypothesis and mechanisms. Git contains notebook commits `1b50804` and `8d0bc3e`, both dated 2026-10-04, but the Card's thresholds were placeholders in both and remain unconfirmed. There is no complete pre-playtest Card commit in the available history. First external playtest date and any separate precommit evidence: **TODO — student input**. Do not backdate a threshold or imply the placeholder met the requirement. If external testing already happened, disclose this timing gap rather than retroactively claiming preregistration.

At the initial audit no real JSON was present. Later on 2026-10-14, six student-confirmed human session exports were received in `telemetry/`; their measured session results are now listed in Playtest Log. Participant mapping and existing feedback were subsequently student-confirmed in Playtest Log; measured iteration decisions, controlled within-person A/B evidence, video and verdict remain **TODO**. Engineering smoke-test events are excluded from playtest evidence. English UI/JSON labels are Original / Slow / Fast Reload / Custom; earlier Chinese exports, if supplied, map to the corresponding modes, and must still be filtered by identical parameter snapshots. Build `lab-b-0.4` now identifies the authorized gravity revision. Historical lab-b-0.2 exports retain gravity 1250 and are not pooled with the new defaults.

Historical pre-experiment defaults are verified at **613233e**. On 2026-10-14 the student explicitly authorized changing only default gravity to 1250/1.1, with jump_speed=720 unchanged. The table below describes current lab-b-0.4 defaults; older human exports and their comparison tables remain historical 1250-gravity evidence. Baseline is copied from authored defaults at startup, never current sliders. Original/Slow/Fast Reload all share the revised gravity, so restart-only A/B still holds all other parameters equal within this build. Restore defaults restores the revised value.

| Parameter | Original | Slow | Fast Reload |
|---|---:|---:|---:|
| jump_speed (px/s) | 720 | 720 | 720 |
| gravity (px/s²) | 1250/1.1 = 1136.363636... | 1250/1.1 = 1136.363636... | 1250/1.1 = 1136.363636... |
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

Slow reduces scrolling world speed 15%: first segment 330→280.5 px/s; Boss 277.5→235.875 px/s. Event times and independently moving laser gate stay unchanged. Fast Reload uses one independent multiplier: rifle 1.2→0.96 s, piercer 1.8→1.44 s, including animation and HUD progress. No other numbers or scoring rules change. The former Baseline / Loop 1 / Loop 2 / Loop 3 names are replaced by Original / Slow / Fast Reload; manual edits show Custom. JSON experiment_preset is a compatibility alias of parameter_mode.

## Controls and session protocol

Default **A + Original**. The start screen pauses world, enemies, timers and animations. No run exists or accumulates time until clicking START. That button applies the chosen complete combination once and starts at campaign entry. There are six combinations; held inputs and the start click are gated until release.

F1 opens the existing panel; F2 selects A, F3 selects B; 1/2/3 retain weapon slots. R / Space / Fire retries directly without returning to the menu and retains the current named mode or custom values. A mode switch restarts from campaign entry with administrative_variant_switch. A parameter selection/edit causes exactly one administrative_parameter_change reset; selecting the same A/B mode is a no-op.

Return to start ends an active run with administrative_return_to_start, retains session/data and remembers the last selected options. Starting again applies the selected full named mode, not leftover custom sliders. For Custom, the menu remembers the last named selection and states that starting will reapply it. New tester archives/exports the old session and returns to the menu with zero runs in a new session; downloads must be saved and checked before handing over. Automated artifacts stay in ignored tmp/, never telemetry/.

## Restoration and measurement definitions

A restores the checkpoint entry's cumulative score, kill counters, ammo, active weapon and scroll distance. It resets player position/movement/guard, reload/fire/slide/lock timers, enemy/projectile collections and timeline. Grenades and temporary effects clear as in the original flow. Boss health, armor, attack sequence and attacks reset in full.

B restores campaign entry: segment 0, score/kill counters/distance zero, rifle selected, magazines 24/5, full guard, no grenade or old objects. Both modes have the same death feedback and 0.35 s animation lock. Resource restoration follows the selected starting point; cumulative A/B scores are not comparable attempt metrics. run_start includes start_score; run_end includes cumulative score and score_delta for interpretation.

Duration counts active simulation seconds, excluding the start screen, panel pauses and input-release gate. Median uses death/victory durations; no observations show N/A. checkpoint_reached identifies progression inside a run without creating a new run.

retry_requested records the first gameplay input dispatch time, including during the death lock. retry separately records failure_to_input_seconds, failure_to_restart_seconds and input_to_restart_seconds. Willingness uses **input** time; animation waiting is not hesitation. UTC timestamps and monotonic milliseconds are retained. Input time means engine event dispatch, not an inaccessible hardware timestamp.

Per-variant denominator = actual run_end events with failure=true. Numerator = unique failed runs followed by a successful retry. Rapid numerator requires first input ≤10 s. Administrative resets, victories and tester changes are excluded. A real death abandoned by switching/returning remains a failure with no retry. Allow the intended response window before exporting.

Summaries are session-wide across parameter modes. Formal A/B should stay Original; if mixed, filter raw events by parameter_mode and identical snapshots. Rates are run-based, not percentages of people. Person-level willingness requires one row per tester/session and an explicit person denominator. Missing rates are null in JSON / N/A on HUD.

Every event includes session_id, run_id, timestamp, version, variant, restart_mode, parameter_mode, experiment_preset alias, segment/checkpoint, Boss flag and full parameter snapshot. Administrative change events include new choices while the ending attempt retains its old snapshot. All raw events remain available.

## Loop Log — student-reported iterations and evidence limits

On 2026-10-14 the student supplied these three actual iteration decisions. That is the report date, **not an invented date for when the experiments happened**. Trial dates, historical trial values, reversal reasons and measured effects not supplied remain **待补**. These rows replace the earlier proposed Slow / Fast Reload / manual-jump experiment plan; that proposal was not evidence of completed historical iterations. The named game modes still exist and have not been removed or changed.

| Iteration / actual trial date | Student-reported change | Verified numerical / implementation evidence | Revert / retain decision | Reason and actual playtest effect | Trial JSON / historical evidence |
|---|---|---|---|---|---|
| 1 / 待补 | 尝试提高速度 | Exact increased value: 待补. Current default scroll_multiplier=1.5; first-segment authored scroll 220 gives 330 px/s. main.gd _scroll() multiplies authored segment/Boss speed by the panel multiplier. This identifies the current mechanism, not the historical trial's exact edit. | 撤销（学生确认）；current default remains 1.5 | 撤销原因、试玩效果及测量数据：待补 | Available history has no committed higher-speed trial/revert. Slow exports A2/B2 use 1.275, a decrease, and do not prove this increase trial. Trial export/commit: 待补. |
| 2 / 待补 | 尝试提高跳跃高度 | Exact historical value/method: 待补. Before this airtime revision, defaults were jump_speed=720 px/s, gravity=1250 px/s². main.gd applies initial velocity -jump_speed and per-frame gravity. Higher jump_speed is a possible mechanism, not a verified account of how this trial was made. | 撤销（学生确认）；jump_speed remains 720; the subsequent gravity revision is documented separately | 撤销原因、试玩效果及测量数据：待补 | The prior notebook's 755.14 was a proposed manual value for approximately +10% ideal height, not proof it was used. No matching committed trial/revert or supplied human snapshot found. |
| 3 / historical trial date 待补; current implementation 2026-10-14 | 最终保留略微增加滞空时间，目标为默认值的 110% | Implemented now: jump_speed=720 unchanged; gravity=1250.0/1.1=1136.363636... in game_data.gd, referenced by panel defaults. This is a 9.09% gravity reduction; theory targets T ratio 1.10. Panel precision 0.01; internal value retains the expression precision. | Retained direction and implementation, student-authorized; not deployed this turn | Engineering fixed-step results: +9.859% airtime at 60 Hz, +10.000% at 120 Hz; jump height also increases. Human effect after this change 待补 | tests/airtime_smoke.gd; ignored tmp/airtime-measurement.json is engineering evidence, not playtest data. Historical trial values/dates/feedback remain 待补 |

### Code and Git check for these records

Checked current game_data.gd, lab_panel.gd, main.gd, all seven telemetry JSON files and all available Git refs for those source paths. Baseline commit `23e8fa2` already contains jump_speed=720, gravity=1250, SCROLL_MULTIPLIER=1.5. Commit `8cf90c7` exposes these same values on the panel; `66f367d` changes widget precision and introduces Slow=1.275, without changing the Original jump/gravity defaults. `7fcb40b` translates UI. Those pre-change commits do not establish the student's historical higher-speed / higher-jump trial values or airtime trial. The authorized implementation below occurs now, without backdating earlier work. Trials may have occurred in uncommitted or unavailable work; their absence from this history is not a claim they never happened. No dates or historical commits have been reconstructed.

All supplied run_start snapshots have jump_speed=720 and gravity=1250. Their scroll multiplier is 1.5 except Slow sessions A2/B2 (1.275). Run duration is not jump airtime, and these exports contain no jump-takeoff/landing timing sufficient to measure a 10% flight-duration gain. The existing 13 panel controls contain jump speed and gravity, but no independent airtime control. These seven original exports remain unchanged. The subsequent authorized lab-b-0.4 change updates defaults/physics and a local Web build; it does not modify historical snapshots or published builds automatically.

### Airtime target is distinct from gravity reduction

For an ideal jump returning to its launch height, with constant downward gravity and no obstacle/stomp interaction, **T=2v/g**. Using historical defaults v=720 and g=1250 gives **T_ideal=1.152 s**; the stated 110% target would be **1.2672 s** in that ideal model. These are calculations, **not frame-stepped game measurements**.

If v alone is held fixed and constant gravity is the chosen mechanism, reaching that ideal target requires g_new=1250/1.10≈1136.364 px/s², a **9.09% reduction**. Reducing gravity by 10% instead gives 1125 and an ideal duration ratio 1/0.9≈1.1111 (about +11.11%), so it must not be labeled the same change. Reducing gravity with fixed initial speed also increases ideal jump height; it would not automatically isolate airtime after withdrawing a height increase. The student subsequently authorized this exact fixed-v gravity method; it is now implemented in lab-b-0.4. Frame integration/collision handling differ from the ideal model, and the measured engineering results are below. This also raises jump height; it is not a claim that height remained unchanged.

Keep / Pivot / Kill **numeric thresholds remain unconfirmed**. The theoretical 10% target, fixed-step measurements below and student retention decision are separate facts; none is a final prototype verdict or a measured human outcome. Future measured iterations should isolate one variable, keep A/B parameters identical within a comparison and keep the panel closed during play.

### Current implementation: fixed-step engineering verification

The test uses actual main.gd _update_player(), starts through the normal Start flow, performs a jump from ground level to ground level without enemies/stomps, and integrates at the specified fixed delta. It measures elapsed simulation time and peak displacement; it is not interactive browser or human testing. Both before/after use identical jump_speed=720. The initial grounded-frame gravity check and discretization explain the difference from ideal T=2v/g.

| Simulation frequency | Historical gravity / airtime / peak height | Revised gravity / airtime / peak height | Measured airtime ratio |
|---|---|---|---|
| 60 Hz | 1250 / 1.183333 s / 213.402771 px | 1136.363636... / 1.300000 s / 234.098480 px | 1.09859155 (+9.859%) |
| 120 Hz | 1250 / 1.166667 s / 210.364594 px | 1136.363636... / 1.283333 s / 231.097107 px | 1.10000000 (+10.000%) |

Source: tests/airtime_smoke.gd; generated engineering report tmp/airtime-measurement.json. Peak height increases as a physical consequence of lower gravity. New human feedback/iteration outcome remains pending; old human sessions use 1250 and cannot validate this new revision. Do not mix versions in A/B analysis. Historical date/values for the student's earlier trials remain pending even though this current implementation is now verified.

## Variant Comparison - P04 paired evidence and limits

A = checkpoint restart (full Boss encounter); B = campaign restart. Actual filename numbering is **1=Original, 2=Slow, 3=Fast Reload**, except A1's outcomes are **Custom**. Compare complete parameter dictionaries, not names alone. On 2026-10-14 the student confirmed six different players, one per file, all outside class. A later student-attributed export, B1playA1.json, supplies P04's Original-A exposure. P04 now has one verified within-person **B then A** pair with identical parameters. The other original candidate pairs remain between-person only; this is not a six-person paired comparison.

| Candidate files | Outcome snapshots | Same tester / actual exposure order | Recorded A vs B failures; retries | Eligibility / missing evidence |
|---|---|---|---|---|
| [B1playA1.json](telemetry/B1playA1.json) / [B1.json](telemetry/B1.json) | Identical Original | Yes: P04, B then A | 4 vs 2; 3 vs 2 | One within-person pair; unequal exposure, open B run and recent unretried A death limit inference. |
| [A1.json](telemetry/A1.json) / [B1.json](telemetry/B1.json) | Different | No: P01 / P04 | 4 vs 2; 4 vs 2 | Not eligible: Custom vs Original and different people; need clean Original-A and within-person pairing. |
| [A2.json](telemetry/A2.json) / [B2.json](telemetry/B2.json) | Identical | No: P02 / P05 | 2 vs 3; 2 vs 3 | Slow settings match, but different people; descriptive only, not planned Original-only comparison. |
| [A3.json](telemetry/A3.json) / [B3.json](telemetry/B3.json) | Identical | No: P03 / P06 | 8 vs 1; 8 vs 1 | Fast Reload settings match, but different people; descriptive only, not planned Original-only comparison. |

The initial six files have 100% observed retry and <=10 s first-input rates. The new P04 Original-A file has 3/4 (75%) at export, versus 2/2 (100%) in P04 Original-B. The A file was exported about two seconds after its last death, before the ten-second response window ended; treat the remaining response as right-censored, not proof of refusal. Do not read the descriptive -25 percentage-point difference as a settled effect. This is descriptive evidence, not a controlled conclusion. Exposure duration, progress, player experience and sample sizes differ; B1/B2 also have an open final run. The file timestamps order these sessions A1 -> A2 -> A3 -> B1 -> B2 -> B3 across different people. P04 later played A at 17:21:20-17:22:47 EDT after B at 17:05:41-17:06:47; the same-person order is B then A. Alternating orders are a future protocol, not a claim that it happened here. P06's reported perception of no difference has an unspecified referent; it does not establish that P06 played both variants.

Formal planned comparison remains **Original only** with identical snapshots and the same people. B1playA1 supplies clean Original-A outcomes for P04; the old A1 Custom file remains excluded. Additional paired participants, balanced exposure durations and full response windows are needed for stronger inference. Summarize existing observations/feedback only; no additional questionnaire is needed.

| Missing comparison evidence | Status |
|---|---|
| Same-person A/B pairs / order | One: P04, B1 then B1playA1; no paired exports for the other five testers |
| Confirmed participant denominator / outside-class count | Six different people; all six outside class, student-confirmed |
| Clean Original-A outcome records comparable to B1 | B1playA1.json, four completed deaths, identical parameters and version to B1 |
| Existing observations / feedback | Entered in participant log; no quit observation supplied |
| Final design choice / data conclusion | Student chose Keep A; higher retry willingness not established; see paired analysis and final Verdict |

### P04: Original B then Original A

One paired tester, P04, played [B1.json](telemetry/B1.json) (B / Campaign) followed by [B1playA1.json](telemetry/B1playA1.json) (A / Checkpoint). Both are lab-b-0.2 / Original, jump_speed=720, gravity=1250; **all gameplay parameter snapshot fields match**. This pair predates the later lab-b-0.4 gravity adjustment, so it cannot measure that adjustment. Player attribution and feedback are student-confirmed; dates/counts/times are from the unchanged exports.

| Measure | B / Campaign: B1 | A / Checkpoint: B1playA1 | Interpretation |
|---|---:|---:|---|
| Started / completed outcome runs | 3 / 2 | 4 / 4 | B's final open run excluded from completed duration |
| Actual deaths / successful retries | 2 / 2 | 4 / 3 | A's last death has an incomplete response window, not an abandonment |
| Raw retry rate at export | 2/2 = 100% | 3/4 = 75% | Descriptive only; the apparent -25 pp is not evidence of lower willingness |
| First input within 10 s | 2 captured retries | 3 captured retries | All successful retries satisfy the metric; last A response unknown |
| Active completed-duration sum | 59.898 s | 84.564 s | Unequal exposure; death count is not a normalized difficulty measure |
| Mean / median completed duration | 29.949 / 29.949 s | 21.141 / 16.049 s | Different restart locations/progress; not a preference score |
| First-input delay median / range | 0.817 / 0.800-0.833 s | 0.367 / 0.183-0.549 s | A responses were faster in these few observed retries; this suggests faster response, not a proven increase in willingness |
| Input-to-ready median / maximum | 0.001 / 0.001 s | 0.001 / 0.184 s | A includes death-lock waiting; response time is distinct from first-input delay |
| Death-to-ready maximum, successful retries | 0.834 s | 0.550 s | All five successful retries ready within 2 s; this uses explicit ready times, not the 10 s willingness metric |
| Relevant restart evidence | segment_3 death resumes segment_0, score 0 | Two segment_2 deaths resume segment_2, score 400 | Observed behavior agrees with restart-location definitions |
| Student-reported player feedback | Experienced genre player; thought it was good | Less exciting; relaxing led to repeated deaths | A may reduce perceived stakes; a challenge-tuning concern, not a measured population effect |

A's last death is recorded at 17:22:47 EDT, with export at 17:22:49. The roughly two-second follow-up is shorter than the ten-second response window. Its response is **right-censored / not observed yet**; do not classify it as refusal, quitting or abandonment, and do not invent a later retry. Keep the raw 4-death/3-retry count, while declining to interpret the missing response as a negative choice.

**Data conclusion:** the hypothesis “checkpoint respawn makes players more willing to retry” is not established by this pair. P04 retried every death for which a response was observed in both modes; A showed faster first inputs, but no demonstrated higher retry proportion. One player, B-before-A order, unequal exposure and the incomplete final response limit inference. Learning, familiarity, fatigue or checkpoint position could affect the differences; none is measured as the cause. The student's final **Keep A** choice is separate from that conclusion. Numeric Keep/Pivot/Kill thresholds were not set before testing and are not being invented afterward.

## Playtest Log

### Participant log - one row per confirmed person

The student confirmed on 2026-10-14 that these files correspond to **six different human testers, all six outside class**. P01–P06 are anonymous notebook identifiers assigned to the file mapping, not names embedded in JSON. Dates/configuration/counts come from raw telemetry; outside-class status, observations and feedback come from the student's chat replies. Feedback below is a faithful summary of that reply, not a fabricated verbatim quote or extra questionnaire. Each real tester has one row.

| Tester ID | Date | Outside class? | Played configuration | Corresponding JSON | Stuck point / observation | Player feedback | Retry behavior |
|---|---|---|---|---|---|---|---|
| P01 | 2026-10-14 | Yes, student-confirmed | A / Custom; Original initially, then three edits | [A1.json](telemetry/A1.json) | 不熟练操作；遥测记录第四段重型炮塔激光死亡 4 次 | 没有教程 | 4 次失败、4 次重试，首次按键均 <=10 s；完整局 5、行政结束 3 |
| P02 | 2026-10-14 | Yes, student-confirmed | A / Slow | [A2.json](telemetry/A2.json) | 跳跃／地刺是卡点；遥测记录地刺死亡 1 次、敌弹死亡 1 次 | 跳跃滞空不足，地刺太大、跳不过去 | 2 次失败、2 次重试，首次按键均 <=10 s；完整局 3 |
| P03 | 2026-10-14 | Yes, student-confirmed | A / Fast Reload | [A3.json](telemetry/A3.json) | 不熟练操作；遥测包含普通关卡及 Boss 死亡 | 内容过多，感觉 overwhelming | 8 次失败、8 次重试，首次按键均 <=10 s；完整局 9 |
| P04 | 2026-10-14 | Yes, student-confirmed | B / Original then A / Original | [B1.json](telemetry/B1.json), [B1playA1.json](telemetry/B1playA1.json) | 类似游戏的熟练玩家；A 模式下因放松而连续死亡 | B：觉得很好；A：不够刺激，但放松后容易连续死亡 | B: 2/2 retries, 2 complete and 1 open run; A: 3/4 retries at export, 4 complete deaths, final response window incomplete |
| P05 | 2026-10-14 | Yes, student-confirmed | B / Slow | [B2.json](telemetry/B2.json) | 地刺问题；遥测记录第一段地刺死亡 3 次 | 仍是地刺问题；其他反馈未记录 | 3 次失败、3 次重试，首次按键均 <=10 s；完整局 3，最后 1 局未结束 |
| P06 | 2026-10-14 | Yes, student-confirmed | B / Fast Reload | [B3.json](telemetry/B3.json) | 具体卡点未记录；遥测记录敌弹死亡 1 次 | 认为没什么区别；比较对象未明确 | 1 次失败、1 次重试，首次按键 <=10 s；完整局 2 |

### Verified session evidence - not participant rows

JSON schema 2 / version lab-b-0.2; seven distinct session IDs from six student-confirmed people. B1playA1 is a second exposure for P04, not a seventh tester. Dates/times below are **2026-10-14 America/New_York (EDT, UTC-04:00)**, converted from UTC JSON timestamps. Range is first through last recorded event, not active gameplay duration; export time comes from exported_at, not filesystem metadata.

| JSON | First-last event (EDT) | Export (EDT) | Actual configuration | Started runs | Complete outcome runs | Administrative ends | Open runs | Deaths | Victories | Successful retries / deaths |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---|
| [A1.json](telemetry/A1.json) | 16:58:27-17:00:03 | 17:00:06 | A / Custom (Original initially; three edits) | 8 | 5 | 3 | 0 | 4 | 1 | 4/4 (100%) |
| [A2.json](telemetry/A2.json) | 17:00:49-17:02:33 | 17:02:35 | A / Slow | 3 | 3 | 0 | 0 | 2 | 1 | 2/2 (100%) |
| [A3.json](telemetry/A3.json) | 17:02:56-17:05:19 | 17:05:21 | A / Fast Reload | 9 | 9 | 0 | 0 | 8 | 1 | 8/8 (100%) |
| [B1.json](telemetry/B1.json) | 17:05:41-17:06:47 | 17:06:48 | B / Original | 3 | 2 | 0 | 1 | 2 | 0 | 2/2 (100%) |
| [B2.json](telemetry/B2.json) | 17:07:14-17:07:45 | 17:07:46 | B / Slow | 4 | 3 | 0 | 1 | 3 | 0 | 3/3 (100%) |
| [B3.json](telemetry/B3.json) | 17:08:15-17:09:40 | 17:09:41 | B / Fast Reload | 2 | 2 | 0 | 0 | 1 | 1 | 1/1 (100%) |
| [B1playA1.json](telemetry/B1playA1.json) | 17:21:20-17:22:47 | 17:22:49 | A / Original (P04) | 4 | 4 | 0 | 0 | 4 | 0 | 3/4 (75% at export; last death response window incomplete) |

Complete outcome = run_end with failure=true or cause=victory. Administrative endings are counted separately and excluded from outcome-duration statistics. B1 and B2 each have an unfinished final run: no invented run_end/duration, and both are excluded from completed-time calculations. A1's first three endings are administrative parameter changes; its five completed outcomes are Custom. The other five files retain their named snapshots. No raw events have been changed.

| JSON | Complete outcome n | Total active duration (s) | Mean (s) | Median (s) | Complete score_delta range |
|---|---:|---:|---:|---:|---|
| [A1.json](telemetry/A1.json) | 5 | 86.180 | 17.236 | 2.367 | 0-3000 |
| [A2.json](telemetry/A2.json) | 3 | 92.280 | 30.760 | 7.400 | 100-3400 |
| [A3.json](telemetry/A3.json) | 9 | 127.920 | 14.213 | 7.833 | 0-2000 |
| [B1.json](telemetry/B1.json) | 2 | 59.898 | 29.949 | 29.949 | 200-1200 |
| [B2.json](telemetry/B2.json) | 3 | 20.599 | 6.866 | 6.916 | 100-100 |
| [B3.json](telemetry/B3.json) | 2 | 79.297 | 39.649 | 39.649 | 200-3800 |
| [B1playA1.json](telemetry/B1playA1.json) | 4 | 84.564 | 21.141 | 16.049 | 300-600 |

Scores are per-run gains (score_delta), not comparable cumulative checkpoint totals. Mean/median include both deaths and victories; checkpoint resumes and unequal progress alter attempt lengths. These descriptive numbers cannot by themselves isolate restart preference.

### Recorded obstacles and configuration details

These are **event-derived facts**, not invented observations or statements by the player. Segment indices are zero-based: segment_3 means the fourth authored segment.

| JSON | Recorded causes of death | Failure checkpoint(s) | Actual snapshot / restart evidence |
|---|---|---|---|
| [A1.json](telemetry/A1.json) | HEAVY TURRET LASER x4 | segment_3 x4 | guard_delay 0.7 vs 0.75; piercer_cadence 0.51 vs 0.52; reload_multiplier 0.99 vs 1.0. All four retries return to segment_3, score 700. |
| [A2.json](telemetry/A2.json) | HOSTILE FIRE x1; GROUND SPIKES // UNBLOCKABLE x1 | segment_0 x2 | Only scroll_multiplier=1.275 differs from Original. Both retries return to segment_0. |
| [A3.json](telemetry/A3.json) | HOSTILE FIRE x5; TURRET COLLISION x1; GROUND SPIKES // UNBLOCKABLE x1; BOSS HIGH PARTICLE x1 | segment_0 x6; segment_2 x1; boss x1 | Only reload_multiplier=0.8 differs from Original. Includes segment_2 checkpoint retry and full Boss restart. |
| [B1.json](telemetry/B1.json) | HOSTILE FIRE x1; HEAVY TURRET LASER x1 | segment_0 x1; segment_3 x1 | Original snapshot. segment_3 death retries at segment_0 with score 0; final run open. |
| [B2.json](telemetry/B2.json) | GROUND SPIKES // UNBLOCKABLE x3 | segment_0 x3 | Only scroll_multiplier=1.275 differs from Original. All retries at campaign entry; final run open. |
| [B3.json](telemetry/B3.json) | HOSTILE FIRE x1 | segment_0 x1 | Only reload_multiplier=0.8 differs from Original. One segment_0 death and campaign-entry retry; later victory. |
| [B1playA1.json](telemetry/B1playA1.json) | GROUND SPIKES // UNBLOCKABLE x1; HOSTILE FIRE x2; TURRET COLLISION x1 | segment_0 x1; segment_2 x2; segment_3 x1 | Original; identical full snapshot to B1. Two recorded retries return to segment_2 with entry score 400. Last death not retried before export. |

### Retry timing - willingness and game response are separate

failure_to_input_seconds measures death to first retry input (including player waiting). input_to_restart_seconds measures first input to ready gameplay. failure_to_restart_seconds measures the entire death-to-ready interval. Each counts successfully retried failed_run_id once; denominators below are actual failures, not people. Rounding is only for display; raw JSON retains full values. Telemetry captures the first input and does not establish the total number of keys physically pressed.

| JSON | First-input delay min / median / max (s) | Input-to-ready median / max (s) | Death-to-ready max (s) | First input <=10 s / deaths | Ready <=2 s after input / retries | Ready <=2 s after death / retries |
|---|---|---|---:|---|---|---|
| [A1.json](telemetry/A1.json) | 0.100 / 0.600 / 0.750 | 0.001 / 0.267 | 0.751 | 4/4 | 4/4 | 4/4 |
| [A2.json](telemetry/A2.json) | 0.483 / 3.558 / 6.634 | 0.000 / 0.000 | 6.634 | 2/2 | 2/2 | 1/2 |
| [A3.json](telemetry/A3.json) | 0.033 / 0.450 / 7.667 | 0.002 / 0.333 | 7.668 | 8/8 | 8/8 | 7/8 |
| [B1.json](telemetry/B1.json) | 0.800 / 0.817 / 0.833 | 0.001 / 0.001 | 0.834 | 2/2 | 2/2 | 2/2 |
| [B2.json](telemetry/B2.json) | 0.466 / 0.467 / 0.650 | 0.001 / 0.001 | 0.651 | 3/3 | 3/3 | 3/3 |
| [B3.json](telemetry/B3.json) | 0.467 / 0.467 / 0.467 | 0.001 / 0.001 | 0.468 | 1/1 | 1/1 | 1/1 |
| [B1playA1.json](telemetry/B1playA1.json) | 0.183 / 0.367 / 0.549 | 0.001 / 0.184 | 0.550 | 3/4 at export | 3/3 | 3/3 |

Across all seven exports: **23/23 successful retries have input-to-ready <=2 s (maximum 0.333 s)**; **21/23 have death-to-ready <=2 s**. A2 has one 6.634 s death-to-ready interval and A3 one 7.668 s interval, primarily before first input (6.634 and 7.667 s). Do not use the initial six files' 20/20 first-input-within-10-s result as evidence of a death-to-ready-under-2-s requirement. The separate input-to-ready fields provide response-time evidence for the recorded attempts only. A3's 0.033 s input waited 0.333 s to restart; this animation wait is not player hesitation.

Participant mapping, outside-class status and existing observations/feedback are now student-confirmed above: six distinct people and six outside class. JSON alone would not establish those facts. Historical iteration values/reasons/effects remain partially missing; the final student design decision is recorded below. One same-person Original A/B comparison is recorded for P04, with the exposure and censoring limits above; player-level experience differs between records. No extra questionnaire or invented observation has been added.

## Verdict

**Keep: retain A / Checkpoint respawn.** This is my final design choice, confirmed on 2026-10-14, rather than a claim that A won the experiment. The question was whether checkpoint respawn makes players more willing to retry, and my hypothesis was yes. No numeric Keep/Pivot/Kill thresholds were established before testing. I will not retroactively invent thresholds, declare that one was met, or portray this post-test decision as a completed pre-test Prototype Card.

The directly paired evidence is one tester, P04: [B1.json](telemetry/B1.json) followed by [B1playA1.json](telemetry/B1playA1.json). Both used Original parameters in lab-b-0.2, with jump strength 720 and gravity 1250; their complete parameter dictionaries match. B recorded two deaths and two retries, while A recorded four deaths and three retries. B also contains an open final run, which is excluded from completed-duration statistics. A's last death occurred about two seconds before export, so its retry response had not received the full ten-second observation window. That missing response is not evidence of abandonment. The raw export-time rates, 100% for B and 75% for A, must therefore not be treated as a settled advantage for B or a failure of A.

Among captured responses, P04's median death-to-first-input delay was approximately 0.817 seconds in B and 0.367 seconds in A. That is a real descriptive difference suggesting faster response in the A exposure. It does not show a higher probability of choosing to retry: P04 continued after every death for which a response was actually observed in either mode. All five successful retries returned to play within two seconds of death, using the recorded ready-time fields. Input-to-ready delay is a separate measure, at most 0.001 seconds in B and 0.184 seconds in A; it should not be confused with the player's waiting before pressing a key. The ten-second first-input metric is not proof of a two-second restart requirement.

Accordingly, the data do **not establish** the hypothesis that checkpoints increase willingness to retry. There is only one paired participant, always B before A, with unequal exposure and different progress/restart locations. Mean completed duration was 29.949 seconds in B versus 21.141 in A, and A had more deaths, but these counts and durations cannot isolate preference or difficulty. Familiarity, order and checkpoint position could contribute; their effects were not independently measured. The other five testers' records and feedback do not enlarge the within-person paired sample, and the old Custom A1 file is excluded from this Original comparison.

P04's feedback gives a useful design tension. This experienced player thought B was good, but described A as less exciting and said relaxing led to repeated deaths. I choose to keep checkpoint recovery despite the uncertain willingness result, while treating the reduced excitement as a concrete problem for the next stage. This is a design commitment, not a manufactured endorsement by the data. The later lab-b-0.4 gravity change is also outside these human records; its engineering airtime measurements cannot substitute for player feedback about the new build.

**Lab C's first step is to keep A and continue tuning challenge intensity in response to “not exciting enough.”** Preserve the checkpoint rule while evaluating a single challenge parameter at a time, with other settings held constant. Define numeric decision criteria before the next measured comparison, use matched exposures and balanced A/B orders if B is retained for evaluation, and allow the full retry-response window before export. This keeps the chosen recovery structure while testing whether challenge can regain tension without mistaking repeated deaths for unwillingness or declaring a winner from one person's incomplete record.
