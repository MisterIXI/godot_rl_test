extends RigidBody3D
class_name PusherAgent

@export var object: RigidBody3D
@export var target_area: Area3D
@export var ai_controller: PusherAIController
@export var manual_control: bool = false
var queued_reward = 0.0
var last_dist = 0.0
var was_just_reset = false
const SPEED = 5.0
const ACCELLERATION = 15.0
const EPS = 0.1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if manual_control:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if input_dir.length() != 0:
			state.linear_velocity = linear_velocity.move_toward(direction * SPEED, ACCELLERATION * state.step)
		# print("input: %s, vel: %s" % [input_dir, state.linear_velocity])
	else:
		var input_dir := ai_controller.move
		if input_dir.length() > 1:
			input_dir = input_dir.normalized()
		if input_dir.length() != 0:
			state.linear_velocity = linear_velocity.move_toward(Vector3(input_dir.x, 0, input_dir.y) * SPEED, ACCELLERATION * state.step)

func _physics_process(_delta):
	# print("position: " + str(position))
	pass

func move_area_to_random_spot():
	target_area.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	while target_area.position.distance_to(object.position) < 2:
		target_area.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	was_just_reset = true

func move_object_to_random_spot():
	object.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	while object.position.distance_to(target_area.position) < 2:
		object.position = Vector3(randf_range(-3.8, 3.8), 0, randf_range(-3.8, 3.8))
	was_just_reset = true

func calc_reward():
	if is_object_at_wall():
		move_object_to_random_spot()
		queued_reward -= 15
	var distance = object.position.distance_to(target_area.position)
	var reward = queued_reward
	var dist_to_cube = object.position.distance_to(position)
	queued_reward = 0
	if is_at_wall(): # punish for being in a corner
		reward -= 1
	if not was_just_reset: # ignore after teleport of target, because that would punish unnecessarily
		if distance < last_dist - EPS: # if we're getting closer
			reward += 1
		elif distance > last_dist + EPS: # if we're getting further away
			reward -= 0.5
		else: # if we're not moving
			reward -= 5
		reward += 5 - dist_to_cube # reward for agent being close to object
	if was_just_reset:
		was_just_reset = false
	# reward for being close to object
	last_dist = distance
	return reward

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
		# finished objective, move area to random spot
		move_area_to_random_spot()
		queued_reward += 10


func _on_evil_zones_body_entered(body: Node3D) -> void:
	if body.is_in_group("Agent"):
		queued_reward -= 0.5
