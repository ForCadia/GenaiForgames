# Weapon sound integration

The student supplied five files in Downloads and authorized integration on 2026-10-30, with reload clips proportionally sped up to match gameplay and firing sounds left at their original speed. Source files are copied unchanged; playback speed is adjusted at runtime.

| Source file | Project file | Trigger | Original duration |
|---|---|---|---:|
| lightgunfire.wav | assets/sfx/rifle_fire.wav | Successful rifle shot | 0.2525 s |
| lightrelaid.mp3 | assets/sfx/rifle_reload.mp3 | Rifle reload starts | 3.6843 s |
| heavyfire.wav | assets/sfx/piercer_fire.wav | Successful piercer shot | 1.1980 s |
| heavygunreload.wav | assets/sfx/piercer_reload.wav | Piercer reload starts | 5.5762 s |
| switchweapon.wav | assets/sfx/weapon_switch.wav | Successful change of selected weapon slot | 0.1792 s |

Reload playback speed is source duration / actual reload duration. Original mode uses approximately 3.0703x for the rifle (1.2 s) and 3.0979x for the piercer (1.8 s). Fast Reload and custom reload multipliers automatically use their actual durations. Godot pitch_scale changes pitch along with speed; this is not pitch-preserving time stretching. Gameplay timings are unchanged.

Firing retains 1x speed with up to six overlapping voices per weapon. Failed shots, full-magazine reload requests and selecting an already active slot do not play new sounds. Weapon audio pauses with the tuning panel, and clears on death, reset, victory or return to the menu. The existing M key mutes the Master bus, including both music and effects.

Initial playback gains in weapon_audio.gd are -8 dB for firing, -6 dB for reload and -4 dB for switching. These are integration settings pending student listening, not an approved final mix. Tool/source licensing, generation prompts, plan tiers, production times and stage ratings have not been supplied and are not inferred from filenames.

## Enemy and environment effects

On 2026-10-30 the student supplied eight additional files and confirmed the ambiguous mappings: droneeffect for the flying laser wall, explode for enemies, bombexpode for Boss bombs, and the countdown for planted Boss bombs.

| Source file | Project file under assets/sfx | Trigger | Source duration |
|---|---|---|---:|
| lightturretfire.aiff | light_turret_fire.wav | Light turret actually fires | 1.3764 s |
| heavyturrentfire.wav | heavy_turret_fire.wav | Heavy turret laser becomes active | 2.0014 s |
| heavyturrnet_prepare to fire.wav | heavy_turret_charge.wav | Heavy turret starts charging | 0.8364 s |
| claimitem.wav | item_pickup.wav | Existing grenade pickup is collected | 1.0800 s |
| droneeffect.wav | laser_gate_hover.wav | At least one living laser wall is on screen | 30.6909 s |
| explode.wav | enemy_explode.wav | Turret, laser wall or Boss explodes | 1.5791 s |
| bombexpode.wav | boss_bomb_explode.wav | Boss bomb starts exploding | 3.1310 s |
| 138108__snakebarney__bomb-countdown-beeps.aiff | boss_bomb_countdown.wav | Boss bomb lands | 2.0437 s |

AIFF files were converted from big-endian PCM to WAV without resampling or changing source bit depth/channels. Other WAV files are copied unchanged. The two fire clips and explosions retain original speed. Charge audio scales to the warning interval, accounting for the turret's travel to its firing position. Bomb countdown scales to ground_hold_time + explosion_warning_time (0.9 s with current defaults), stopping when the bomb explodes or is removed. No gameplay timers were changed.

Multiple laser walls share one looping ambience voice, raised from -20 dB to -10 dB after student feedback that it was too quiet. The ambience stops when none remain alive on screen. Boss bomb countdown and explosion gains are raised from -8 dB to -2 dB. Other enemy effects remain at -8 dB; pickup is -4 dB. Effects pause with the tuning panel. Death stops ambience and warnings while allowing already-triggered explosions to finish; resetting or returning to the menu clears all effects. M controls all sound. Pickup audio only hooks the existing collection branch; this change does not add pickup spawns or new mechanics.

The Boss's high particle attack reuses heavy_turret_charge.wav during its telegraph and heavy_turret_fire.wav on actual firing, both at -2 dB. Charge playback scales to the telegraph duration and stops if armor break, death or a reset interrupts the attack. Firing retains original speed. Boss music is lowered separately to -17 dB to leave these cues clearer.

The additional Downloads file opensheild.wav is copied unchanged to assets/sfx/shield_open.wav. It plays once when guarding becomes active, at -6 dB and original speed, rather than repeating every frame while the guard button is held.

There are now 14 supplied effect assets integrated across the existing triggers. This count is not evidence that all Lab C sourcing, editing, AI trials, mixing, licensing and two-browser acceptance steps are complete. Those records and listening acceptance remain separate.
