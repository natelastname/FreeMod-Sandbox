extends AudioStreamPlayer3D

func remove_self():
	queue_free()

func play_stream(sound_stream):
	set_stream(sound_stream)
	self.connect("finished",self,"remove_self")
	play()

func _ready():
	pass

