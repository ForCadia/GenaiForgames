extends Node2D
# Cosmetic only: no hitboxes, damage, input, audio or telemetry.
const DATA := preload("res://mecha_boss_data.gd")
const GD := preload("res://game_data.gd")
var sparks: Array[Dictionary] = []
var spark_clock := 0.0
var effect_time := 0.0
var thrust := false
var nozzle := Vector2.ZERO
var thrust_direction := Vector2.DOWN
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func clear_effects() -> void:
	sparks.clear()
	spark_clock = 0.0
	thrust = false
	queue_redraw()

func _spark(origin: Vector2, burst: bool = false) -> void:
	if sparks.size() >= 96: return
	var velocity := Vector2(-rng.randf_range(0.6,1.35)*DATA.SPARK_SPEED,-rng.randf_range(22.0,95.0))
	if burst: velocity *= 1.4
	sparks.append({"p":origin,"v":velocity,"life":DATA.SPARK_LIFETIME,"max_life":DATA.SPARK_LIFETIME})

func landing_burst() -> void:
	for index in range(18):
		_spark(get_parent().global_position+Vector2(rng.randf_range(-35.0,25.0),-2.0),true)

func advance_effects(delta: float, enabled: bool, state: String, sprite: Sprite2D, metadata: Dictionary, sheet: String, frame: int) -> void:
	effect_time += delta
	for index in range(sparks.size()-1,-1,-1):
		var spark: Dictionary = sparks[index]
		spark.life = float(spark.life)-delta
		if float(spark.life) <= 0.0:
			sparks.remove_at(index)
			continue
		spark.v = Vector2(spark.v)+Vector2(0.0,220.0)*delta
		spark.p = Vector2(spark.p)+Vector2(spark.v)*delta
		if Vector2(spark.p).y > GD.GROUND_Y:
			spark.p = Vector2(Vector2(spark.p).x,GD.GROUND_Y)
			spark.v = Vector2(Vector2(spark.v).x,0.0)
	var grounded: bool = enabled and state not in ["dead","inactive","entry","takeoff","land"] and absf(get_parent().global_position.y-GD.GROUND_Y) < 2.0
	if grounded:
		spark_clock += delta
		while spark_clock >= DATA.SPARK_INTERVAL:
			spark_clock -= DATA.SPARK_INTERVAL
			_spark(get_parent().global_position+Vector2(rng.randf_range(-32.0,24.0),-2.0))
	else:
		spark_clock = 0.0
	thrust = enabled and state in ["entry","takeoff","air_prepare","air_fire","air_recover","stab_prepare","stab","stab_recover","air_return","land"]
	thrust = thrust and DATA.BACKPACK_OUTLETS.has(sheet)
	if thrust and not metadata.is_empty():
		# Full-sheet measured backpack outlet, not a chest-relative offset.
		var landmarks: Array = DATA.BACKPACK_OUTLETS[sheet]
		var source: Vector2 = landmarks[clampi(frame,0,landmarks.size()-1)]-Vector2(float(metadata.x),float(metadata.y))
		nozzle = to_local(sprite.to_global(source))
		# Exhaust exits outwards behind the pack, never through the torso.
		thrust_direction = Vector2(0.7,0.714143).rotated(sprite.global_rotation-global_rotation)
	queue_redraw()

func _draw() -> void:
	for spark in sparks:
		var p: Vector2 = to_local(Vector2(spark.p)).round()
		var fade: float = clampf(float(spark.life)/float(spark.max_life),0.0,1.0)
		var tail := Vector2(16.0,-4.0)
		draw_line(p,p+tail,Color(1.0,0.48,0.08,fade),3.0,false)
		draw_rect(Rect2(p,Vector2(4,4)),Color(1.0,0.9,0.5,fade))
	if not thrust: return
	# Stepped, unfiltered pixel flame behind the backpack, not a damage region.
	var pulse: float = 0.84+0.16*sin(effect_time*43.0)
	var length: float = DATA.THRUSTER_LENGTH*pulse
	var axis: Vector2 = thrust_direction
	var side := axis.orthogonal()
	var root: Vector2 = nozzle.round()
	draw_colored_polygon(PackedVector2Array([root-side*DATA.THRUSTER_WIDTH*0.5,root+side*DATA.THRUSTER_WIDTH*0.5,root+axis*(length*0.5)+side*6.0,root+axis*length,root+axis*(length*0.5)-side*6.0]),Color("287adf"))
	draw_colored_polygon(PackedVector2Array([root-side*4.5,root+side*4.5,root+axis*(length*0.72)]),Color("65e8ff"))
	draw_rect(Rect2(root-Vector2(4,3),Vector2(8,9)),Color("e8ffff"))
