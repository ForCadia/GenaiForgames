# Lab B submission audit — 2026-10-14

This bundle is a technical submission draft, **not a claim that all assignment evidence is complete**. Deadline supplied by the student: October 14, 2026, 23:59; course timezone must be confirmed.

| Requirement | Evidence / status |
|---|---|
| Public browser game | https://people.duke.edu/~wz204/everfront/ — English build uploaded earlier today; student previously verified browser play. Current audit rebuild remains local until explicitly deployed. |
| Repository | https://github.com/ForCadia/GenaiForgames — local audit commits may be newer than remote; source ZIP includes hidden .git. |
| Core action, failure, score | Jump/slide/aim/fire/guard; one unblocked hit; HUD score and checkpoint/Boss progress. |
| Single-key retry | R / Space / Fire; buffered during existing 0.35 s death lock. |
| Tuning | 13 effective numerical controls plus existing particle toggle, F1 panel, defaults reset. |
| A/B | A checkpoint/full Boss encounter; B campaign entry. F2/F3 and panel retain weapon keys 1/2/3. |
| JSON | T/button download, local session archives; durations, score, cause/location, retries, mode/snapshot and raw switches. |
| Four documents | AGENTS.md, GDD.md, PROTOTYPE.md, BUILD_LOG.md supplied. Content completeness below. |
| Real telemetry | **TODO: no real JSON in telemetry/**. Engineering tests cannot replace it. |
| Completed pre-test Card | **TODO** thresholds; existing Git commits contain placeholders, not a complete pre-test Card. First external test date and separate evidence unknown. |
| Three real loops | **TODO** measured results/dates/decisions; three single-variable plans exist. |
| Variant comparison | **TODO** same testers in A/B, actual results and order records. |
| Six testers / two outside class | **TODO** anonymous IDs, dates, course membership and observations. |
| Verdict, about one page | **TODO** student's evidence-based Keep/Pivot/Kill and first Lab C change; last section stays pending. |
| Lab A / Rep 3 | Lab A PDF and supporting originals received from student and archived in design_sources/; GDD.md summarizes original design and current scope separately. **TODO: Rep 3 GDD/sprint plan**, not identified in supplied directory. |
| Video, 60–90 seconds | **TODO** recording/file/link. |
| Development history | Existing actual log preserved; unprovided work/timings remain TODO. |

## Submission files

Run `python tools/package_lab_b.py` after updates to create a new independent directory under `tmp/lab-b-submission-20261014` (a suffix is used if it exists). It contains the four documents, README, this checklist, deployable `web/`, `web.zip`, `EverFront-project-with-git.zip`, `telemetry/`, engineering logs and a hash manifest. Generated assets/temp/template downloads are excluded from the source ZIP; install matching templates or fetch Web templates as documented in AGENTS.md. The current working copy is preserved, including the student's pending edits; manifest records its status. Never put automated JSON into telemetry/.

## Testing and deployment

For parameter loops use A and Original before each single change: Slow (scroll 1.5 to 1.275), Fast Reload (reload multiplier 1 to 0.8), then manual jump 720 to 755.14 with gravity 1250. Actual results are not yet supplied. Formal A/B uses Original only, identical snapshots and the same people; alternate A→B and B→A. Keep the panel closed during actual play. Export before selecting New tester.

The existing Duke upload script uploads, **does not build**. Re-export first, then run `./deploy_duke.ps1` when deployment is authorized and Z: is connected. Do not delete the source or other hosted directories. Local preview: `./start_web.ps1`; do not use file://. After deployment use Ctrl+F5/private window and test six selections, Start/Return, weapon keys, ordinary/Boss retry and actual JSON download. HTTP/hash checks do not prove interactive behavior.

Video suggestion (student recording required): show Start and selected combination, core action/score, failure and one-key retry, A/B change, F1 parameters and T download in 60–90 seconds. Do not present engineering events as real playtest outcomes.

## Evidence still required from the student

Provide thresholds and any real pre-test commit; tester identities as anonymous codes plus in/out-of-course status; actual loop and A/B notes; real export paths; Lab A/Rep 3; omitted development history/timings; video; final judgment and Lab C action. The student replied “keep existing” during this audit, confirming existing design rather than supplying these missing results. No missing fact has been filled by inference.
