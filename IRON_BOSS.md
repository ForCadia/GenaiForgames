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


Iron correction2026-11-01: user clarifies do NOT shrink mortar; keep scale0.36 and shift mount right to(25,-390). Main cannon uses individual source regions/anchors, including firing frame x700..1536 to retain leftward flash beyond the nominal grid; muzzle uses matching frame source coordinates. Former rocket module now deploys1 aerial rifleman and1 kamikaze per cycle,0.55s apart, capped at3 live air supports. Destroying its8HP module stops deployment; existing air enemy physics, hit/guard/kill/grenade behavior reused. Spawn API supports optional explicit origin, normal campaign spawn defaults unchanged. Rifleman can orbit forward of the bay with per-instance anchor; Boss death removes summoned actors and their rounds. Mortar shell and explosion now use user neon-effects atlas sprites instead of placeholder circles, black background keyed only on Iron own draw material. Existing source art and HP unchanged. No game/import/tests.


Iron simplification2026-11-01: shift home x670->790 so rear hull intentionally extends offscreen. Remove visible rocket/hangar and front core-cover sprites and their hit regions; retained source files are unused/hidden, core exposed immediately. Air deployment remains independent of a destructible hangar; same cap/roster. HUD now shows cannon HP and exposed core, no phantom cover/hangar HP. Replace broad hull rectangle with source-alpha collision; front core lane remains unobstructed. Summoned flyers draw at z6 in front of Boss z4; before shot resolution collect active flyer body boxes and yield Boss collision for forward aim rays intersecting these foreground enemies, preventing hull from consuming their rounds. Normal campaign targets unaffected. No engine/tests.


Iron reverse/pixel atlas update2026-11-01: user adds Downloads reversing hull8-frame sheet; original saved as reverse_source.png. Built-in imagegen repacks hull8 and cannon4 into isolated transparent pixel atlases; all12 measured source regions have zero opaque pixels along2px border. Hull loops10fps with fixed per-frame track baseline/chassis anchor; cannon ready/fire/smoke/recover uses matching fixed base anchors. Scale recalibration retains approx600px hull width and prior cannon footprint rather than shrinking when source images shrink. Sprite-local pixel shader gives consistent ~2.25world-pixel grain and nearest sampling, no color grading/hue/brightness changes; warm bone-white/charcoal/red palette retained. Source metadata/core anchor and firing muzzle recalibrated; source-alpha collision follows current atlas frame, preserving foreground flyer priority. Death cannon retains original atlas with matching pixel sampling. No game/import/export/tests. See assets/boss_iron/animation_repack.source.md.


Latest user artwork replacement2026-11-01: use supplied four-frame pixel mortar-v2 and four-frame fortress reverse atlases directly, copied unchanged as cannon_pixel_user_v2.png/reverse_pixel_user_4.png. Both loop/frame counts now derive from loaded arrays (hull4, cannon4). Cannon source rows split at actual transparent gutter y532 rather than512, preventing base bleed; all8 source frame borders have0 opaque pixels. Recomputed frame base/core anchors and muzzle positions. Hull retains600px approximate width; mortar base footprint grows from about168px to235px (about40% larger), mount lowered into rear roof to keep muzzle flash onscreen, still behind hull. Wreck scale follows enlarged live cannon. User hues/brightness retained; no imagegen transformation of these supplied replacements. No runtime tests.


Iron motion/layer follow-up2026-11-01: lower the assembled Boss18px via root ground offset (player track/ballistic landing ground remain unchanged). Shared four-frame chassis bounce0/-2/+1/-1px and measured roof-height deltas drive cannon mounting every hull tick, including idle/intro and wreck; barrel firing animation remains separate. Remove the arbitrary prepare-circle drawn over the cannon. Shell/explosion atlas rendering moves to a dedicated world Node2D at rear-cannon layer z-1, drawn above cannon but behind hull, so effects no longer paint through front armor. Actual muzzle, core/hull contact and intro focus follow assembly transforms; no HP/timing or palette changes. No game/import/tests.


Iron destruction simplification2026-11-01: stop using cannon/hangar destruction flipbooks. Destroyed cannon hides and triggers3 staggered cosmetic atlas bursts; Boss death freezes hull, triggers7 distributed bursts, then hides hull after1.1s. Existing neon atlas effects rendered in a separate world layer over hull, with no damage or UI overlay. Reset clears bursts and restores sprites. Mortar projectile grows32x24->56x42 and collision radius9->16, keeping trajectory and ground explosion radius unchanged. Source destruction PNGs retained but not preloaded/played. No engine/tests.


Iron HP/fragmentation revision2026-11-01: user asks+1x health, interpreted as double: exposed core24->48, cannon8->16. Mortar shell detonation (ground or direct/shield contact) emits8 discrete shrapnel rounds into the upward hemisphere,300px/s, gravity180, radius5, lifetime1.6s. One fragment generation per parent shell, no chain fragmentation; pending fragments join on next update to avoid mutating collision iteration. Every fragment uses swept guard/player hit and consumes contact once; grenade/reset/death clear both live/pending rounds. Atlas red slugs represent fragments, separate from large mortar orb. Landing marker and blast radius unchanged; no engine/tests.


Latest Iron shared HP rule2026-11-01: core and mortar hits both reduce the same48HP Boss pool. Cannon no longer takes separate module HP damage, hides or explodes independently; remains active until whole Boss defeat. Its internal availability sentinel remains positive until full death, and HUD removes the separate cannon count. Core threshold1 and cannon threshold3 remain; solid inert hull ricochet remains. Entire Boss still uses7 cosmetic death bursts; fragmentation shells retained. This supersedes earlier16HP destructible cannon. No engine/tests.


Latest Boss roster2026-11-01: reduce mortar fragments8->4 (upward angles-155/-115/-65/-25deg). Campaign01 eye,02 IRON BASTION,03 gunblade; Endless rotates eye at5,Iron at10,gunblade at15 then repeats every15waves. Explicit Boss tests still override; historical LAB unchanged. Iron uses shared48HP baseline and existing Endless five-wave HP/aggression growth plus selected difficulty; campaign02 remains normal baseline. Active-kind dispatch now recognizes Iron beyond test mode, including foreground flyers, summons, HUD, intro, grenade/death/reset and targeting. Boss hit message denominator uses actual encounter maximum. No engine/tests.
