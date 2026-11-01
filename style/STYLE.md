# EverFront production style guide

Track: 2D frame by frame animation. Author: William Zhu. Lab C production handoff dated 1 November 2026. This guide consolidates the established direction; it does not claim the direction was first chosen today.

EverFront is an automatic scrolling side view run and gun game. The visual direction is pixel science fiction with Contra like arcade readability. The player must distinguish a rifle shot, armor rejection, shield contact and a lethal obstacle while moving. Art must support that decision before it supplies decoration.

## Visual language

Use dark blue industrial environments, deep olive player armor, bone white enemy machinery, charcoal recesses and red cloth. Cyan marks shield energy and normal progress. Amber marks selected weapons, currency and upgrades. Red marks hostile telegraphs and failure. Orange rifle rounds and blue armor piercing shots remain distinct. Boss materials belong to the same industrial palette; do not brighten each replacement independently.

Work on a960 by720 logical canvas with nearest sampling. Match visible pixel size at gameplay scale, not merely source image resolution. Preserve alpha gutters around each frame. Anchor player poses to feet and shoulder sockets; anchor machinery to its mounting base. Painted flashes and empty padding are not body hitboxes. Keep each frame at one consistent scale. Isolate a long sword blade or cannon flash before making an atlas.

## Hero assets

Hero one is the player: the original modular body, separate aiming arms and head, the selected olive sixteen frame run cycle, and the red procedural cape. Hero two is the armored turret family, with light and heavy silhouettes, charge, fire and damage states. The eye, gunblade and Iron Bastion bosses are additional production examples, not substitutes for documenting these two heroes.

## Environment and interface

Use the existing blue factory parallax layers and a readable horizontal track. Background contrast stays below characters and hostile rounds. Keep gameplay information near screen edges. Main menus use the industrial monitor artwork; text is real editable UI, not text baked by a generator. Manually authored labels and the title use Fusion Pixel. Larger tutorial text sits below the track. Important states include selected weapon, reload progress, shield energy, five campaign markers and Boss HP.

## VFX direction

Hit sparks are short white or amber bursts at the real contact point. Pickups use a cyan or amber collection burst. Failure uses a red burst before the death animation and framing. These three cosmetic effects can be disabled together in Settings. Gameplay bullets, damage regions and red attack warnings remain active. Reduced Flash is a separate control. More recent imagegen examples include the red slash flipbook and the warning banner; they are supplementary presentation, not permission to obscure the player.

## Music brief

Instrumental pixel science fiction action with a strong pulse and clear forward drive. Use restrained chiptune and electronic rhythm; avoid dense high frequency leads masking shots or warning cues. Regular play uses Untitled; Boss fights use Chase Mode, as selected by the developer. Keep the original full songs. The Lab C runtime uses separate sixty second Ogg loops with a short seam crossfade. Music and effects use separate native buses and a Master peak limiter. Seam audibility still needs listening acceptance.

## Voice brief and attention ranking

Priority order: lethal telegraphs, player shield and weapon state, enemy actions, pickups and progress, music, spoken narration. Use no spoken dialogue in this version. Read docs/voice-script.md for the150 word rationale. UI messages carry the relevant meaning; do not invent unrecorded voice trials.

## Acceptance and provenance

Review candidates at actual play size for silhouette, palette, frame stability, alpha edges and collision alignment. About four candidates is a decision checkpoint, not a claim that every historical search obeyed that cap. Keep originals and record replacements. See ASSET_LOG.csv for one row per retained asset, including superseded files and unresolved sources. Tool tiers, costs and historical task timings require the author's confirmation.
