extends RefCounted
const GD := preload("res://game_data.gd")
# Reuse actual project thresholds, not a newly invented medium armor value.
const CORE_PENETRATION: int = GD.ENEMIES.light.armor
const BODY_PENETRATION: int = GD.ENEMIES.heavy.armor
const HEALTH := 24
const BODY_HEIGHT := 160.0
const HOME_X := 730.0
const AIR_X := 600.0
const HOVER_HEIGHT := 195.0
const ENTRY_SPEED := 240.0
const RETREAT_SPEED := 280.0
const GROUND_RETREAT_SPEED := 700.0
const CHARGE_SPEED := 1450.0
const CHARGE_DISTANCE := 450.0
const STAB_SPEED := 1300.0
const STAB_DISTANCE := 380.0
const GROUND_BULLET_SPEED := 440.0
const AIR_BULLET_SPEED := 390.0
const GROUND_SHOT_PHASES := [0.125,0.625]
const AIR_SHOT_PHASES := [0.125,0.5]
const GROUND_FIRE_FRAMES := [0,1,2,3,0,1,2,3]
const PREPARE := 0.9
const RECOVERY := 0.30
const GROUND_FIRE_TIME := 0.40
const SLASH_PREPARE := 0.8
const SLASH_TIME := 0.32
const TAKEOFF_TIME := 0.35
const AIR_PREPARE := 0.9
const AIR_FIRE_TIME := 0.40
const STAB_PREPARE := 0.9
const STAB_TIME := 0.30
const STAB_RECOVERY := 0.26
const LAND_TIME := 0.38
const LAND_RECOVERY := 0.75
# Actual sheet order, kept separate by action. Indices are zero-based.
const SLASH_READY := [0,1,2,3,4]
const SLASH_ACTIVE := [5,7,8,10,9,8]
const SLASH_RECOVER := [11,12,13,14,0]
const STAB_READY := [0,2,3]
const STAB_ACTIVE := [4]
const STAB_RECOVER := [5,6,0]

const DEATH_FPS := 14.0
const ATLAS_INSET := 2.0
const STAB_HIT_LENGTH := 150.0
const STAB_HIT_RADIUS := 10.0

# Mecha entrance and cosmetic propulsion/friction, separate from combat tuning.
const ENTRY_TIME := 1.1
const ENTRY_OFFSET_X := 110.0
const ENTRY_RECOVERY := 0.45
const SPARK_INTERVAL := 0.015
const SPARK_SPEED := 340.0
const SPARK_LIFETIME := 0.46
const THRUSTER_LENGTH := 85.0

const MELEE_WINDUP_ANIMATION := 0.20
const SLASH_CHARGE_FRAME := 8
const MELEE_TRAIL_TIME := 0.22

# Source-pixel helmet widths measured independently of legs, blades and backpack.
const HELMET_WORLD_WIDTH := 46.0
const HELMET_SOURCE_WIDTH := {"slash":34.0,"ground_fire":44.0,"lift":44.0,"air_fire":46.0,"stab":45.0,"death":44.0}
# Backpack outlet landmarks in full-sheet coordinates, frame order retained.
const BACKPACK_OUTLETS := {
 "air_fire":[Vector2(300,215),Vector2(744,214),Vector2(1187,214),Vector2(1630,214),Vector2(299,636),Vector2(744,636),Vector2(1187,636),Vector2(1631,636)],
 "stab":[Vector2(287,218),Vector2(733,215),Vector2(1174,213),Vector2(1619,213),Vector2(275,638),Vector2(742,638),Vector2(1187,638),Vector2(1624,635)],
 "lift":[Vector2(290,219),Vector2(735,213),Vector2(1174,209),Vector2(1619,207),Vector2(288,650),Vector2(735,635),Vector2(1174,662),Vector2(1616,666)]
}
const THRUSTER_WIDTH := 18.0

# Chest weak-point box in unrotated world-size units relative to the red core.
const CORE_HIT_RECT := Rect2(-30.0,-23.0,66.0,48.0)
