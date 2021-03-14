extends KinematicBody

# NPC is a misnomer because the player is an NPC.
class_name generic_npc

export(int) var npc_health = 100
var health = npc_health

# Movement params
# These are set to be the same params as the player. Can be modified by NPCs
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jump_velocity = 7.5
# If the player's speed is below stopspeed, _friction behaves as if the npc's
# speed was stopspeed.  

var stopspeed = 10
var max_speed = 10
var max_velocity = 5
var friction_floor = 1
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

var phys_disabled = false

func trigger_death():
	pass

func npc_damaged():
	pass


func apply_damage(amt):
	health = health - amt
	if health <= 0:
		trigger_death()
	else:
		npc_damaged()
	
	
func _init():
	phys_disabled = false
	add_to_group("npc")

func npc_physics_process(delta):
	pass

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
	
	MovementUtil.movement_normal(delta, self, wish_dir)

