extends RefCounted
const GD := preload("res://game_data.gd")
const HEALTH := 48
const CANNON_HP := 16
const LAUNCHER_HP := 8
const PLATE_HP := 6
const ARMOR: int = GD.ENEMIES.heavy.armor
const CORE_ARMOR: int = GD.ENEMIES.light.armor
const HOME_X := 790.0
const ENTRY_SPEED := 430.0
const HULL_SCALE := 0.45
const HULL_ORIGIN := Vector2(-300.0,-475.0)
const CANNON_MOUNT := Vector2(25,-390.317)
const LAUNCHER_MOUNT := Vector2(8,-286)
const PLATE_MOUNT := Vector2(-127,-157)
const CORE_RECT := Rect2(-196.340,-320.566,46,104)
const PLATE_RECT := Rect2(-169,-337,84,182)
const BODY_RECT := Rect2(-240,-390,530,360)
const PREPARE := 1.0
const RECOVERY := 1.0
const FIRE_TIME := 0.40
const DEATH_FPS := 10.0
const CANNON_ANGLE := 35.0
const SHELL_GRAVITY := 580.0
const SHELL_RADIUS := 16.0
const DEPLOY_INTERVAL := 0.55
const DEPLOY_ROSTER := ["aerial","kamikaze"]
const AIR_SUPPORT_CAP := 3
const EXPLOSION_TIME := 0.28
const EXPLOSION_RADIUS := 34.0
const ATTACK_WAIT := {"easy":1.5,"normal":1.0,"hard":0.75}

const LAUNCH_PORTS := [Vector2(212,180),Vector2(272,204),Vector2(212,249),Vector2(272,270),Vector2(212,314),Vector2(272,330)]

const CANNON_SCALE := 0.36
const LAUNCHER_SCALE := 0.28
const PLATE_SCALE := 0.37
const INTRO_FOCUS := Vector2(0,-267)

# Regions include firing flash overshoot; mount anchors are global source coordinates.
const CANNON_REGIONS := [Rect2(0,0,700,512),Rect2(700,0,836,512),Rect2(0,504,768,520),Rect2(768,504,768,520)]
const CANNON_ANCHORS := [Vector2(445,500),Vector2(1177,501),Vector2(478,1005),Vector2(1180,1005)]
const CANNON_MUZZLES := [Vector2(205,155),Vector2(950,195),Vector2(232,671),Vector2(940,680)]

const DEPLOY_ORIGIN := Vector2(-60,-440.317)

const HULL_ANIM_SCALE := 1.15163148
const CANNON_ANIM_SCALE := 0.52
const REVERSE_FPS := 10.0

const GROUND_OFFSET := 18.0
const CHASSIS_BOUNCE := [Vector2(0,0),Vector2(0,-2),Vector2(0,1),Vector2(0,-1)]

const SHELL_DRAW_SIZE := Vector2(56,42)
const DEATH_BURST_TIME := 0.45
const FORTRESS_DEATH_TIME := 1.1

const FRAGMENT_ANGLES := [-170.0,-150.0,-130.0,-110.0,-70.0,-50.0,-30.0,-10.0]
const FRAGMENT_SPEED := 300.0
const FRAGMENT_GRAVITY := 180.0
const FRAGMENT_RADIUS := 5.0
const FRAGMENT_LIFETIME := 1.6
const FRAGMENT_DRAW_SIZE := Vector2(18,10)
