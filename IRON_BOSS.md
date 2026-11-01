# IRON BASTION prototype

Status: source and assets implemented for user playtesting; no engine run, import, export, smoke test or capture was performed.

## Entry and scope

Boss test selector now includes IRON BASTION alongside Eye and Gunblade. Separate IronBoss.tscn, iron_boss.gd and iron_boss_data.gd. Retry/replay retain selection; no new campaign/endless replacement. No mixed regular enemies. Reuses the existing warning, safe empty running track, camera focus, audio, grenade and victory/retry systems. Historical LAB and telemetry remain unchanged.

## Modular rules

- Main Boss HP24 represents core health.
- Main cannon8HP, six-port launcher8HP and cover6HP are separate pools; damaging those does not reduce core HP.
- Cover is positioned DIRECTLY OVER the existing left-side red core, covering it until destroyed. Its eight source poses show progressive breakage; final pose is the empty frame.
- Cannon, launcher and cover use existing AP threshold3. Exposed core uses existing light threshold1. No core damage multiplier.
- Weapons can be destroyed independently of the cover. Their attacks stop immediately, and four-frame destruction leaves persistent wreckage without hurtboxes.
- Core is accessible as soon as its cover is gone; destroying both weapons first is optional. Core destruction ends the whole encounter.
- Inert hull armor ricochets. Source-pixel weapon contacts ignore transparent padding and bright flash pixels. Front hull does not swallow cover/core shots. One round has one shared Boss target ID so it cannot damage multiple modules from the same crossing.
- Grenade retains current Boss rule: clears every hostile round and deals1 direct core HP, bypassing the cover; no damage to module armor.

## Attacks

Cycle: prepare -> cannon firing -> recovery -> prepare -> launcher firing -> recovery. Destroyed weapon is skipped; if both are destroyed, there are no further shots.

Cannon preserves the user-authored up-left35-degree pose. Ballistic launch speed solves for a locked, slightly dispersed player-ground landing point using gravity580. Launch comes from the cannon muzzle; the fixed launch angle follows artwork. Shell falls and explodes on the track; landing marker is visible during flight. Cannons animate ready/fire/smoke/recover over0.40s.

Launcher fires six individually spawned missiles, spaced0.16s, from separately authored port anchors. Each locks a dispersed target lane at launch; no pursuit. Flying missiles were removed from firing artwork using imagegen so they do not remain attached to the launcher. Directional missile geometry/tails are drawn by code.

Projectile and explosion hits resolve swept paths against player/guard, with one consumed contact per projectile; standard shield handling remains in main. Death, title/reset, pause and grenade cleanup include all Iron projectiles.

## Configuration and presentation

iron_boss_data.gd centralizes HP, armor mapping, mounts, core/cover/body boxes, scales, attack intervals, projectile gravity/speed/radius and port anchors. Simple/normal/hard downtime API matches mechanical Boss interface, while test entry currently uses normal. No campaign or Endless injection in this first pass.

Original art is retained in assets/boss_iron. Runtime hull is an imagegen transparent cutout; raw hull_source.png preserved. Per-frame mount coordinates compensate the supplied atlases' shifting layout. UI shows core HP plus cannon/missile/cover HP. Source inspection is not proof of in-game alignment; user will test.


Boss audio follow-up2026-11-01: new user Downloads sword_fire01, fire-3-rpg and cannon-shot are converted into boss_melee_sword.wav, iron_missile_fire.wav and iron_cannon_fire.wav. Gunblade slash/thrust emit the sword cue once on execution-state entry, never during warning or every frame. Iron cannon uses the first cannon report only (source0.12..5.1s; second report excluded), launcher one RPG cue per pair of missiles. Leading silence trimmed, PCM conversion preattenuated8dB to avoid clipping, active-segment RMS measured offline and calibrated through audio_mix.gd; missile target gets3dB extra overlap headroom. Existing SFX bus/settings/limiter/pause/title cleanup remain. Source manifest assets/sfx/boss_new_audio.source.json records files, trim and gains. No game/import/tests or runtime audition.


Iron layout correction from user annotated hull: hull scale0.45 (formerly0.25), home x670, roof mortar mount(-40,-390) behind hull at z-1, central-wall launcher mount(8,-286) at z1, core cover mount(-127,-157) at z2. Uniform cover scale0.37 replaces unequal0.20/0.30 stretch; full red core column is covered. Core/cover/hull collision boxes recalibrated to the enlarged art, and sprite-space muzzle anchors follow the new transforms automatically. Approximate body spans x370..969, highest cannon y98, track y632 on960x720 canvas. Faster entrance fits the intro window; Iron focus uses whole-fortress center and1.05zoom to avoid cropping the enlarged assembly. No runtime tests.
