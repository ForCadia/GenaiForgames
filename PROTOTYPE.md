# Lab B — Prototype notebook

Deadline: **2026-10-14 23:59**, course submission timezone to confirm. Telemetry must work before the **October 8** classroom playtest swap. This notebook contains scaffolding, not completed playtest evidence.

## Prototype Card — pending student decisions

**Complete and commit this section before the first external playtest.** A committed blank template does not meet the assignment requirement. Confirm its commit hash below before recruiting testers.

| Field | Student entry |
|---|---|
| One focused verb | Pending |
| Question | Pending |
| Hypothesis | Pending |
| Single tested mechanism / parameter | Pending |
| Variant A value | Pending |
| Variant B value | Pending |
| Primary observation metric and denominator | Pending |
| Secondary metrics | Pending |
| Rapid-retry time window | Pending; HUD currently reports <=10 s |
| Keep threshold | Pending |
| Pivot threshold | Pending |
| Kill threshold | Pending |
| Test order / sampling plan | Pending |
| Completed card commit hash / date | Pending |

Candidate questions for student selection: jump strength versus spike failure / first-segment completion / rapid retry; guard drain versus guard-related failure / survival / rapid retry; rifle cadence versus first-segment completion / score / rapid retry. These are suggestions, not selected decisions. If a metric is not directly logged, specify how it will be observed or add its event before testing.

## Measurement definitions

- A run starts on deployment or checkpoint retry; checkpoint transitions within an attempt do not start a new run. A run ends on death, victory, administrative reset or session change.
- Gameplay duration counts active simulation seconds, excluding panel pauses. JSON timestamps are UTC; retry latency uses monotonic wall-clock time.
- Retry rate = failed runs followed by a gameplay retry / all failed runs in the tester session. Fast retry rate = those retries within 10 seconds / all failed runs. A recently failed run still awaiting retry is in the denominator; export at the end of the observation window. UI edits and tester resets do not count as retries.
- Median duration uses death/victory runs only. Administrative endings are retained in JSON but excluded. HUD runs is the number started, including administrative runs; use filtered completed runs for comparison.
- This is a **run-based** rate. To report how many **people** retry, aggregate one row per session/tester and specify the person-level denominator; do not call the run percentage a participant percentage.
- Failure x/y is the player's logical position at death; segment and Boss flag locate the encounter. Panel changes end the current attempt and restart from campaign start to avoid mixed parameters. Snapshots include all panel values.

## Loop Log

Use a different set of testers each round. Each measured loop changes one variable. The rows below are empty slots and do not yet count as three completed loops.

| Loop / date | One parameter: before -> after | Why | Test sessions / JSON | Metric before -> after / sample size | Observed result |
|---|---|---|---|---|---|
| 1 / pending | | | | | |
| 2 / pending | | | | | |
| 3 / pending | | | | | |

## Variant Comparison

Implementation pending the student's selected mechanism and A/B values. Do not present the current `baseline_pending` as an A/B result. Keys 1/2 are existing weapon slots; use alternative unused keys or explicit buttons once approved. Safe switching must end the current run with `variant_switch`, record the old/new variant and restart both versions from the same initial state. Other panel values, timeline and conditions must match.

| Item | Entry |
|---|---|
| Mechanism / A value / B value | Pending |
| All held-constant parameters | Pending |
| Same testers try A and B; counterbalanced order | Pending |
| Sessions / runs per variant / excluded administrative runs | |
| Primary metric A / B / absolute difference | |
| Which won, by how much, uncertainty | |
| Corresponding JSON and observations | |

## Playtest Log

At least six actual testers, at least two outside the course. Slots below are not claimed participants. Use pseudonyms / tester IDs; avoid unnecessary personal information. Each tester starts a new session. Export before handing over to the next tester, and copy the file into `telemetry/`.

Protocol: hand over link with one sentence of context; do not explain controls. Watch silently for three minutes. Note confusion, retries and quits. Ask one question: **“What were you trying to do?”** The same tester tries both variants; new testers are used in later rounds. State variant exposure/order and session IDs.

| Tester ID | In course? (>=2 outside required) | Date / round / A-B order | Observation / stuck location | Confusion / answer | Retry / quit behavior | Session ID / JSON file |
|---|---|---|---|---|---|---|
| Pending 1 | | | | | | |
| Pending 2 | | | | | | |
| Pending 3 | | | | | | |
| Pending 4 | | | | | | |
| Pending 5 | | | | | | |
| Pending 6 | | | | | | |

## Verdict

**Pending real evidence and student judgment.** Write approximately one page after testing. State Keep / Pivot / Kill, compare measured numbers to the precommitted thresholds, cite sample sizes and actual JSON files, connect observations to the metrics, discuss contradictory evidence and limitations, and specify the first change for Lab C. A supported Pivot or Kill earns the same credit as Keep. Do not insert an AI-generated conclusion without real data. Keep this section last.
