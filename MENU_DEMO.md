# Title-screen live gameplay demo

The title background now runs the real `main.tscn`, including the authored three missions, actual Player scene, spawns, turrets, laser gates, spikes, projectiles, collisions, armor, reloads, shields, Boss encounters and death/retry behavior. `ui/menu_demo.gd` only chooses controls and aims; it no longer creates cosmetic enemies or rounds or applies its own damage rules.

The live game is inside a separate SubViewport/World2D. The outer menu remains paused and interactive. AI actions use a per-instance input dictionary; user keyboard/mouse/gamepad input never enters the background run. Starting the player's game removes the background instance immediately.

Background HUD/overlays are hidden for menu readability. On actual death the normal death animation/camera finishes before an automated retry; on actual victory the bot continues to the next mission, looping after mission three. All timers and combat parameters are the normal defaults, with no invulnerability, damage multiplier, timeline skip or fabricated outcomes.

The background profile is memory-only and does not load the real wallet/upgrades. Telemetry stays disabled; leaderboard reading/writing is bypassed for the background instance. It shares the outer settings object without creating another audio/display settings manager. Background music/SFX players are silent so only the title BGM plays; normal gameplay audio paths are unchanged.

Validation: real-render menu capture; tests/menu_demo_smoke.gd (fixed-fps 60) verifies the actual main scene, distinct World2D, ignored global input, running timers/shots, paused outer menu, memory-only profile and cleanup on Start. A separate 400-second engineering run exercised natural stage progression and a Boss encounter. Existing start_modes, progression, settings and ground_spikes smokes passed. Exit-only ObjectDB cleanup warnings remain in some existing smoke runs. No real save or tester telemetry was used.
