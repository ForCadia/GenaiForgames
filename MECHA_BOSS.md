# Gunblade Mecha Boss — first implementation, 2026-10-31

User-authorized independent Boss test,24 shared HP. Existing eye Boss, campaign endings, Endless bosses, historical LAB and telemetry files remain unchanged. DEV/BOSS now opens an eye/mecha selector; the selected Boss remains through retry/redeploy. No enemy waves or terrain hazards accompany the mecha. Boss tests remain isolated from currency, persistent upgrades and records.

## Assets and frame contract

Six supplied Downloads/boss PNGs were visually inspected and copied unchanged to assets/boss_mecha. Existing alpha is real (background RGB may still contain color but alpha0); no imagegen/redraw or jet flames added. Source filenames and one-based frame sequences:

- ground_fire: 象牙机甲八帧开火使用1234.png — ONLY1,2,3,4; reused twice for an eight-tick firing cycle, never source5–8.
- slash: 滑行劈砍，使用12345689-11-10-9-12-13-14-15-1.png —1,2,3,4,5 prepare;6,8,9,11,10,9 sweep;12,13,14,15,1 recover. Source7/16 excluded. Idle uses slash1.
- stab: 空中向下攻击使用1345（攻击）671.png —1,3,4 prepare;5 active thrust;6,7,1 recovery. Despite filename, artwork is a horizontal left thrust, not a downward slash.
- lift: 象牙机甲起降像素帧，不要使用18使用滑行劈砍的1.png — takeoff slash1→lift2,3,4; landing lift5,6,7→slash1. Source lift1/8 excluded. Hover uses lift4.
- air_fire: 斜向下射击的无喷射机甲.png — all8 frames, no jet effects.
- death: 像素机甲持枪剑倒地八帧动画.png — all8 frames.

Frame regions use integer boundaries for1774x8874x2 and1536x10244x4 sheets. Offline source-pixel inspection provides chest anchors/opaque-body baselines, in assets/boss_mecha/frames.json and the exportable mecha_boss_frames.gd constant. Whole-body pose scale is calibrated by a common chest-to-helmet span; source sprites never flip, rotate or inherit movement mirroring. Feet align on the track; air foot root is displaced by code.

## Damage contract

Mecha has no consumable armor variable, armor bar, cracks, detachment or exposed phase. CORE_PENETRATION references GD.ENEMIES.light.armor=1; BODY_PENETRATION references GD.ENEMIES.heavy.armor=3, the existing AP-only threshold explicitly accepted by user for this Boss's medium body requirement. No new armor grade value invented. Core exists from first combat frame and shares the same24HP as body. Each valid bullet inflicts the current Boss weapon damage of1, with no core multiplier; insufficient penetration only plays ricochet. Grenade directly inflicts1 health damage and retains existing screen clear without armor changes.

Segment tests check the separate red-core region first, before body alpha/solid-pixel checks. Body checks reject transparent pixels, forward gun extension, red/orange effects and bright white blade centerlines adjoining red energy. Existing per-projectile actor IDs deduplicate mecha core/body into one target, including multi-target-piercing bullets. Homing target data uses core position; smart targeting can ask the region's penetration requirement.

## Loop, windows and configuration

MechaBoss.tscn/mecha_boss.gd are independent of EyeballBoss. mecha_boss_data.gd centralizes health, dimensions, speeds/distances/heights, projectiles and stage timings. Order: ground prepare0.9s → two-shot ground firing0.8s → recover0.8s → slash prepare1.0s → left charge/sweep0.65s → recover0.8s → backslide → wait0.8s → takeoff0.75s → air prepare0.9s → two-shot diagonal fire0.8s → recover0.8s → thrust prepare0.9s → horizontal thrust0.65s → recover1.0s → return hover → land0.8s → recover1.0s.

Ground bullets440px/s, air390px/s; shot emission snaps to the actual selected flash frames. Source-space barrel points are transformed by the current pose; airborne direction locks once per volley and follows the existing diagonal barrel orientation (no pursuit). Ground gun height intersects standing but clears crouched player. Ground sword checks only the forward sweep frames9/10/11/8 as configured (never preparation); jump clears its low band. Air stab only source5, at fixed altitude, grounded player passes below. No body-contact damage box seals a jump path. Sword swept rectangles account for fast horizontal travel and consume at most one contact/guard result per attack, via existing blockable _receive; shields remain recovery tools. Long return/recovery windows separate jump and aerial threats.

## Validation status

Only source/assets were inspected. NO Godot launch, import, automated tests or captures per standing user instruction. Manual acceptance remains: eye selector/regression; both retry paths; core AR/body ricochet/AP damage; grenade1HP and clear; shield one debit; crouch/jump/ground-under-stab evasion; source animation order, anchors/muzzles and death frames. Do not claim runtime verification. User's pre-existing HUD/layout/artwork changes were preserved; only the Boss HUD call is staged from that file.


## Frame/timing/aim correction

Source layouts are NOT exact uniform grids. Read alpha row/column gutters to derive per-row frame rectangles, keeping one-based frame orders unchanged. Examples: death row divider531 (not443), air fire472, ground fire495, lift470, stab485; slash row dividers258/512/760. Per-frame AtlasTextures clip filtering and inset2 pixels with margins restoring local size/anchor coordinates. This replaces Sprite2D region sampling and avoids sampling adjacent frame borders. No source image pixels were redrawn.

