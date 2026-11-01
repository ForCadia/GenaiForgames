# Aerial rifleman — 2026-10-31

User requested a ranged enemy from Downloads/空中射击兵像素动画设定表.png, restricted to Level03 and Endless. Original file retained unchanged. image_gen removed the reference board/background and redrew a transparent8x6 atlas: idle/fly/aim/shoot/boost/defeat, eight frames each. The soldier faces right in the asset and flips left at runtime.

Aerial_rifleman.gd creates an animated96px cell visual and36x60 hitbox,3HP (rifle1/AP2 damage), no armor,180 score/4G reward,40 active pressure points. It enters at170px/s from the right at y280/340, hovers near x730, aims for0.6s, locks player direction and fires three320px/s orange rounds0.18s apart. After each burst it boosts to another position within x620–860/y250–390. After two bursts it flies out left; age16s safety cleanup prevents stalled stages. Death plays its8-frame fall/explosion sequence, with immediate harmless state and one kill reward. Uses existing light-fire and explosion cues with calibrated audio routing.

main.gd integrates actor spawning, shots/unique piercing hits/homing, grenade kills, shield contact, lethal contact, smart weapon targeting, pressure reservation, death/offscreen cleanup and stage-clear wait. Existing hostile-round handling retains shield/auto-guard behavior. Title's real-game AI can target this enemy. All cleanup also applies to run retries and return to title.

Level03 replaces seven of its existing14 kamikaze events, preserving total event counts. Level01/02 and Boss/LAB entry points are untouched; spawning additionally enforces Level03-or-Endless scope. Endless adds a separate aerial type to all independent profile weights (10–22% nominal depending profile), preserving total-wave budgets and difficulty pressure limits. No campaign template is used by Endless.

Only the aerial coin-value entry is committed in build_data.gd; user's existing node-position edits remain uncommitted. No game, Godot import, tests or captures were run; manual acceptance is the user's responsibility.


Latest user revision: enlarged visual96→128px and hitbox36×60→48×80. Replace stationary hover/boost with kamikaze-style smooth104×64 ellipse/tangent orbit around(650,base_y),2.6s before each0.6s aim; orbit continues slower while aiming/firing. No self-destruct/dive; exits after two bursts. Shots now fixed left/down45° at480px/s (was320), muzzle follows a30° visual lean aligning the reference rifle to the shot direction. Dead actors manually show only frames1–3 during gravity-driven fall; hold frame3 until actual world ground contact, then play frames4–8 and explosion sound. Cleanup waits for the landing sequence, rather than the old fixed death timeout. HP/reward/threat/spawn scope unchanged. File-only, user tests.


Latest firing presentation: aerial rounds use a dedicated main callback with radius4/glow4 (others retain7/glow8), unchanged480 speed and45-degree trajectory. Fly bank limited to±0.035rad, aim/shoot26-degree lean eased more slowly, tiny1.5px visual bob supports jet flight. Muzzle locations are calibrated per shoot-row frame by reading the forward orange muzzle-flash base (excluding rear jet), with source-space fallback; mirror offsets and Sprite2D.to_global apply current scale/rotation/bob. Emission happens after movement/pose transforms, retaining the final shoot pose through its last bullet. No game/import/tests/captures.


Latest aim revision: remove fixed45-degree direction. Each burst samples filtered player velocity, estimates travel time capped0.65s, applies45–80% randomized lead and adds±32px horizontal/±22px vertical aim error, with on-playfield target limits. Lock that direction for all3 rounds; no per-round retargeting or homing. Attack artwork banks toward target within the existing restrained tilt range; muzzle transform,480 speed, radius4/glow4 retained. No runtime tests.


Latest corpse persistence: after ground contact, play landing frames4–7 and hold the final prone body (frame8 is an explosion-only image). Continue moving left at the actual track scroll speed indefinitely until the full transformed sprite rectangle is left of x0; remove death timeout. Corpse uses absolute z=-9, directly above track z=-10 and below live actors. Remains harmless/unshootable/no threat points; standard administrative cleanup still clears it on retry/title. No runtime tests.


Runtime-log correction: existing EverFront/logs/godot.log reports AnimatedSprite2D.get_rect missing in is_finished. Replace it with bounds derived from current SpriteFrames frame texture size, offset/centering/flips and global transform; retain complete-offscreen cleanup. Other retained runtime logs inspected did not contain additional script errors at inspection time. Read-only logs/source inspection only; no game/tests launched.
