# Boss armor and shield balance — 2026-10-31

Current normal play, Development-profile play, name/Guest play, Boss test and the real-game menu background use the new combat values. Historical LAB tuning retains its original shield parameters and one-AP-hit-per-plate Boss behavior; tester telemetry is untouched.

## Boss armor

- Two physical layers, 18 armor points each, 36 total, shown as a separate cyan bar above red health.
- Rifle penetration 1 ricochets and removes no armor. Piercer penetration 3 removes 3 armor per hit: six hits per layer, twelve in total.
- Partial armor damage does not interrupt the attack cycle. Exhausting a layer plays the existing armor-break transition and preserves the other layer's remaining 18 points; the bar never refills between layers.
- Only after both layers break do normal shots damage the weak point's existing 24 red health. Grenades retain their one-point direct red-health damage without removing armor.

## Shield

| Value | Before | Now |
| --- | --- | --- |
| Sustained drain | 66.67/s | 100.005/s (1.5×) |
| Per blocked impact | 7 | 18 |
| Unupgraded regeneration | 12.5/s | 6.25/s |
| Base recharge delay | 0.75s | 1.25s |
| Fast-regen capstone | 50/s | 25/s |

Intermediate regeneration bonuses are also halved, to 3.125/s and 6.25/s. Existing capacity, drain-reduction and kill-energy upgrades remain. Automatic shield requires at least one impact's 18 energy. Reaching zero immediately disables blocking and enters the existing break lock, so another hit that frame is not free. Ground-spike blocking still works, including when the successful block exhausts the last energy.

Values are centralized in combat_balance.gd; game_data.gd and lab-panel defaults remain the historical baseline. Build-tree text reflects the current effective regeneration.

Validation: Boss actor and integrated Boss checks cover twelve-hit armor break, rifle ricochet, layer transitions, attacks, grenades and HUD values. Combat-balance smoke verifies shield rates, break lock and LAB isolation. Progression, start-mode, ground-spike and player-profile checks passed. Real-render screenshot inspected the 27/36 armor bar above full red health. Some smoke runs retain exit-only ObjectDB cleanup warnings. This is engineering validation, not a human balance verdict.

Armor-driven appearance: outer/inner idle damage frames now follow armor thresholds (75%/25%), with the existing cracked-to-detached frames played at 50% and 0% before changing form. Attack animations remain intact; armor amount, AP damage and red-health logic are unchanged. boss_smoke verifies cracked and detached frame IDs for both layers.
