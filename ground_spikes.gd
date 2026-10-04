class_name GroundSpikes
extends Area2D

@onready var base_collision: CollisionShape2D = $BaseCollision
@onready var spike_collisions: Array[CollisionPolygon2D] = [
	$LeftSpikeCollision, $CenterSpikeCollision, $RightSpikeCollision
]

var touching_player := false

func advance(delta: float, speed: float) -> void:
	position.x -= speed * delta

func hits_rect(rect: Rect2) -> bool:
	var base_shape := base_collision.shape as RectangleShape2D
	if Rect2(base_collision.global_position - base_shape.size * 0.5, base_shape.size).intersects(rect):
		return true
	var player_polygon := PackedVector2Array([
		rect.position, Vector2(rect.end.x, rect.position.y),
		rect.end, Vector2(rect.position.x, rect.end.y)
	])
	for collision in spike_collisions:
		var points := PackedVector2Array()
		for point in collision.polygon:
			points.append(collision.to_global(point))
		if not Geometry2D.intersect_polygons(player_polygon, points).is_empty():
			return true
	return false
