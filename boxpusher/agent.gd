extends RigidBody3D
class_name PusherAgent

@export var object: RigidBody3D
@export var target_area: Area3D
@export var ai_controller: PusherAIController
@export var manual_control: bool = false
@export var agent_collision_shape: CollisionShape3D
@export var agent_mesh: MeshInstance3D

var last_dist = 0.0
var was_just_reset = false
const SPEED = 2.0
const ACCELLERATION = 20.0
const ROTATION_SPEED = 2.0
const EPS = 0.1
var body_rotation: = 0.0

func _ready():
	ai_controller.init(self)
	reset_env()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if manual_control:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		# var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		var direction := (Vector3(input_dir.x, 0, input_dir.y))

		var rotate_input := Input.get_action_strength("rotate_left") - Input.get_action_strength("rotate_right")
		if input_dir.length() != 0:
			state.linear_velocity = linear_velocity.move_toward(direction * SPEED, ACCELLERATION * state.step)
		angular_velocity.y = rotate_input * ROTATION_SPEED


		# print("input: %s, vel: %s" % [input_dir, state.linear_velocity])
	else:
		var input_dir := ai_controller.move
		if input_dir.length() > 1:
			input_dir = input_dir.normalized()
		if input_dir.length() != 0:
			state.linear_velocity = linear_velocity.move_toward(Vector3(input_dir.x, 0, input_dir.y) * SPEED, ACCELLERATION * state.step)
		angular_velocity.y = ai_controller.rotate_input * ROTATION_SPEED

func move_area_to_random_spot():
	target_area.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	while target_area.position.distance_to(object.position) < 2 or target_area.position.distance_to(position) < 2:
		target_area.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	was_just_reset = true

func move_object_to_random_spot():
	object.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	while object.position.distance_to(target_area.position) < 2 or object.position.distance_to(position) < 2:
		object.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	object.linear_velocity = Vector3.ZERO
	object.angular_velocity = Vector3.ZERO
	was_just_reset = true

func move_agent_to_random_spot():
	position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	while position.distance_to(target_area.position) < 2 or position.distance_to(object.position) < 2:
		position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	was_just_reset = true

func calc_reward():
	var distance = object.position.distance_to(target_area.position)
	var reward = 0
	var dist_to_cube = object.position.distance_to(position)
	if not was_just_reset: # ignore after teleport of target, because that would punish unnecessarily
		if distance < last_dist - EPS: # if we're getting closer
			reward += 1
		elif distance > last_dist + EPS: # if we're getting further away
			reward -= 0.5
		else: # if we're not moving
			reward -= 0.5
		reward += max(-10,-dist_to_cube)*0.3 # reward for agent being close to object
	else:
		was_just_reset = false
	# reward for being close to object
	last_dist = distance
	return reward

func reset_env():
	move_area_to_random_spot()
	move_object_to_random_spot()
	move_agent_to_random_spot()
	# random object rotation on y
	object.rotation.y = randf_range(0, 6.28)
	ai_controller.reward = 0
	

func is_at_wall():
	if (position.x > 4.3 or position.x < -4.3) or (position.z > 4.3 or position.z < -4.3):
		return true
		
	return false

func is_object_at_wall():
	if (object.position.x > 4.3 or object.position.x < -4.3) or (object.position.z > 4.3 or object.position.z < -4.3):
		return true
	return false

func _on_target_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Object"):
		ai_controller.reward += 2
		ai_controller.done = true


func _on_evil_zones_body_entered(body: Node3D) -> void:
	if body.is_in_group("Agent"):
		ai_controller.reward -= 1
