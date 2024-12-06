# meta-name: AI Controller Logic
# meta-description: Methods that need implementing for AI controllers
# meta-default: true
extends AIController3D
class_name PusherAIController

@onready var player: PusherAgent = get_parent()
var move: Vector2 = Vector2.ZERO
#-- Methods that need implementing using the "extend script" option in Godot --#

func get_obs() -> Dictionary:
	return {"obs":[
		player.position.x,
		player.position.z,
		player.linear_velocity.x,
		player.linear_velocity.z,
		player.object.position.x,
		player.object.position.z,
		player.target_area.position.x,
		player.target_area.position.z
	]}

func get_reward() -> float:	
	return player.calc_reward()
	
func get_action_space() -> Dictionary:
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
		},
		}
	
func set_action(action) -> void:	
	move.x = action["move"][0]
	move.y = action["move"][1]
# -----------------------------------------------------------------------------#

#-- Methods that can be overridden if needed --#

#func get_obs_space() -> Dictionary:
# May need overriding if the obs space is complex
#	var obs = get_obs()
#	return {
#		"obs": {
#			"size": [len(obs["obs"])],
#			"space": "box"
#		},
#	}