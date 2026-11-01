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
const CHARGE_SPEED := 1000.0
const CHARGE_DISTANCE := 450.0
const STAB_SPEED := 850.0
const STAB_DISTANCE := 380.0
const GROUND_BULLET_SPEED := 440.0
const AIR_BULLET_SPEED := 390.0
const GROUND_SHOT_PHASES := [0.125,0.625]
const AIR_SHOT_PHASES := [0.125,0.5]
const GROUND_FIRE_FRAMES := [0,1,2,3,0,1,2,3]
const PREPARE := 0.9
const RECOVERY := 0.5
const GROUND_FIRE_TIME := 0.55
const SLASH_PREPARE := 0.8
const SLASH_TIME := 0.45
const TAKEOFF_TIME := 0.48
const AIR_PREPARE := 0.9
const AIR_FIRE_TIME := 0.55
const STAB_PREPARE := 0.9
const STAB_TIME := 0.48
const STAB_RECOVERY := 0.65
const LAND_TIME := 0.5
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
const SPARK_INTERVAL := 0.025
const SPARK_SPEED := 230.0
const SPARK_LIFETIME := 0.32
const THRUSTER_LENGTH := 30.0
