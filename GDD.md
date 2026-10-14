# EverFront — GDD

## Source status

Lab A source received on **2026-10-14** from `E:/bledderfile for helss/desktop/GENAI_03/w4`. The original one-page visual GDD is [LabA_Zhu_GDD.pdf](design_sources/LabA_Zhu_GDD.pdf), **THE FRONT NEVER STOPS**, William Zhu, Version 3.0, document date **September 20, 2026**. It was read in full and its rendered page inspected. Original bytes and source hashes are retained in design_sources/README.md. Receipt date is not the document's creation date or a new design decision.

Supporting originals: [Lab A evaluation](design_sources/LabA_Zhu_Evaluation.docx), [Lab A brainstorm log](design_sources/LabA_Zhu_Log.docx) (document date September 18, 2026), and [W5 debt/explainability journal](design_sources/Debt_Explainability_Journal_W5_revised.docx) (recorded September 22, 2026). These are preserved unchanged. The journal is not rewritten. Their historical claims are attributed to the supplied sources; none is converted into invented Lab B testing evidence.

**Week 4 production-rep GDD and sprint plan found** in Downloads on 2026-10-14: [W4_Zhu_Submission.pdf](design_sources/W4_Zhu_Submission.pdf), 23 pages, cover “The Front Never Stops — Week 4 Production Rep | Full GDD and Two Week Sprint Plan”, William Zhu, September 27, 2026. The same project title/author, Week 4 clue, complete GDD and two-week plan identify the project material requested as Assignment 3 / Rep 3. Its cover uses “Agentic AI for Game Production”; it does not explicitly print “Assignment 3” or “590.03”, so those labels are not presented as a literal document heading. This discovery supersedes the earlier source-missing status, rather than renaming the Lab A source.

Companion [W4_Zhu_Journal.pdf](design_sources/W4_Zhu_Journal.pdf), three pages, identifies the same project/GDD production rep and contains the student's explainability answers and translated reflections. Both PDFs are copied unchanged from `C:/Users/lenovo/Downloads`; hashes are in design_sources/README.md. The original full GDD, complete plan, review and prompt archive remain available in the source PDF; the reconciled summary below does not replace or rewrite those originals. Current implementation claims continue to follow actual code and evidence. Reference assignment: `Lab_B_Playable_Prototype (Final).pdf`, read previously on 2026-10-04.

## Lab A design — source-preserving summary

### Concept, intent and audience

The original pitch is a one-hit-death 2D auto-scrolling run-and-gun with a horizontally anchored player who reads incoming patterns, chooses weapons to break armor, and balances survival against a higher kill score. It reinvents Contra by removing horizontal navigation: the player cannot cautiously stop or retreat, while the world and independently moving enemies approach. Jumping/crouching, multidirectional shooting, weapon choice, lethal mistakes, pattern learning and stage progression preserve the recognizable core.

The target player enjoys precision aiming, pattern learning and short high-stakes runs. The planned platform was PC with keyboard/mouse or controller. Planned session length was 6–8 minutes, using 6–8 segments of 30–45 seconds. These are **original targets, not observed session lengths or promises about today's build**.

### Main actions and loop

The functional diagram keeps the player in a fixed horizontal zone, with jump/crouch movement; terrain scrolls left, ground enemies move at independent speed, and flying enemies can exit and return. Controls include jump/crouch, mouse/right-stick aim, fire, swap, reload and guard. Pressure comes from track hazards, bullets, enemy speeds and reload timing.

1. Game sends a pattern of hazards and enemy paths.
2. Player reads and defends through jump, crouch and guard.
3. Player aims and attacks through weapon swaps, armor breaking and weak-point hits.
4. Game resolves score/checkpoint progress and advances to a harder pattern.

### Weapons, armor and failure

The source defines an Assault Rifle with medium penetration/balanced fire, an AP Rifle with high penetration/slower fire, and a pickup-only grenade. Two permanent weapon slots plus the temporary pickup are planned.

| Original rule | Source intent |
|---|---|
| Unarmored target | Any bullet or stomp kills in one hit |
| Light armor | One shot breaks armor, next kills; stomp kills immediately |
| Heavy armor | Assault Rifle ricochets; AP breaks armor, next hit kills; stomp only slides the enemy |
| Weak point | One precise hit bypasses either armor level and kills immediately |
| Loss | One unguarded hit or an unblockable hazard |
| Win | Clear the planned 6–8 segments and defeat Boss |
| Score | More enemy kills yield a higher final score |

### Boss, scope and presentation

