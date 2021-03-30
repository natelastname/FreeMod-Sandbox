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
	
	for key in wep_scenes.keys():
		player.add_wep(key)
	
	player.wep_update()	
	
	AudioUtil.play_at_pos(FileUtil.rand_elt(player_spawn_sounds), spawnpoint["origin"])

func _init():
	# Here, we load all weapons that are possible to get in this game mode.
	# This prepares them so that they can be added later with player.add_wep.
	load_wep("res://weps/unarmed/unarmed.tscn")		
	load_wep("res://weps/finger/finger.tscn")		
	load_wep("res://weps/wrench/wrench.tscn")		
	load_wep("res://weps/deagle/v_deagle.tscn")		
	load_wep("res://weps/mp5/mp5_viewmodel.tscn")
	load_wep("res://weps/psg/v_psg.tscn")
	load_wep("res://weps/m16/v_m16.tscn")
	load_wep("res://weps/m60/v_m60.tscn")
	load_wep("res://weps/test gun/testgun.tscn")
	load_wep("res://weps/striker/striker.tscn")
	load_wep("res://weps/barret/v_barret.tscn")
	load_wep("res://weps/mp5 SD/mp5SD.tscn")
	load_wep("res://weps/katana/v_katana.tscn")
	load_wep("res://weps/mossberg/mossberg.tscn")

func _ready():
	._ready()
	get_spawnpoints()
	player.wep_scenes = wep_scenes
	respawn_player()
