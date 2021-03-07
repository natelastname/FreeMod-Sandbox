extends Node

# The maximum height of a ledge that can be automatically scaled
var step_height = 1.05
var step_offset = (step_height)*Vector3.UP

func _friction(kbody, delta):
	
	var speed = kbody.velocity.length()
	if speed == 0:
		return Vector3(0,0,0)

	var ctl = max(speed, kbody.stopspeed)

	var newspeed = speed - (delta*(kbody.friction)*ctl)
	if newspeed < 0:
		newspeed = 0

	return kbody.velocity*(newspeed/speed)


# Called whenever the kbody hits a wall, tests if the wall is a small step
# that should be automatically climbed
func wall_collide(kbody, delta):
	pass


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

	var test_dir = kbody.velocity
	test_dir.y = 0
	var test_transform = kbody.global_transform

	kbody.velocity = kbody.move_and_slide(kbody.velocity, Vector3.UP)

	
	var moveA = kbody.is_on_wall()
	var moveB = true

	if moveA:
		test_transform.origin = test_transform.origin + step_offset
		# clear the y compotent because it causes test_move to return true due to a
		# collision with the floor.
		var test_dir2 = test_dir
		test_dir2.y = 0
		moveB = kbody.test_move(test_transform, test_dir2.normalized(), true)

	if (moveA == true) and (moveB == false):
		kbody.global_transform = test_transform
		kbody.velocity = test_dir
		kbody.velocity = kbody.move_and_slide(kbody.velocity, Vector3.UP)
