# Retro shooter sheet — 2026-10-31

User supplied Downloads/复古像素射击游戏素材表.png (only one matching file was present despite duplicated name in message). Original1536x1024 RGB/black-background board retained unchanged. image_gen extracted actual alpha with preserved layout to assets/retro_shooter/sheet.png; source and generated texture dimensions and selected crops inspected without running Godot.

Coin world drops now cycle9 coin poses at10fps using fixed atlas cells; HUD, mission/build wallet icons share the new first-pose AtlasTexture. Existing coin burst/fall/bounce/homing/value/audio/wallet rules unchanged. Standard orange player rifle rounds and orange hostile rounds use the rifle slug; red generic hostile rounds use the red energy bolt. Sprites rotate with projectile velocity. Blue AP lasers, cyan special-round feedback, heavy turret beams and dedicated BossParticle/BossBomb visuals retain existing appearance. No collision radii, damage, speed or enemy pressure changes. Additional explosions/rocket/dust/melee-art from the sheet are not connected yet.

No runtime tests, import, captures or package exports performed. User manually tests. New render crops live in retro_shooter_assets.gd, static wallet icon in assets/retro_shooter/coin_icon.tres. User's other uncommitted HUD edits preserved.