Ground/air fire durations0.8→0.55s, slash0.65→0.45s, takeoff0.75→0.48s, landing0.8→0.5s, recovery0.8→0.5s; death14fps. Increase charge/stab speeds to1000/850 so faster animations still cover configured distances. Slash prepare0.8s; stab prepare remains0.9s. Air stab now targets the player's position at the END of preparation, locks one direction and goal for the full lunge (overrides original fixed-height request). Sprite rotates about chest toward that direction, never flips. Capsule-like segment/swept-tip checks align melee to the locked blade axis and retain once-per-attack guard/contact. Recovery returns pose rotation to neutral before flying home/landing. No continuous tracking during lunge. No game/import/tests/captures run; manual acceptance pending.


Mecha atlas repack (2026-10-31): all six action sheets now use transparent `_spaced.png` assets, with full blade clearance and individually measured frame regions. Original sheets and user-authored frame selection/order are retained. All 56 source regions have an empty two-pixel outer border in the asset inspection. Per-sheet body scale, source-space hit masks, core anchors and per-frame muzzle coordinates are recalibrated for the new source sizes; death anchors use the neutral body center. Attack timing and gameplay rules are unchanged. No Godot run, import, export or runtime tests were performed, per user instruction.


Mecha entrance/effects revision (2026-10-31): user now authorizes backpack propulsion, superseding the original no-jet-flame request for this Boss. Mecha enters by descending from above the screen, plays landing poses and a brief safe recovery before its existing attack loop. Procedural pixel-style orange friction sparks travel left while grounded; cyan backpack exhaust follows the transformed sprite during airborne states, with a spark burst on touchdown. Cosmetic effects have no hitboxes or damage and clear on reset/death/disabled combat. Values are centralized in mecha_boss_data.gd. Changes were inspected as source only; no engine run or tests, per user request.


Mecha melee readability revision (2026-10-31): larger backpack exhaust and leftward ground sparks. Ground slash and aerial thrust display red swept-area telegraphs before execution; thrust direction locks at preparation start so the warning gives a usable dodge window. Windup poses play in the final 0.20 seconds of the unchanged preparation window; charge holds slash source frame 9, and execution/recovery/fire/lift/landing animations are faster. Cosmetic oversized red crescent uses the user Downloads neon effects atlas, retained unchanged as assets/vfx/neon_effects_source.png; shader removes its black background at render time. Damage still uses existing swept blade shapes and one contact per attack. No game, import or tests were run.


Melee warning presentation follow-up: removed warning outlines; widened ground warning from 37px to 73px and thrust warning from 36px to 80px. Enlarged cosmetic crescent artwork to 4.0x3.8 (slash) and 3.6x3.0 (thrust). Actual damage shapes and timing are unchanged. Source edits only, no runtime tests.


Ground slash effect alignment: rotate the red crescent into a broad, low horizontal arc centered on the actual blade band (core offset -57,30.5), following Boss charge travel for its 0.32-second execution. Retain the last attack kind/direction during fading so recovery cannot switch its orientation. Aerial thrust artwork, damage and warning geometry remain unchanged. No runtime testing.


Aerial thrust presentation correction: aerial attack now uses the straight red streak from the user neon atlas (27,422,340,64), aligned with locked stab direction, bright tip leading and tail behind. The crescent is restricted to ground slash; thrust movement, warning and collision remain unchanged. No runtime tests.


Mecha presentation update: normalize alive action-sheet scale using helmet-to-core span against ground idle, instead of total leg-dependent body height, correcting smaller aerial fire/thrust appearance. Ground melee cosmetic is now a thin red line across its swept path, expanding rapidly and contracting back to thin; the crescent is removed from ground melee. Slash preparation adds a red/white cross attached to per-pose sword-hand source anchors. Aerial straight thrust trail, HP/armor/damage and timings remain unchanged. Source changes only; no runtime verification per user instruction.


Screen-wide slash art: built-in imagegen generated assets/vfx/mecha_screen_slash.png with actual alpha. Ground slash now draws this strip across the logical viewport plus 120px overscan on each side, retaining thin/wide/thin animation. Original PNG and generation prompt are retained. This updates cosmetic reach only; melee damage and warning geometry remain unchanged. No runtime tests.


Pixel flipbook supersedes the single-strip slash: generated 4x2 eight-frame transparent atlas, played with AnimatedSprite2D at fixed scale/nearest filtering, synchronized to melee execution (25fps). The source frames provide the thin/wide/thin shape changes; previous vertical scale animation is removed. Full-screen cosmetic coverage remains. No runtime tests.


Backpack/scale follow-up: replace chest-relative exhaust offset with eight per-frame, full-sheet backpack outlet landmarks for lift, aerial fire and thrust. Convert through each frame region and actual sprite transform; exhaust points outwards right/down and only emits for sheets with known backpack anchors. No exhaust is guessed for ground slash poses. Narrow nozzle to18px, retain85px flame length. Per-sheet fixed helmet-width calibration (46 world pixels) now supersedes helmet-to-core normalization, avoiding torso/leg pose-dependent scale changes. Death uses matching helmet calibration too. Values/landmarks are centralized in mecha_boss_data.gd. Source/image inspection only; no game or tests.
