extends Spatial

onready var audio_player = $"AudioStreamPlayer3D"

func remove_self():
	queue_free()

func play(sound_stream):
	audio_player.set_stream(sound_stream)
	audio_player.connect("finished",self,"remove_self")
	audio_player.play()

func _ready():
	pass # Replace with function body.


