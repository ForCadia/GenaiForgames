# THE FRONT NEVER STOPS — Godot prototype

A single-level 2D side-view shooting runner prototype built for Godot 4.7. The player stays on the left while the world scrolls right-to-left. The player and four-layer backdrop use imported pixel art; enemies, obstacles, effects, and HUD still use procedural geometry.

## Run

Open this folder in Godot 4.7 and press **F6/F5**, or run from a terminal with a Godot executable on PATH:

```powershell
godot --path .
```

The main scene is `main.tscn`.

## Backdrop assets

`main.tscn` contains editor-visible `Parallax2D` nodes for `background.png`, `middlelayer.png`, and `track.png`. Each scrolling layer uses its original 1672-pixel-wide image followed by a horizontally mirrored copy, making a seamless 3344-pixel loop without stretching or changing the source file. The scrolling distance ratios are 0.15, 0.55, and 1.35 respectively. The moon is no longer shown; its original `background-moon.png` and the earlier derived overlay remain untouched but unused. A scene-authored `Ground/CollisionShape2D` has its top edge at Y=620, matching the player's logical foot position and the track artwork.

## Laser gate

The legacy `high_barrage` timeline events now instantiate the editor-previewable `LaserGateEnemy.tscn` instead of four geometric projectiles. The gate still enters at X=990 and moves left at 315 px/s. Its source `lazerdrone.png` is actually 1774x887 rather than the specified 2304x1152, and its rows spill across an even 6x3 grid. `tests/generate_laser_gate_atlas.gd` repacks those existing pixels into `laser_gate_atlas.png` with 296x296 cells, leaving the original untouched and the four unused Hit cells transparent; `tests/generate_laser_gate_frames.gd` writes the three SpriteFrames animations. No rescaling is performed. Both drone hit areas share one exported HP value, defaulting to one hit; the laser damage shape is separate and turns off as soon as Hit begins.

## Controls

| Action | Keyboard / mouse | Controller |
|---|---|---|
| Jump | Space / W | A / Cross |
| Crouch | S / Ctrl | Left stick down |
| Aim | Mouse | Right stick |
| Fire | Left mouse | RT / R2 |
| Guard | Right mouse | LT / L2 |
| Switch weapon | Q / mouse wheel | Y / Triangle |
| Direct weapon slots | 1 rifle / 2 piercer / 3 grenade | — |
| Reload | R | X / Square |
| Grenade | E | RB / R1 |

After death, press R, Space, or Fire to restart the current segment checkpoint. Boss deaths restart the complete boss encounter.

## Prototype notes

- `body(2).png` is the active 8×5 body flipbook, with uniform 256×256 cells. Run plays at 14 FPS; startup, jump, slide and death remain at 12 FPS. Each animation row uses one fixed foot baseline; individual frames are never recentered from their alpha bounds, so authored motion remains intact without crop jitter. Its prominent upper circle is an arm socket, not a head: the complete source frame remains intact, both arm layers attach to that measured socket, and `helmet_game.png` sits slightly behind and above it while aiming toward the cursor. The original `body.png` and helmet assets remain untouched.
- The arm sheets remain 192×204 per cell. Their front and rear rows share a shoulder pivot, with calibrated reload offsets. The complete visual rig is at 0.5 scale; standing and sliding hurtboxes exclude the weapon. Shots spawn from the transformed muzzle in the visible gun direction. The HIGH recovery frame still crops muzzle-flash spill from its preceding cell.
- `PLAYER_CAN_DIE` in `main.gd` is `true`; the normal death and checkpoint retry flow is enabled. `tests/capture_visual.gd` saves running-game and magnified pose screenshots for visual checks.
- Six authored 20–25 second patterns run at a `0.72` prototype pace multiplier; world scrolling is additionally multiplied by `1.5`.
- Assault rifle and piercer have finite magazines and infinite reserve ammunition.
- Light armor takes one armor break plus one body hit. Heavy armor ricochets rifle rounds and requires the piercer to break its armor; there is no weakpoint bypass.
- The fifth segment contains the one-use grenade pickup.
- Boss armor must be broken with the piercer or a passing explosive track barrel. Once armor is gone, a hit on the boss body removes one of four health sections, then its armor resets.
- Audio and remaining placeholder art use color, particle, text, recoil, armor-break, guard, and death feedback.

## High-priority balancing checks

1. Jump clearance over low obstacles and stomp timing at 60/120/144 Hz.
2. Standing versus crouching collision against high barrages and hanging obstacles.
3. Guard drain (1.5 s), 0.75 s recovery delay, and 0.5 s break lockout.
4. Piercer armor-breaking against heavy enemies and the boss, followed by body hits.
5. Every segment and boss death restoring a clean, repeatable checkpoint state.
