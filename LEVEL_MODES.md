# Three missions and endless mode — 2026-10-31

The main menu's START GAME button opens SELECT MISSION. All three missions and ENDLESS MODE are available immediately. Back/Esc returns to the title. Opening the selector does not start a run; selecting a mission starts it with the existing held-input gate.

| Mode | Content |
|---|---|
| Level 01 — Frontline | Existing four stages and Boss, with original event data retained |
| Level 02 — Signal Breach | Four new timelines: Signal Jam, Low Clearance, Crossfire, Relay Breach; laser walls and staggered turret pressure; cooler background tint |
| Level 03 — Iron Citadel | Four new timelines: Armored Column, Laser Corridor, Siege Platform, Final Approach; heavy turret and mixed-hazard encounters; warmer background tint |
| Endless | Survive repeating authored patterns; a Boss every fifth wave; normal-wave event spacing gradually reaches a 30% reduction cap; no final victory state |

New missions reuse the existing environment, music, enemies, Boss and attacks. They are new encounter arrangements, not new map artwork or Boss assets. Movement, firearms, grenade behavior and Boss health remain the existing authored defaults. Each regular stage and Boss encounter supplies a grenade opportunity. HUD identifies the mission or wave and retains the four-stage-plus-Boss progress blocks.

Ordinary mission deaths retry the selected mission's checkpoint and restore checkpoint resources. A campaign reset restarts that selected mission. Victory offers NEXT MISSION where available, REDEPLOY for the same mission, or Return to Title. Selecting another mission or starting a new run clears score/time/inventory for that run.

Endless carries score and grenades between waves. Clearing a Boss awards its score, holds a one-second protected transition, then starts the next wave. Death records score and wave and retries from wave one with fresh resources. No endless checkpoint farming or repeated victory dialog occurs. Records are separate per mission and for endless, and the old Level 01 best-score key is retained. Record saving loads the existing ConfigFile before changing keys so other records survive. Results are captured when the run ends even if retry input was already buffered.

Development and Boss-test entry points always use Level 01; new missions/endless do not enable telemetry or modify retained developer sessions. Existing historical tester JSON is unchanged. `campaign_data.gd` owns the new timelines and endless spacing rule; `game_data.gd` remains the baseline.

The UI gallery includes LevelSelect, Level2, Level3 and Endless pages. `tests/campaign_modes_smoke.gd` covers timeline ordering, selection, checkpoint identity, the fifth-wave Boss, sixth-wave continuation, fresh endless retries and developer isolation. Godot editor script import, campaign_modes_smoke and start_modes_smoke passed. The existing start-mode suite reported a non-fatal ObjectDB shutdown cleanup warning; no script/assertion failures occurred. Gameplay balancing and full runs remain for the user's manual testing. No package was rebuilt.
