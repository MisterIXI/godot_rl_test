extends RigidBody3D
class_name PusherAgent

@export var object: RigidBody3D
@export var target_area: Area3D
@export var ai_controller: PusherAIController
@export var manual_control: bool = false
var reward = 0.0
const SPEED = 5.0
const ACCELLERATION = 15.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if manual_control:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		state.linear_velocity = linear_velocity.move_toward(direction * SPEED, ACCELLERATION * state.step)
	else:
		var input_dir := ai_controller.move
		if input_dir.length() > 1:
			input_dir = input_dir.normalized()
		state.linear_velocity = linear_velocity.move_toward(Vector3(input_dir.x, 0, input_dir.y) * SPEED, ACCELLERATION * state.step)

func move_area_to_random_spot():
	while target_area.position.distance_to(object.position) < 2:
		target_area.position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))


func _on_target_area_body_entered(body:Node3D) -> void:
	if body.is_in_group("Object"):
		# finished objective, move area to random spot
		move_area_to_random_spot()
		reward += 1

