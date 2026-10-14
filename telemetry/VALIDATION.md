# Human export validation - 2026-10-14

Source: C:/Users/lenovo/Downloads/A1.json through B3.json. The student explicitly confirmed these are human-played records in chat. Tester count, anonymous identities, course membership and exposure pairing remain unconfirmed. Files are copied byte-for-byte, not relabeled or synthesized. No tester_type was added to raw JSON; this document records the student-reported provenance. No uploads performed.

All six parse as schema 2, lab-b-0.2, with distinct session IDs and required raw event fields. Actual deaths and successful retries, excluding administrative ends:

| File | Actual mode | Deaths | Retries | Input within 10 seconds | Victory | Open run at export |
|---|---|---:|---:|---:|---:|---:|
| A1.json | A / Custom after three edits | 4 | 4 | 4 | 1 | 0 |
| A2.json | A / Slow | 2 | 2 | 2 | 1 | 0 |
| A3.json | A / Fast Reload | 8 | 8 | 8 | 1 | 0 |
| B1.json | B / Original | 2 | 2 | 2 | 0 | 1 |
| B2.json | B / Slow | 3 | 3 | 3 | 0 | 1 |
| B3.json | B / Fast Reload | 1 | 1 | 1 | 1 | 0 |

Important limits:
- Actual 2=Slow and 3=Fast Reload, opposite the previously requested labels. Retain original filenames; analyze actual snapshots, not suffixes.
- A1's failed runs use guard_delay=0.7 (default 0.75), piercer_cadence=0.51 (default 0.52), reload_multiplier=0.99 (default 1.0). It is not a valid Original-A comparison to B1. Its initial Original run ended administratively, not in death.
- Every recorded death was retried, including within 10 seconds. Observed rates are 100% for these exported sessions; this does not demonstrate equal population willingness or participant counts. First-input delays range 0.033 to 7.667 seconds. Three requests occurred during the death lock; ready time is separately recorded.
- A1 has four segment_3 -> segment_3 retries. A3 has segment_2 -> segment_2 and boss -> boss retries. B1 has segment_3 -> segment_0 with score zero. B Boss-death reset is not exercised in these exports.
- B1/B2 have an unfinished final run. Exclude it from completed-duration/death statistics, do not invent run_end.
- These sessions cannot by themselves establish three chronological one-variable iterations, same-person A/B exposure or six people including two outside class. Participant mapping, existing observations/feedback and completed pre-test Card evidence remain required; no additional questionnaire is requested. Derived session statistics and timing definitions are in PROTOTYPE.md.

Original byte hashes:

| File | SHA256 |
|---|---|
| A1.json | 56181288455b4b79854755635a2df7f74df2020b5d5cd0cc7d47d4d1179c5352 |
| A2.json | 01348aacfcfa17285895a2591218904def2d3f432285e4015381d8b2898ab568 |
| A3.json | 94c582af86d80a0e9533d721248351e7e807429db9ff8add35e5e871dc2bd41f |
| B1.json | c6fb5bad5314fbc5af2fe3b00ea91d7941a637c1d7a46cbdcd84b01cb49a2cd8 |
| B2.json | 2a4410a62b0c407d97b2100339e1390d05230f157e2a1416662a13a7a31f3e8b |
| B3.json | c77e271360a9b8c7071ac1a8052b9c5b66b92fa5a6436be64fecfc9ec31f684c |
