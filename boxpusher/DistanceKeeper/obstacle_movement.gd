extends CharacterBody3D
class_name  ObstacleMovement
var time_left = 0.0
var current_input = 0.0
@export var distance_agent: DistanceKeeper

func _physics_process(delta):
	time_left -= delta
	if time_left <= 0:
		time_left = randf_range(0.5, 2.0)
		current_input = randf_range(-1.0, 1.0)
	var dist = current_input * distance_agent.OBJECT_SPEED * delta

	dist = clamp(dist,-distance_agent.ENV_SIZE_HALF - position.x + 3.0, distance_agent.ENV_SIZE_HALF - position.x)
	move_and_collide(Vector3.RIGHT * dist)