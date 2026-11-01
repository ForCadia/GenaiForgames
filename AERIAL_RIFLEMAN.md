# Aerial rifleman — 2026-10-31

User requested a ranged enemy from Downloads/空中射击兵像素动画设定表.png, restricted to Level03 and Endless. Original file retained unchanged. image_gen removed the reference board/background and redrew a transparent8x6 atlas: idle/fly/aim/shoot/boost/defeat, eight frames each. The soldier faces right in the asset and flips left at runtime.

Aerial_rifleman.gd creates an animated96px cell visual and36x60 hitbox,3HP (rifle1/AP2 damage), no armor,180 score/4G reward,40 active pressure points. It enters at170px/s from the right at y280/340, hovers near x730, aims for0.6s, locks player direction and fires three320px/s orange rounds0.18s apart. After each burst it boosts to another position within x620–860/y250–390. After two bursts it flies out left; age16s safety cleanup prevents stalled stages. Death plays its8-frame fall/explosion sequence, with immediate harmless state and one kill reward. Uses existing light-fire and explosion cues with calibrated audio routing.

main.gd integrates actor spawning, shots/unique piercing hits/homing, grenade kills, shield contact, lethal contact, smart weapon targeting, pressure reservation, death/offscreen cleanup and stage-clear wait. Existing hostile-round handling retains shield/auto-guard behavior. Title's real-game AI can target this enemy. All cleanup also applies to run retries and return to title.

Level03 replaces seven of its existing14 kamikaze events, preserving total event counts. Level01/02 and Boss/LAB entry points are untouched; spawning additionally enforces Level03-or-Endless scope. Endless adds a separate aerial type to all independent profile weights (10–22% nominal depending profile), preserving total-wave budgets and difficulty pressure limits. No campaign template is used by Endless.

Only the aerial coin-value entry is committed in build_data.gd; user's existing node-position edits remain uncommitted. No game, Godot import, tests or captures were run; manual acceptance is the user's responsibility.
