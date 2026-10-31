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
