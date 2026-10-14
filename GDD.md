# EverFront — GDD

## Source status

2026-10-14 audit: required project documents exist; no Lab A / Rep 3 source was supplied during this audit. Preserve this inventory and pending entries until the student supplies original material. The public game UI now uses English labels, with unchanged mechanics.

Lab A concept and Rep 3 GDD/sprint plan: **pending student input**. The following is an inventory of the existing demo, not a reconstruction of the original design. Reference assignment: desktop `Lab_B_Playable_Prototype (Final).pdf`, six pages, read 2026-10-04.

## Existing implementation

2D side-view automatic scrolling action shooter. The player stays at a fixed horizontal position, jumps and slides, aims with the mouse/right stick, fires two weapons, guards, reloads and changes weapons. Ground spikes, laser gates and turrets create threats. Four authored segments lead to a Boss encounter; two additional defined segments currently remain inactive. One unblocked hit causes death. R / Space / Fire retries the segment checkpoint, or the whole Boss encounter. Victory displays final score and allows redeployment.

The rifle and piercer have finite magazines with infinite reserve. The piercer breaks heavy armor and Boss armor. Existing score, ammo, guard-energy and Boss-health feedback remain. Existing pixel art and animations remain; their authorship/license provenance must be supplied by the student if absent. No new art is needed for Lab B. The README's older six-segment/grenade notes describe authored data rather than the current active campaign.

## Lab A / Rep 3 material to supply

| Item | Student content |
|---|---|
| Lab A concept and design intent | Pending |
| Target player and intended experience | Pending |
| Original core action and loop | Pending |
| Rep 3 GDD in full | Pending |
| Rep 3 planned scope, sprint and changes | Pending |
| Asset origin / license | Pending |

## Lab B scope

Preserve the existing loop. The student confirmed the experiment: whether players retry after one-hit death, and whether checkpoint versus campaign restart changes willingness. Hypothesis: checkpoint restart encourages more continued attempts. A restores the current segment/full Boss entry; B restores campaign entry. The static start screen chooses A/B and Original / Slow / Fast Reload, default A + Original. These parameter modes prepare experiments and do not constitute test results. Keep / Pivot / Kill thresholds and evidence are pending; refer to PROTOTYPE.md. Do not add story, unlocks, meta-progression, new levels or juice effects. Cosmetic particle toggle affects only existing decorative particles; hostile Boss projectiles are gameplay objects and remain visible. Original Lab A / Rep 3 material remains missing.
