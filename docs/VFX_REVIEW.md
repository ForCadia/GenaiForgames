# VFX acceptance scope

Three required moments share the native cosmetic particle renderer but have separate triggers and visual roles:

| Moment | Actual implementation | Toggle |
|---|---|---|
| Hit | white/amber sparks at resolved contact point, including Boss shot contact | Settings Hit Pickup and Failure Particles |
| Pickup | cyan/amber burst at actual coin/grenade collection | same |
| Failure | red40particle burst at player center before complete death animation | same |

Switching this option off suppresses particle creation and rendering in normal play. Existing LAB particle control remains authoritative for its historical experiment, and the new normal preference does not change old telemetry. Gameplay projectiles, attack areas, Boss telegraphs and shield logic remain enabled. Reduced Flash separately controls bright screen flashes. This separation keeps effect comparison from changing combat difficulty. Native shader/atlas Boss effects are additional effects, not all controlled by this switch.

Evidence is source inspection of main.gd _emit/_die/pickup paths and saved setting registration. No new runtime comparison was performed.
