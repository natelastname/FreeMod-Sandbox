class_name mode_deathmatch
extends FreeModMap

export(Array, AudioStreamSample) var player_spawn_sounds = null			

var spawnpoints = []

# Get the deathmatch spawnpoints of the map
func get_spawnpoints():
	var s_points = get_qents_by_classname("info_player_deathmatch")
	for spawnpoint in s_points:
		var spawnpoint_dict = {}
		var angle = 0
		var origin = spawnpoint.global_transform.origin
		if "angle" in spawnpoint.properties:
			angle = float(spawnpoint.properties["angle"])/180
			angle = angle * PI
			angle = angle + PI
		spawnpoint_dict["angle"] = angle
		spawnpoint_dict["origin"] = origin
		spawnpoints.append(spawnpoint_dict)

func respawn_player():
	if len(spawnpoints) == 0:
		player.global_transform.origin = Vector3(0,0,0)
		player.mouse_motion.x = 0
		return
	var spawnpoint = FileUtil.rand_elt(spawnpoints)
	player.global_transform.origin = spawnpoint["origin"]
	player.mouse_motion.x = spawnpoint["angle"]/-0.001
	player.velocity = Vector3(0,0,0)
	play_3d_sound(FileUtil.rand_elt(player_spawn_sounds), spawnpoint["origin"])
		
func _ready():
	._ready()
	get_spawnpoints()
	respawn_player()
