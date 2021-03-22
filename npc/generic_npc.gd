# NPC is a misnomer because the player is an NPC.
class_name generic_npc

extends KinematicBody

export(int) var npc_health = 100
# Movement params
# These are set to be the same params as the player. Can be modified by NPCs
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
export(float) var jump_velocity = 10
# If the player's speed is below stopspeed, _friction behaves as if the npc's
# speed was equal to stopspeed.  
export(float) var stopspeed = 10
export(float) var max_speed = 10
export(float) var max_velocity = 5
export(float) var friction_floor = 1
export(float) var friction_air = 0
export(float) var friction = friction_air
# The maximum height of a ledge that can be automatically scaled
export(float) var step_height = 1.05

var health = npc_health
var step_offset = (step_height)*Vector3.UP
var movement_accel = 0
var on_floor = false
# the position it is supposed to be walking towards.
var wish_dir = Vector3(0,0,0)
var velocity = Vector3(0,0,0)
var phys_disabled = false

func trigger_death():
	pass

func npc_damaged():
	pass

func npc_physics_process(delta):
	pass

func _init():
	add_to_group("agent")

func apply_damage(amt):
	if health <= 0:
		# they're already dead
		return
	health = health - amt
	if health <= 0:
		trigger_death()
	else:
		npc_damaged()


func _friction(delta):
	
	var speed = velocity.length()
	if speed == 0:
		return Vector3(0,0,0)

	var ctl = max(speed, stopspeed)

	var newspeed = speed - (delta*friction*ctl)
	if newspeed < 0:
		newspeed = 0

	return velocity*(newspeed/speed)

# TODO: There should be something that accounts for the height of a step.
# E.g., if a step is 0.1 tall and you get boosted up 1, then you fall 0.9.
# instead, it should boost the player up 0.1+epsilon
func movement_normal(delta, wish_dir):
	var length = wish_dir.length()
	if length > 0:
		wish_dir = wish_dir/length
	
	velocity = _friction(delta)		
	# How fast the player is going in the direction that they want to go
	var current_speed = velocity.dot(wish_dir)
	# How hard the player is pushing to go the direction they want to move
	var accelVel = (movement_accel) * delta
	
	if current_speed + accelVel > max_speed:
		# we are going as fast as we are allowed to go (in the direction of wish_dir)
		accelVel = max_speed - current_speed

	velocity = velocity + (wish_dir*accelVel)

	var test_dir = velocity
	test_dir.y = 0
	var test_transform = global_transform

	var on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	var moveA = is_on_wall() and on_floor
	#var moveA = is_on_wall()
	var moveB = true
	
	if moveA:
		# we have hit a wall.
		test_transform.origin = test_transform.origin + step_offset + (test_dir*0.1)
		# clear the y compotent because it causes test_move to return true due to a
		# collision with the floor.
		var test_dir2 = test_dir
		test_dir2.y = 0
		test_dir2 = test_dir2.normalized()
		moveB = test_move(test_transform, test_dir2, true)

	if (moveA == true) and (moveB == false):
		# The conditions are met, perform the boost.
		global_transform = test_transform
		velocity = test_dir
		velocity = move_and_slide(velocity, Vector3.UP)		
	

func _physics_process(delta):

	if phys_disabled:
		velocity = Vector3(0,0,0)
		return
	
	# Expects wish_dir (and possibly other movement params) to be updated
	# by this function. It will move the NPC accordingly.
	velocity.y -= gravity * delta
	on_floor = is_on_floor()
	npc_physics_process(delta)

	if on_floor:
		friction = friction_floor
	else:
		friction = friction_air
	
	movement_normal(delta, wish_dir)

