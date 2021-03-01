extends Node


func _friction(kbody, delta):
	
	var speed = kbody.velocity.length()
	if speed == 0:
		return Vector3(0,0,0)

	var ctl = max(speed, kbody.stopspeed)

	var newspeed = speed - (delta*(kbody.friction)*ctl)
	if newspeed < 0:
		newspeed = 0

	return kbody.velocity*(newspeed/speed)

func movement_normal(delta, kbody, wish_dir):

	var length = wish_dir.length()
	if length > 0:
		wish_dir = wish_dir/length
	
	
	kbody.velocity = _friction(kbody, delta)		
	# How fast the player is going in the direction that they want to go
	var current_speed = kbody.velocity.dot(wish_dir)
	# How hard the player is pushing to go the direction they want to move
	var accelVel = (kbody.movement_accel) * delta
	
	if current_speed + accelVel > kbody.max_speed:
		# we are going as fast as we are allowed to go (in the direction of wish_dir)
		accelVel = kbody.max_speed - current_speed

	kbody.velocity = kbody.velocity + (wish_dir*accelVel)		
	kbody.velocity = kbody.move_and_slide(kbody.velocity, Vector3.UP)
