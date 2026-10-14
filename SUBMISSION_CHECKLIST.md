# Final Lab B submission checklist - 2026-10-14

This bundle contains current materials, not a claim that every requirement passed. Nothing is uploaded to Canvas by the packaging process. Deadline supplied by the student is October 14, 2026, 23:59; course timezone should be confirmed.

| Requirement | Current evidence / status |
|---|---|
| Public game | https://people.duke.edu/~wz204/everfront/ - lab-b-0.4 re-exported/deployed; public HTML/JS/WASM/PCK returned 200 and matched local hashes |
| Private-window interaction | **PENDING HUMAN CONFIRMATION**: gameplay, one-key retry and actual JSON download. Browser control could not initialize; video filename/frames are not substituted for confirmation |
| Repository / source ZIP | https://github.com/ForCadia/GenaiForgames; seven human exports were explicitly authorized and pushed. Local latest documentation may be newer. Final source ZIP includes hidden .git and current working-copy source; manifest records commit and pending configuration/generated-file differences |
| Core loop / retry | Existing shooter, one-hit failure, score/progress; R/Space/Fire buffered retry. Relevant engineering checks recorded; not a new browser validation |
| Tuning / A-B | 13 numerical controls plus particle toggle. A checkpoint/full Boss, B campaign; F2/F3 preserve weapon keys |
| Current gravity | 1250/1.1, jump strength 720. All named modes share it; fixed-step engineering airtime results in PROTOTYPE. Historical human JSON remains unchanged with gravity 1250 |
| Four root documents | AGENTS.md, GDD.md, PROTOTYPE.md, BUILD_LOG.md present and current |
| Seven human JSON | A1/A2/A3/B1/B2/B3/B1playA1 copied unchanged from Downloads. Hashes and archive entries verified; no automated data substituted |
| Tester log | Six different human testers, all outside class, student-confirmed; one row each, real provided feedback and references |
| Paired comparison | P04 B1 then B1playA1, Original/full parameters equal; n=1 paired. Final A death response window incomplete, not abandonment. Evidence does not establish higher willingness |
| Prototype Card timing | Numeric thresholds were not set before testing; timing gap disclosed. No retroactive threshold or pre-test commit invented |
| Three iterations | Higher-speed and higher-jump trials reverted after developer disliked feel, no quantified results. Historical values/dates remain pending. Retained current airtime change has engineering evidence, not new human validation |
| Verdict | About one page, last section. Student chooses Keep A independently of limited data; Lab C keeps A and tunes challenge intensity |
| Lab A / W4 sources | Original design PDFs/DOCX and full W4 GDD/sprint plan copied unchanged under design_sources/. Historical estimates/plans are not represented as completed work |
| Video | User-selected Desktop EverFront InPrivate recording. **99.31 seconds: OUTSIDE 60-90 second requirement, 9.31 s over maximum.** Full audio/video decode exit 0, no errors with original time-base passthrough; inspected frames show the game. Copied unchanged as EverFront-demo.mp4; no trimming performed |
| Asset provenance | Original document disclosure retained; full runtime sprite/audio license evidence remains pending |
| Canvas | Not uploaded or submitted |

## Bundle contents and validation

Final output is a fresh directory under tmp/lab-b-final-20261014 (suffix if needed), separate from source. It contains EverFront-project-with-git.zip; standalone PROTOTYPE.md and BUILD_LOG.md; AGENTS/GDD/README/checklist; original video copied as EverFront-demo.mp4; design_sources/; telemetry/ with seven originals; web/ and web.zip; VIDEO_VALIDATION.json; MANIFEST.json; GAME_LINK.txt. Source ZIP includes current tracked working-copy files, original Git history, design_sources and telemetry. Generated build folders, temporary tools/export templates and .godot are excluded; install/import matching Godot as AGENTS documents. Git history may include old generated files, preserved as history.

Validation reopens ZIP, tests CRC, checks hidden .git/HEAD and config, documents and source, compares every JSON and design original, verifies standalone copies, hashes every output and ensures Verdict is final. Video copy hash must match Desktop original. Engineering artifacts remain labeled and separate from human telemetry. Metadata/decoding do not constitute the user-confirmed browser/download checklist.

## Still required / not claimed complete

1. A compliant 60-90 second video: supplied video is 99.31 seconds. Student may replace/re-record; packaging does not edit it.
2. User confirmation of latest incognito gameplay, retry and JSON download.
3. Historical exact values/dates for the first two reverted trials and unprovided development timings. Developer reasons already supplied; no new tests required to document those reasons.
4. Any missing runtime asset provenance/license evidence.
5. Pre-test threshold timing deficiency remains disclosed; it cannot be repaired by backdating. One paired tester and the incomplete final response limit conclusions, not a missing invented result.

## Canvas game link

https://people.duke.edu/~wz204/everfront/

Upload the standalone PROTOTYPE.md, BUILD_LOG.md and compliant video as requested by Canvas, plus source ZIP or repository link and real JSON evidence. The video presently supplied is retained but marked noncompliant. No Canvas submission is made automatically.
