extends Node2D
# A visual-only attract loop. No gameplay, profile, input or telemetry callbacks.
const GD := preload("res://game_data.gd")
const PLAYER := preload("res://Player.tscn")
const LIGHT := preload("res://light_turret_frames.tres")
const HEAVY := preload("res://heavy_turret_frames.tres")
var game: Node
var actor: PlayerVisual
var active := false
var elapsed := 0.0
var scroll_distance := 0.0
var spawn_left := 0.0
var fire_left := 0.0
var magazine := 0
var reload_left := 0.0
var enemies: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var sparks: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor = PLAYER.instantiate()
	actor.collision_layer = 0
	actor.collision_mask = 0
	add_child(actor)
	disable_collisions(actor)
	set_active(false)

func disable_collisions(node: Node) -> void:
	if node is CollisionObject2D:
		node.collision_layer = 0
		node.collision_mask = 0
	for child in node.get_children(): disable_collisions(child)

func set_active(value: bool) -> void:
	active = value
	visible = value
	for enemy in enemies:
		if is_instance_valid(enemy.sprite): enemy.sprite.queue_free()
	enemies.clear()
	bullets.clear()
	sparks.clear()
	elapsed = 0
	scroll_distance = 0
	spawn_left = 1.2
	fire_left = 0.2
	magazine = 0
	reload_left = 0
	actor.set_process(value)
	if value:
		actor.start_scrolling()
		spawn_enemy(620,false)
		spawn_enemy(930,true)
		actor.position = Vector2(130,GD.GROUND_Y)
	queue_redraw()

func spawn_enemy(x: float, heavy: bool) -> void:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = HEAVY if heavy else LIGHT
	sprite.scale = Vector2(0.7,0.7)
	sprite.position = Vector2(x,GD.GROUND_Y-44)
	add_child(sprite)
	sprite.play(&"armored_idle" if heavy else &"idle")
	enemies.append({"sprite":sprite,"heavy":heavy,"armor":heavy,"hp":2,"dead":false,"life":0.0,"fire":0.9,"flash":0.0})

func _process(delta: float) -> void:
	if not active: return
	if game.state != "start": set_active(false); return
	elapsed += delta
	scroll_distance += 170 * delta
	spawn_left -= delta
	if spawn_left <= 0:
		spawn_enemy(1040,fmod(elapsed,7.0)>3.5)
		spawn_left = 2.4
	var jump_phase := fmod(elapsed,5.4)
	var jump := sin((jump_phase-2.8)/1.1*PI)*155 if jump_phase>2.8 and jump_phase<3.9 else 0.0
	actor.position = Vector2(130+sin(elapsed*0.6)*20,GD.GROUND_Y-jump)
	var target := Vector2(820,GD.GROUND_Y-55)
	var weapon := 0
	for enemy in enemies:
		if not enemy.dead and enemy.sprite.position.x > actor.position.x+80:
			target = enemy.sprite.position
			weapon = 1 if enemy.armor else 0
			break
	var guarding := fmod(elapsed,8.0)>6.8
	actor.set_motion(jump<=0,false,weapon,target,guarding,true)
	reload_left = maxf(0,reload_left-delta)
	fire_left -= delta
	if fire_left <= 0 and reload_left <= 0:
		if magazine >= 10:
			magazine = 0
			reload_left = 1.2
			actor.play_reload(reload_left)
		else:
			actor.play_fire()
			var muzzle := actor.muzzle_world_position()
			bullets.append({"pos":muzzle,"velocity":(target-muzzle).normalized()*1000,"hostile":false,"ap":weapon==1})
			magazine += 1
		fire_left = 0.38 if weapon==1 else 0.16
	for enemy in enemies:
		var sprite: AnimatedSprite2D = enemy.sprite
		sprite.position.x -= 170*delta
		enemy.flash = maxf(0,enemy.flash-delta)
		if enemy.dead:
			enemy.life += delta
			continue
		enemy.fire -= delta
		if enemy.fire <= 0 and sprite.position.x > 280 and sprite.position.x < 900:
			bullets.append({"pos":sprite.position+Vector2(-30,-12),"velocity":Vector2(-390,0),"hostile":true,"ap":enemy.heavy})
			if not enemy.heavy: sprite.play(&"shoot")
			enemy.fire = 1.3
		if enemy.flash <= 0 and sprite.animation in [&"shoot",&"damaged_shoot"] and not sprite.is_playing(): sprite.play(&"idle")
	for index in range(bullets.size()-1,-1,-1):
		var bullet: Dictionary = bullets[index]
		var previous: Vector2 = bullet.pos
		bullet.pos += bullet.velocity*delta
		var consumed := false
		if not bullet.hostile:
			for enemy in enemies:
				if enemy.dead: continue
				if Geometry2D.get_closest_point_to_segment(enemy.sprite.position,previous,bullet.pos).distance_to(enemy.sprite.position)<36:
					consumed = true
					if enemy.armor:
						if bullet.ap:
							enemy.armor = false
							enemy.sprite.play(&"armor_break")
							enemy.flash = 0.5
					else:
						enemy.hp -= 1
						if enemy.hp <= 0:
							enemy.dead = true
							enemy.sprite.play(&"explode")
							burst(enemy.sprite.position,Color("ffb224"))
					break
		elif bullet.pos.x < actor.position.x+45:
			burst(bullet.pos,Color("3de0f2"))
			consumed = true
		if consumed or bullet.pos.x < -40 or bullet.pos.x > 1080: bullets.remove_at(index)
	for index in range(enemies.size()-1,-1,-1):
		var enemy: Dictionary = enemies[index]
		if enemy.sprite.position.x < -100 or enemy.life>0.65:
			enemy.sprite.queue_free()
			enemies.remove_at(index)
	for index in range(sparks.size()-1,-1,-1):
		var spark: Dictionary = sparks[index]
		spark.pos += spark.velocity*delta
		spark.life -= delta
		if spark.life<=0: sparks.remove_at(index)
	queue_redraw()

func burst(origin: Vector2, color: Color) -> void:
	for index in range(10):
		sparks.append({"pos":origin,"velocity":Vector2.from_angle(index*TAU/10)*90,"life":0.35,"color":color})

func _draw() -> void:
	for bullet in bullets:
		var color := Color("389cff") if bullet.ap else Color("ff9638")
		draw_line(bullet.pos-bullet.velocity.normalized()*(28 if bullet.ap else 10),bullet.pos,color,3)
	for spark in sparks: draw_circle(spark.pos,2,spark.color)
