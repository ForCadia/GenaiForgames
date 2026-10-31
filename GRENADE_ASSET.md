# Grenade asset and current behavior

Generated on 2026-10-31 using the built-in image_gen tool. Project asset: `assets/items/grenade.png`; transparent PNG, used as the pickup and HUD icon. Original output is retained in the Codex generated_images directory.

Prompt:

> Create a single original game sprite for EverFront, a side-scrolling pixel-art science-fiction run-and-gun. One compact futuristic military hand grenade, olive green segmented metal body, dark charcoal outlines, small amber glowing charge indicator, steel safety lever and ring, slightly tilted 15 degrees. Crisp deliberate pixel art, limited palette, readable at 32x32 display size, flat side view with subtle pixel highlights, no smooth painting or photorealism. Centered isolated object occupying 80 percent of canvas. Actual transparent background, no ground, no shadow outside the object, no text, no other objects. This sprite will be used both as a pickup and as a thrown grenade.

The user subsequently specified an immediate screen flash/clear rather than a travelling projectile. F (or the retained controller RB binding / third weapon slot) consumes one grenade. Visible regular enemies and track hazards are cleared; all hostile bullets, Boss bombs and Boss particles are cleared. Boss receives one direct red-health hit without losing armor. Boss maximum red health is now 24. Existing movement, scrolling and weapon cadence are unchanged.

Each of the four active segments has one pickup event at authored time 0.7 seconds (subject to the existing segment pace); Boss entry supplies one pickup after 0.5 active seconds. Inventory capacity remains one. Retries restore the encounter and its pickup opportunity. `assets/sfx/item_pickup.wav` is byte-identical to the user's Downloads/claimitem.wav and is reused when collected. Historical tester JSON is unchanged.

UI follow-up: checkpoint titles use the 24px LargeLabel variant. Panels, button backgrounds and key-cap boxes are removed through a derived theme without overwriting the user's theme resource. The lower-right weapon HUD is widened while retaining its compact height.

The initial grenade regression passed before the user's final Boss-damage revision. Test files were updated for the final behavior; final runtime verification and packaging were intentionally left to the user as requested.
