extends FreeModSwep

func swep_process(_delta):
	# This is for testing purposes
	if Input.is_action_just_pressed("fire"):
		player.apply_damage(100)

