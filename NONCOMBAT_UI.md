# Noncombat UI revision — 2026-10-31

User scope: prioritize noncombat interfaces after reviewing Claude's screenshot feedback. Combat HUD, gameplay, economy and persistence behavior remain as supplied.

- Added a menu-only theme (`ui/menu_style.gd`) so menu typography, neutral buttons, primary actions, danger actions and focus outlines are consistent without changing the combat HUD theme.
- Main menu retains its background and 640px framed panel. Primary buttons are 440px wide, with wallet balance inside the build-tree entry. Developer entries are compact secondary controls.
- Mission selector uses four readable rows with descriptions inside the buttons. No unrecorded best rank is invented.
- Controls use Action / Keyboard / Controller columns and full-width key caps; descriptions match existing controls.
- Main-menu and pause settings share the same 640px panel, 352px scrolling area, explicit cyan ON / neutral OFF indicators and scroll hint. Existing immediate-save, preview and reset behaviors remain.
- Build tree derives its presentation positions from the prerequisite topology in its own UI script. Purchase state controls node borders, branch identity controls fill, white outer border marks selection, and ancestors highlight. Locked details are neutral rather than red. Game data, prerequisites, prices and effects were byte-identical before/after this task.
- Pause uses a prominent Resume action. Death retains a framed MISSION FAILED text section, compact metrics, Boss phase/context where relevant, and default focus on Retry; existing death animation and camera timing remain unchanged.
- Victory separates performance and rewards, keeps the existing rank calculation, and focuses Next Mission when that action exists. Final mission focuses Redeploy.
- Combat reticle is omitted while paused; no other combat drawing/layout changed.

## Verification

Godot real-render capture inspected main menu, selector, controls, settings top/bottom, build tree available/owned/locked/insufficient-funds/selected states, pause, both pause subpages, normal/Boss death and intermediate/final victory. Tree and settings also rendered at 1280×720, 1920×1080 and 800×600. Panels fit the logical 960×720 canvas; fractional output scaling still has the project's existing pixel resampling tradeoff. Captures are in ignored `tmp/noncombat-review/`, not submission/tester data.

Existing checks passed: settings_smoke, progression_smoke, campaign_modes_smoke, start_modes_smoke. Progression test still reports its existing exit resource cleanup warnings. Test runs used `--lab-test`, with no real settings/progression writes or historical telemetry modifications.

Claude's coordinates were treated as a layout reference, not copied literally: content-driven panel heights avoid overflowing his proposed fixed rectangles. Existing Fusion Pixel and game assets are retained. Readable small labels use 12px where fractional font sizes distorted the pixel font. Best-score grades and new gameplay/control mappings were not added.