The source Boss encounter stays on a straight horizontal 2D track. “Looping” refers to recurring hand-authored track modules, not a circular on-screen track. Player and Boss stay relatively stable while hazards/usable objects move right to left. Reduced projectile density and track hazards are intended to support readability. Boss death restarts the full encounter. Proposed damage routes are direct shots, triggering passing track objects, then armor break followed by exposed weak-point attack. Passing-object interaction is an original proposal, **not claimed here to exist in current code**.

Original small-team scope: one stage, four enemy types, three weapons, two permanent slots and one Boss. Presentation intent: military sci-fi pixel art, modern lighting and clear silhouettes; chiptune/electronic drums and distinct ricochet, armor-break, reload, guard-break and death cues. These are design targets, not proof that all assets or audio were delivered.

The PDF discloses ChatGPT assistance with layout/wording and two labeled OpenAI ImageGen mood references dated September 20, 2026; the game-space illustration is a functional diagram. It attributes design decisions to William Zhu and states that no original Contra assets were reused. These statements describe the source document. Full runtime asset origin/license verification is still pending; the source's art intent does not establish licenses for every current sprite.

### Selection rationale and historical AI work

The evaluation source compares The Front Never Stops, The Screen Is the Weapon and Death Echo using preservation of Contra's core, structural change, understandable rules, feasible prototype scope and repeated-play support. The student selected The Front Never Stops for its clear rule and direct pacing/readability test, overriding the AI's preference for Death Echo because echo recording, collision and enemy-attention rules enlarged scope. The source groups twenty concepts into about eight clusters. This is historical concept selection, not the Lab B Keep verdict.

The September 18 log records two ideation passes with GPT 5.6 Sol: one uses anti-reference constraints/design levers, the other preserves Contra's identity. The September 22 journal records ChatGPT Pro 5.6 for one-page GDD structure/wording/brainstorming, student review and revisions, and about three hours for that task. This is a supplied historical estimate, **not elapsed time invented for current Codex work**.

## Week 4 / requested Rep 3 — historical full GDD

Source pages 1–7: scaffold and eleven GDD sections; document owner/human-review date September 27, 2026. The scaffold was AI-proposed and selected by William, not represented as independently student-authored. It evolves the existing playable **four-stage campaign plus Boss**, superseding the earlier Lab A 6–8-segment target for this production plan.

| W4 design area | Historical source specification / boundary |
|---|---|
| Concept and experience | Fixed horizontal position, pattern learning, lethal errors, readable warning/action/result; use each retry to improve |
| Core loop | Read warnings; jump/slide/stomp/shield; aim/shoot/swap/reload; resolve armor/score/death; advance or checkpoint retry |
| Controls and shield | Bindings were to be copied from build. Reported shield use about 1.5 s, recharge delay 0.75 s, exhaustion lockout about 0.5 s; explicitly not proven balance targets |
| Spike rule | Body contact is lethal; frontal shield collision can destroy a spike first. Retaining shield clearance was a human-approved decision, not a presumed bug |
| Weapons | AR magazine 24 / penetration 1; AP magazine 5 / penetration 3; unlimited reserve with reload. Grenade slot/effect reported present but no obtainable pickups in the baseline |
| Armor details | Light turret damaged then destroyed; heavy rejects AR, AP removes armor before a finishing hit. Old Lab A universal armor/stomp rules were not assumed verified |
| Boss | Reported four health and two armor layers; after armor breaks, weak point stays exposed. Ground bombs prompt jump, high particles prompt crouch; full encounter reset. Existing-parameter balance considered, no new phases/regenerating armor |
| Progression | Stage 1 light turrets/spikes; 2 laser gates; 3 repeated turrets/gates; 4 combined threats; then Boss. Stages 5/6 defined but inactive |
| Sprint content | Scene grenade pickup integration, shield/checkpoint checks, shareable build, essential audio, unfamiliar-player test; Boss tuning optional |
| Presentation | Three parallax layers, combat/player animations, HUD/reticle/score effects. Audio streams not reported configured; essential audio and provenance were tasks, not delivered results |
| Technology / risks | Engine/version/build metadata not confirmed in the W4 report. Reset/collision errors, redundant grenade use, scope/ownership and untested readability were observable risks |
| Success / cuts | Preserve runnable campaign and consistent resets; observe explainable responses to repeated threats. Defer Boss tuning first; further cuts require human decisions |

