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

Initial playback gains in weapon_audio.gd are -8 dB for firing, -6 dB for reload and -4 dB for switching. These are integration settings pending student listening, not an approved final mix. Tool/source licensing, generation prompts, plan tiers, production times and stage ratings have not been supplied and are not inferred from filenames. These five clips do not by themselves fulfill the assignment's six-sound requirement.
