extends CharacterBody3D
class_name DistanceKeeper

@export var obstacle: CharacterBody3D
@export var ai_controller: DistanceAIController
const ENV_SIZE_HALF = 9
const MOVE_SPEED = 15.0
const OBJECT_SPEED = 10.0
## move input, -1 to 1 for left to right
var move_input = 0.0

const TARGET_DIST: float = 5.0
## fake sensor output
var sensor_output = 0.0
const FIXED_PENALTY = -10



func _ready():
	ai_controller.init(self)
	reset_env()

func calc_reward():
	# calc dist to obstacle, the closer to TARGET_DIST the better
	var dist = abs(obstacle.position.x - position.x)
	var reward = 0
	reward += (TARGET_DIST - dist) * 0.1
	return reward

func _physics_process(delta):
	sensor_output = obstacle.position.x - position.x
	var clamped_input = clamp(move_input, -1, 1)
	var dist = clamped_input * MOVE_SPEED * delta
	dist = clamp(dist, -ENV_SIZE_HALF - position.x, ENV_SIZE_HALF - position.x)
	# move the agent
	var col = move_and_collide(Vector3.RIGHT * dist)
	if col:
		# check if we hit the obstacle
		if col.get_collider() == obstacle:
			ai_controller.needs_reset = true
			ai_controller.reward += FIXED_PENALTY
			ai_controller.done = true
			# reset the environment
			reset_env()

func reset_env():
	# reroll position for both objects
	position = Vector3(randf_range(-ENV_SIZE_HALF, ENV_SIZE_HALF - 2.0), 0, 0)
	obstacle.position = Vector3(randf_range(position.x + 1.0, ENV_SIZE_HALF), 0, 0)
	print("reset env")
