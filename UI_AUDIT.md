# EverFront UI audit — 2026-10-31

## Existing files and data sources

| File / scene | Responsibility | Authoritative data |
|---|---|---|
| main.gd / main.tscn | World simulation plus old immediate-mode HUD, reticle, banners, notices, death and victory overlays | score; stats.unarmored/light/heavy/flyer; state; segment; checkpoint resources; restart_mode; boss_mode; boss_test_mode |
| PlayerHUD.tscn / player_hud.gd | Old player-following HP/weapon/penetration/ammo block | _refresh_player_ui passes weapon name/penetration, ammo[weapon_index], weapon magazine, reload_left and actual reload duration |
| start_screen.gd | Start / developer / Boss test entry | start_game; developer_mode; boss_test_mode |
| lab_panel.gd | Presets, A/B modes, live tuning and local data tools | lab_panel.values/baseline; lab telemetry summary; existing administrative event APIs |
| lab_telemetry.gd | Historical experiment records and retry timing | Existing monotonic first-input/restart timestamps; excluded pauses; local persistence only |
| game_data.gd | Authored defaults | GUARD.maximum; WEAPONS; SEGMENTS; BOSS.health/armor_per_cycle |
| eyeball_boss.gd | Boss presentation state | form, armor_layers(), attack_state; main.boss.hp/armor/phase |
| music_player.gd / world_audio.gd / weapon_audio.gd | Existing music, effects, master mute | AudioServer Master mute; M shortcut |

The player has finite magazines and unlimited reserve, not a finite reserve-ammo counter. Grenade inventory is a boolean (0 or 1). Kills are already wired through _award_enemy_kill; screenshot fixtures previously displayed zero because no turret was killed. Death cause is main.banner after _die. Checkpoint/campaign retry semantics must remain intact.

## Confirmed problems

- Immediate-mode HUD and world objects share the world canvas; projectiles can cover text.
- _notify appends multiple floaters at the same position. Boss receive_shot and _boss_damage can both notify for one hit; this is the overlap source.
- Menu overlays still reveal the world HUD. Old player-following HP1/1 block adds clutter.
- Controls, fonts, sizes and colors are duplicated among scripts and scene overrides.

## Implementation boundaries

UI is moved into layered Controls, a shared theme, palette and string resources. No movement, armor, weapon, damage or Boss attack numbers change. Death input retains the existing 0.35-second animation lock and first-keypress capture: the proposed 0.4-second input discard would break the established retry contract. Debug entry buttons remain available as secondary controls during current student testing. Pause/controls are presentation states and do not add run duration or retries. UI death/time/best-score statistics are separate from experiment telemetry; Boss test and developer runs are not ranked or saved as campaign records. Historical JSON is never edited.

## Assets and verification

Font: Fusion Pixel, official repository https://github.com/TakWolf/fusion-pixel-font ; SIL OFL 1.1. Exact downloaded release/file and license will be recorded after import.

Generated chamfer panels, key caps, icons and stripe textures are original procedural UI assets. UI gallery uses clearly labeled fixture data; screenshots are interface previews, not human playtest evidence.

Stage verification and any deviations are recorded below as work completes.

## Delivered UI revision — 2026-10-31

- Foundation: shared `ui/ui_theme.tres`, palette, strings, generated chamfer/icon/stripe textures, key-cap component, nearest filtering and pixel-font import. Pinned font: official Fusion Pixel **2026.09.01**, `fusion-pixel-12px-monospaced-zh_hans.otf`. `tools/fetch_ui_font.py` reproduces the download and includes constituent OFL notices.
- HUD: existing `PlayerHUD.tscn` remains the scene adapter, now on CanvasLayer 10 with `ui/hud.gd`. Compact anchored score/guard panels and horizontal weapon panel replace immediate-mode text and the floating HP block. Magazine numbers mean current/capacity, not reserve. M and the icon button share Master mute. Reticle changes color for unavailable fire and turret/Boss aim.
- Prompts: one notification label replaces overlapping fixed-position floaters; checkpoint panel fades; contextual key-cap hints appear once per run for four seconds; opening controls last six seconds. Death clears prompts.
- Boss: one `apply_state` updates name/phase, armor or exposed-weak-point text, health and delayed damage trail. Armor flashes on loss. The independent canvas prevents projectiles covering HUD.
- Menus: pixel-styled title with decorative parallax, controls page, secondary developer/Boss entries, pause/resume/title and visual fade-in. The menu hides the gameplay HUD and player. Tuning uses the same theme.
- Results: readable death cause and actual checkpoint/campaign/Boss destination, buffered retry buttons, cumulative run time/deaths, campaign S/A/B/C rating and local best score. Developer/Boss test runs are unranked. Preview fixtures cannot save best scores. Victory stops simulation FX updates.
- Preview: run `ui/debug/ui_gallery.tscn` with F6; select pages or press PageUp/PageDown. Thirteen fixture views include menu, controls, HUD, reload, three Boss states, pause, death, victory, tuning, banner and tutorials. Preview data is explicitly labeled and never becomes tester telemetry.

## Adaptations to the proposal

The original gameplay/retry contract takes priority: early retry input is buffered during the existing 0.35-second lock, never discarded. Fades are cosmetic and do not defer run/retry timestamps. Developer and Boss test entries remain available in release builds, as previously requested. The weapon panel is horizontal to avoid covering the player; the existing HUD scene remains the integration point. Death/results use compact matching cards. Animations use restrained fades, score roll/pop, rank stamp and health trails rather than camera shake, full-screen sliding transitions or sequential result counters. UIAudio exposes empty tick/confirm hooks because no dedicated menu sounds were supplied.

## Verification

Godot 4.7.2 editor import and eight smoke suites passed: gameplay, Lab B, start modes, airtime, horizontal movement, player HUD, Boss and UI. New checks cover paused time, buffered UI retry, ordinary telemetry isolation and the Boss health display. Existing HUD checks now verify viewport anchoring and magazine/reload values instead of the removed HP block. A subset of headless shutdowns still intermittently reports ObjectDB/resource cleanup warnings; no script/assertion failures remain in the final runs.

All 13 preview pages were rendered with the native Compatibility renderer and visually reviewed at 960×720. Web release export was rebuilt; browser gameplay and physical controller navigation are left for manual testing. No deployment/upload or historical telemetry edits were performed.
