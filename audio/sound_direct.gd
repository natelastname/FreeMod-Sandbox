extends AudioStreamPlayer

func remove_self():
	queue_free()

func play_sound(sound_stream):
	set_stream(sound_stream)
	connect("finished",self,"remove_self")
	play()

func _ready():
	pass # Replace with function body.