Historical human decisions on source page 10: retain shield spike clearance to avoid frustrating progression blocks; add scene-only grenade collection for more room for action; balance the existing Boss; use flexible sessions rather than rigid daily quotas; defer Boss tuning first; arrange an unfamiliar tester. Capacity/dates were confirmed; exact grenade capacity, Boss effect and checkpoint pickup/inventory reset (D1) remained unresolved, and Boss tuning choice (D2) could be deferred. Source plans are not automatic instructions to implement those features now.

### Two-week sprint plan — reproduced as a plan, not completion evidence

Source pages 8–9: **September 28–October 11, 2026**, owned by William Zhu. Planned Week 1: T1–T7; Week 2: T8–T11. Human-confirmed minimum capacity **20 hours**, without a fixed daily maximum or two-hour quota. **16 estimated task hours + 4 shared reserve hours (20%)**. The source explicitly labels task estimates **UNSOURCED**; they are not actual recorded work times. Shared reserve is available at any task, not only at the end. Each task should fit within two workdays; that is a sizing rule, not a daily hours limit.

| Task | Planned estimate | Dependency | Original acceptance / deliverable |
|---|---:|---|---|
| T1 Baseline and rules | 1.5 h | None | Run campaign/checkpoint/Boss reset; record engine/version/build steps; verify existing grenade effect; resolve D1; arrange tester or record unconfirmed slot |
| T2 Shield verification | 1 h | T1 | Check bullets, shield-front/body spike contact, gates and depleted energy; list reproducible mismatches separately |
| T3 Pickup and activation | 1.5 h | T1; D1 resolved | Scene pickups connect to existing grenade action; no automatic respawn supply; verify collection/use |
| T4 Inventory and reset | 1.5 h | T3; D1 resolved | Functional HUD count, selected capacity, checkpoint inventory/pickup policy, no duplicate collection |
| T5 Shareable build | 1 h | T2–T4 | Package/run outside editor, verify launch/restart, record commands and artifact path |
| T6 Essential audio | 2.5 h | T1; checked assets | Locate files and provenance, then wire fire/reload/armor-break/death audio; report missing assets before integration |
| T7 Boss baseline / optional tuning | 1 h | T4; D1 Boss effect resolved | Record armor-break/exposed timing; compare any retained small parameter change; tuning is first deferral |
| T8 External playtest | 2 h | T5; tester confirmed | Observe unfamiliar player's responses/deaths/confusion/grenade use/Boss exposure; do not claim unreached content tested |
| T9 Priority repairs | 2 h | T2/T8 findings | Fix highest-impact reproducible issue within budget; list remaining work, split/re-estimate if needed |
| T10 Final build / regression | 1 h | T9; retained changes | Package/check four stages, Boss victory, checkpoint death, Boss reset and fresh campaign; record build ID/failures |
| T11 GDD / evidence update | 1 h | T8–T10 | Match GDD to actual build; save observations/timings/known issues/scope changes |
| Shared contingency | 4 h | Available throughout | Use when blocked, record use and revise remaining estimates; not a completed task or actual spent time |

T3/T4 separate activation from reset work; T5 supplies T8's build; T6 is not a mandatory serial dependency for Boss or testing. If grenade foundations are missing, re-estimate rather than label new development as integration. The AI-proposed observation protocol checks death explanations and repeated-pattern responses; its two-hour budget includes setup/notes, not compulsory two-hour player exposure. If a tester cannot reach Boss, preserve the result and disclose missing coverage instead of inventing it or adding an unplanned level select.

### Review provenance and historical limits

Source pages 10–13 and appendix: GPT-6 Astra draft/assembly and Doubao 2.1 review are disclosed. The human retained flexible capacity and chose Boss tuning as first cut; AI revised split tasks, explicit packaging and shared reserve. The hypothetical three-month-late postmortem in the review is **a scenario, not an actual delay or proof of missing code**. The original prompt/review setup qualifications remain visible in the PDF. The companion Journal reports its own task time as two hours; neither that nor the sprint estimates is substituted for current BUILD_LOG timings. It is retained without rewriting student answers.

### W4 plan versus current checked project

