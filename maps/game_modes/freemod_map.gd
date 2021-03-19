class_name FreeModMap
extends Spatial

export(NodePath) var qodot_map_path
var qodot_map

onready var player = $"/root/World/map/Player"

var sound3d = preload("res://audio/sound3d.tscn")
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound3d_fact 
var sound_direct_fact

func play_3d_sound(audio_stream, position):
	if audio_stream == null:
		return
	var sound = sound3d_fact.duplicate()
	qodot_map.add_child(sound)
	sound.global_transform.origin = position
	sound.play_stream(audio_stream)
	return

func play_direct_sound(audio_stream):
	if audio_stream == null:
		return
	var sound = sound_direct_fact.duplicate()
	qodot_map.add_child(sound)
	sound.volume_db = -15
	sound.play_sound(audio_stream)

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

func _ready():
	qodot_map = get_node(qodot_map_path)
	sound3d_fact = sound3d.instance()
	sound_direct_fact = sound_direct.instance()
