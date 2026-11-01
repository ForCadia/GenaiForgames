# Sound list and production record

Attention priority: lethal warning and player state before enemy decoration, reward cues and music. F10 toggles global mute; Settings retains separate Master Music SFX levels. No HUD volume control was added.

All rows use the same five stages: Codex assisted spotting; user source selection; documented conversion/editing; native state-based implementation; offline calibration plus pending listening. Exact source licenses and plans are per ASSET_LOG.csv, not assumed from integration.

| File under assets/sfx | Trigger | Editing and behavior | Evidence |
|---|---|---|---|
| rifle_fire.wav | Rifle successful shot | original speed; polyphony cap | SFX.md |
| rifle_reload.mp3 | Rifle reload starts | pitch scales to actual reload duration | SFX.md |
| piercer_fire.wav | Piercer successful shot | original speed | SFX.md |
| piercer_reload.wav | Piercer reload starts | pitch scales to reload duration | SFX.md |
| weapon_switch.wav | Successful weapon switch | no cue for same selected slot | SFX.md |
| armor_ricochet.wav | Insufficient penetration | event based; calibrated gain | SFX.md |
| shield_open.wav | Guard becomes active | single sustained voice; stops on release/death | SFX.md |
| item_pickup.wav | Grenade pickup | one shot at collection | SFX.md |
| coin_pickup.wav | Coin collection | native cue; anti stacking behavior | UI_SFX.md |
| light_turret_fire.wav | Enemy actual firing | same state that emits round | SFX.md |
| heavy_turret_charge.wav | Heavy/eye attack preparation | scales to warning duration; interrupt cleanup | SFX.md |
| heavy_turret_fire.wav | Heavy laser active or eye shot | actual execution | SFX.md |
| laser_gate_hover.wav | Living laser wall on screen | shared ambience voice | SFX.md |
| enemy_explode.wav | Enemy destruction | retain appropriate tail on death | SFX.md |
| boss_bomb_countdown.wav | Eye bomb planted | scaled countdown then stop | SFX.md |
| boss_bomb_explode.wav | Bomb or shell detonation | native one shot | SFX.md |
| boss_melee_sword.wav | Gunblade slash or stab execution | leading silence trim; once per action | assets/sfx/boss_new_audio.source.json |
| iron_cannon_fire.wav | Iron mortar round emitted | first source cannon report only | assets/sfx/boss_new_audio.source.json |
| ui_click.wav | Button down | trimmed immediate onset | UI_SFX.md |
| ui_error.wav | Button rejection | separate rejection cue | UI_SFX.md |

At least six effects are present in source. That is not a claim that each originated with an AI waveform generator: the documented AI work includes spotting, matching, edits and implementation assistance. The unused iron_missile_fire.wav is retained as a rejected/replaced asset and has no current firing trigger. Bus gains are in audio_mix.gd, and the Master limiter ceiling is-1dB. Two browser unlock, pause, repeat and mute checks remain unperformed in this audit until permission/evidence is supplied.
