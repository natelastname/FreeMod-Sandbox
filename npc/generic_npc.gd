extends KinematicBody

class_name generic_npc

# Movement params
# These can be set to the same params as the player, or be modified

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jump_velocity = 5
var stopspeed = 3
var max_speed = 10
var max_velocity = 5
var friction_floor = 2.5
var friction_air = 0
var friction = friction_air

var movement_accel = 0
var walk_speed_sprint = 30
var walk_speed_normal = 20
var walk_speed_crouch = 10

var on_floor = false

# the position it is supposed to be walking towards.
var wish_dir = Vector3(0,0,0)
var velocity = Vector3(0,0,0)

func apply_damage(amt):
	pass
	
func _init():
	add_to_group("npc")

func npc_physics_process(delta):
	pass

func _physics_process(delta):
	# Expects wish_dir (and possibly other movement params) to be updated
	# by this function. It will move the NPC accordingly.
	npc_physics_process(delta)
	
	velocity.y -= gravity * delta
	on_floor = is_on_floor()
	if on_floor:
		friction = friction_floor
	else:
		friction = friction_air
	
	MovementUtil.movement_normal(delta, self, wish_dir)

