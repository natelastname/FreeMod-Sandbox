extends AudioStreamPlayer3D

var offset = 0

func remove_self():
	queue_free()

func play_sound(sound_stream):
	set_stream(sound_stream)
	connect("finished",self,"remove_self")
	play(offset)

func _ready():
	pass


