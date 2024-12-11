@tool
extends Node3D

# add button

@export var distance_env: PackedScene
@export var batch_count: Vector2i
@export var batch_dist: Vector2
@export var respawn_envs: bool:
	set(x):
		spawn_envs()


var envs: Array[Node3D] = []
var env_root: Node3D = null

func spawn_envs():
	if not env_root:
		env_root = get_node("env_root")
		if not env_root:
			env_root = Node3D.new()
			add_child(env_root)
			env_root = env_root
			env_root.owner = self
			env_root.name = "env_root"
	if envs and envs.size() > 0:
		for x in envs:
			if x:
				x.queue_free()
		envs = []
	var total_size = Vector2(batch_count.x * batch_dist.x, batch_count.y * batch_dist.y)
	for x in batch_count.x:
		for y in batch_count.y:
			var env = distance_env.instantiate()
			env.position = Vector3(x * batch_dist.x - (total_size.x / 2 - batch_dist.x / 2), 0, y * batch_dist.y - (total_size.y / 2 - batch_dist.y / 2))
			env_root.add_child(env)
			env.owner = self
			envs.append(env)