| Historical item | Current implementation / evidence boundary |
|---|---|
| Four stages, two firearms, shield, full Boss reset | Existing baseline preserved; A checkpoint and B campaign modes now coexist. Keep A is the later Lab B decision, not a September W4 claim |
| Shield can destroy spike before lethal body collision | main.gd checks the guard hitbox first, removes a hit spike and consumes energy; lethal body contact remains separate. This supports the W4 rule without adding code |
| Grenade scene pickups and inventory/reset integration | Grenade action/collection code exists; current active game_data timeline has no pickup event. Planned normal acquisition/capacity/reset completion is not claimed |
| Boss exposed-phase concern / optional balancing | Existing Boss retained; exact completion of T7 or its historical change is not established by this source alone |
| Engine/version/build metadata unknown in W4 | Now verified Godot 4.7.2, native single-threaded Web export and Duke workflow; historical metadata gap can be filled with current facts, not backdated |
| Shareable build / tests / evidence | Later Web exports, engineering checks and seven human sessions are documented in BUILD_LOG/PROTOTYPE; they do not prove T1–T11 were performed on the September schedule |
| Audio / source permissions | Historical audio task and runtime asset provenance remain unverified here; no TODO removed without source or delivery evidence |
| Physics / lab question | Later lab-b-0.4 gravity=1250/1.1 and Keep A are separate authorized Lab B changes; old human snapshots and W4 design are preserved |

## Original Lab A plan versus current prototype

| Area | Lab A plan | Verified current scope / evidence boundary |
|---|---|---|
| Navigation | Horizontally anchored player; jump/crouch and threat reading | Preserved; current crouch includes slide behavior |
| Progression | 6–8 segments, 6–8-minute target | Four active segments then Boss; six timeline definitions. Old target not silently replaced with a measured result |
| Weapons | AR, AP Rifle, pickup grenade | Rifle/piercer and existing temporary grenade behavior; active pickup availability follows actual campaign code |
| Boss | Full encounter restart; usable track-object proposal | Full encounter reset in A; B restarts campaign. Usable-object proposal not independently confirmed |
| Retry | Section failure cost; full Boss reset | Lab B compares checkpoint A and campaign B; final student choice is Keep A |
| Presentation/audio | Pixel-art/readability and specified sound direction | Existing art preserved; missing delivery/provenance details remain pending |
| Physics | No numeric gravity/jump requirement in supplied visual GDD | Current lab-b-0.4 uses jump 720, gravity 1250/1.1; older human exports retain 1250 |

## Existing implementation

2D side-view automatic scrolling action shooter. The player stays at a fixed horizontal position, jumps and slides, aims with the mouse/right stick, fires two weapons, guards, reloads and changes weapons. Ground spikes, laser gates and turrets create threats. Four authored segments lead to a Boss encounter; two additional defined segments currently remain inactive. One unblocked hit causes death. R / Space / Fire retries the segment checkpoint, or the whole Boss encounter. Victory displays final score and allows redeployment.

The rifle and piercer have finite magazines with infinite reserve. The piercer breaks heavy armor and Boss armor. Existing score, ammo, guard-energy and Boss-health feedback remain. Existing pixel art and animations remain; their authorship/license provenance must be supplied by the student if absent. No new art is needed for Lab B. The README's older six-segment/grenade notes describe authored data rather than the current active campaign.

## Remaining source gaps

| Item | Student content |
|---|---|
| Lab A concept and design intent | Supplied in original PDF and evaluation; summarized above |
| Target player and intended experience | Supplied in PDF sidebar |
| Original core action and loop | Supplied in diagram/callouts; summarized above |
| Requested Rep 3 / W4 full GDD | Supplied: W4_Zhu_Submission.pdf, pages 1–7; archived unchanged. Cover does not print the numeric assignment/course code |
| Rep 3 / W4 planned scope, sprint and changes | Supplied: source pages 8–13 plus archive; historical plan, not proof of completion |
| Asset origin / license | PDF disclosure supplied; full runtime sprite/audio provenance still pending |

## Lab B scope

Authorized revision on 2026-10-14: retain jump_speed=720, set default gravity=1250/1.1. Ideal ground-to-ground airtime targets 110% of the historical baseline; actual fixed-step measurements are documented in PROTOTYPE.md. Lower gravity also increases peak height. Historical human exports remain 1250-gravity evidence and are not retroactively changed. Numeric verdict thresholds remain pending.

Preserve the existing loop. Question: does checkpoint respawn make players more willing to retry? Hypothesis: yes. A restores the current segment/full Boss entry; B restores campaign entry. The static start screen chooses A/B and Original / Slow / Fast Reload, default A + Original. The final student choice is **Keep A**, separate from the limited P04 paired evidence, which does not establish increased willingness. Numeric thresholds were not set before testing and are not backfilled; see PROTOTYPE.md. Do not add story, unlocks, meta-progression, new levels or juice effects. Cosmetic particle toggle affects existing decoration only; hostile Boss projectiles remain visible. Lab A and W4 production-rep sources are now preserved; missing runtime provenance, historical implementation results or dates remain pending.
