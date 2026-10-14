# EverFront — GDD

## Source status

Lab A source received on **2026-10-14** from `E:/bledderfile for helss/desktop/GENAI_03/w4`. The original one-page visual GDD is [LabA_Zhu_GDD.pdf](design_sources/LabA_Zhu_GDD.pdf), **THE FRONT NEVER STOPS**, William Zhu, Version 3.0, document date **September 20, 2026**. It was read in full and its rendered page inspected. Original bytes and source hashes are retained in design_sources/README.md. Receipt date is not the document's creation date or a new design decision.

Supporting originals: [Lab A evaluation](design_sources/LabA_Zhu_Evaluation.docx), [Lab A brainstorm log](design_sources/LabA_Zhu_Log.docx) (document date September 18, 2026), and [W5 debt/explainability journal](design_sources/Debt_Explainability_Journal_W5_revised.docx) (recorded September 22, 2026). These are preserved unchanged. The journal is not rewritten. Their historical claims are attributed to the supplied sources; none is converted into invented Lab B testing evidence.

**Rep 3 GDD / sprint plan remains missing.** No file in the supplied directory is identified as Rep 3 or contains a Rep 3 sprint plan. Evaluation “Part 3” is concept clustering, not Rep 3. Supply the separate Rep 3 material or confirm which existing source is intended to serve that role; do not silently rename Lab A as Rep 3. The existing demo inventory below remains the basis for current implementation claims. Reference assignment: `Lab_B_Playable_Prototype (Final).pdf`, read previously on 2026-10-04.

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

## Original plan versus current prototype

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
| Rep 3 GDD in full | Pending |
| Rep 3 planned scope, sprint and changes | Pending |
| Asset origin / license | PDF disclosure supplied; full runtime sprite/audio provenance still pending |

## Lab B scope

Authorized revision on 2026-10-14: retain jump_speed=720, set default gravity=1250/1.1. Ideal ground-to-ground airtime targets 110% of the historical baseline; actual fixed-step measurements are documented in PROTOTYPE.md. Lower gravity also increases peak height. Historical human exports remain 1250-gravity evidence and are not retroactively changed. Numeric verdict thresholds remain pending.

Preserve the existing loop. Question: does checkpoint respawn make players more willing to retry? Hypothesis: yes. A restores the current segment/full Boss entry; B restores campaign entry. The static start screen chooses A/B and Original / Slow / Fast Reload, default A + Original. The final student choice is **Keep A**, separate from the limited P04 paired evidence, which does not establish increased willingness. Numeric thresholds were not set before testing and are not backfilled; see PROTOTYPE.md. Do not add story, unlocks, meta-progression, new levels or juice effects. Cosmetic particle toggle affects existing decoration only; hostile Boss projectiles remain visible. Lab A sources are now preserved; Rep 3 source remains pending.
