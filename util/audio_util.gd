extends Node

var sound_3d = preload("res://audio/sound_3d.tscn")
var sound_direct = preload("res://audio/sound_direct.tscn")

func play_direct(audio_stream):
	if audio_stream == null:
		return
	var sound = sound_direct.instance()
	add_child(sound)
	sound.play_sound(audio_stream)

func play_at_pos(audio_stream, position):
	if audio_stream == null:
		return
	var sound = sound_3d.instance()
	add_child(sound)
	sound.global_transform.origin = position
	sound.play_sound(audio_stream)
	
func play_at_node(audio_stream, parent):
	if audio_stream == null:
		return
	var sound = sound_3d.instance()
	parent.add_child(sound)
	sound.play_sound(audio_stream)
