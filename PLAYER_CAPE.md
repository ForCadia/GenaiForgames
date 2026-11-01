# Procedural ribbon cape — 2026-10-31

First visual-only implementation requested by the user. Downloads/红白披风围巾素材图.png supplies the red/ivory cloth and cowl design; 飘扬的破碎赤红披风.png was inspected as a silhouette reference. Original Downloads files remain unchanged. image_gen extracted/redrew a transparent pixel atlas plus a separate pure-red scarf. The unused red/ivory cowl within the atlas is not rendered.

- player_cape.gd creates a twelve-link global-space Verlet strip with fixed-step integration, damped inertia, wind and gravity. Seven constraint passes keep link lengths, behind-body placement and ground clearance. Vertices snap to logical world pixels and use nearest texture sampling.
- Red and bone-white textured meshes share the strip, with a small animated lining offset for visible pale edging. This is a broad ribbon with preserved painted folds, not a full 3D cloth simulation or arbitrary front/back folding.
- Root follows the animated back-shoulder socket; run, slide and jump change airflow/width. Player movement contributes inertia without affecting movement or collisions. Teleports/restarts reinitialize the strip; hidden actors stop simulating; UI pause freezes it.
- Death lowers the attachment toward the body and removes wind so the cape settles above the track. The scarf hides during death because the existing death animation contains its own head.
- Cape z=-3 behind the body. Scarf is a sibling inserted immediately before Helmet at z=0: body → pure-red scarf → helmet → front weapon arm. Its position follows the helmet neck anchor with a downward offset, without inheriting weapon aiming rotation. The separate head remains above the scarf.
- Local artwork sizes: link6.5 world pixels ×12, maximum cloth half-width17 world pixels; scarf68 VisualRoot pixels before the existing0.5 scale. Values are presentation-only.

Assets: assets/player/cape_red_ivory_atlas.png and assets/player/scarf_red_pixel.png. Integration only adds a child from player_visual.gd; gameplay, collider shapes, weapons, HUD and historical telemetry are unchanged. No Godot game/import/tests/captures run per user; user will judge size, attachment and motion in play.


Latest user revision: scarf and ivory mesh are removed from rendering; only the red cape remains (source/unused assets retained). Thick cloth uses stronger shape springs, lower gravity/flutter, higher damping and10 constraint passes plus two-link bending constraints; root direction is braced, tail still moves and death relaxes it. Draw layers now body0, cape1, back arm/helmet/front arm2 in their original sibling order, guard3. A visual-only8×10px elliptical shoulder exclusion follows the animated back-shoulder socket. Both centerline simulation points and rendered cloth edges are pushed to its rear boundary on contact; root attachment is exempt. No changes to gameplay collision/hitboxes. No runtime tests per user.


Jump/render correction: the previous floor constraint incorrectly followed actor.global_position.y (airborne feet). Both simulation and mesh now use the true game_data.GROUND_Y transformed by the world parent. Root displacement translates current AND previous strip points before solving relative flutter; capped root acceleration supplies movement inertia without collapsing link geometry. Enforce rearward centerline spacing, stabilize width-normal orientation and use explicit triangle faces instead of runtime quad triangulation to reduce folds/missing mesh. Fixed dimensions remain independent of body animation scale. Source-only inspection, no runtime verification.
