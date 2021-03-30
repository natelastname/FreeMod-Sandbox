class_name FreeModMap
extends Spatial

export(NodePath) var qodot_map_path
var qodot_map

onready var player = $"/root/World/map/Player"
var wep_scenes = {}

func get_qents_by_classname(qent_name):
	var qents = []
	for kid in qodot_map.get_children():
		if not "properties" in kid:
			continue
		elif not "classname" in kid.properties:
			continue
		elif kid.properties["classname"] != qent_name:
			continue
		else:
			qents.append(kid)
	
	return qents

func load_wep(swep_location):
	var wep_scene = load(swep_location)
	wep_scenes[swep_location] = wep_scene

func _ready():
	qodot_map = get_node(qodot_map_path)
