extends Spatial

# This is the class of all scripted weapons (SWEPs.)
# A SWEP is an object that has an entry in the weapon selection bar, can be
# thrown/picked up and has an FPS-style viewmodel.
# There is no requirement that a SWEP has to actually be a weapon. SWEPs are 
# free to do anything they want to the node tree. 

class_name FreeModSwep

onready var player = $"/root/World/map/Player"

export(String) var swep_name = "Default SWEP name"
export(String) var swep_desc = "Default SWEP description"
export(String) var swep_prop = "NONE"
export(String) var swep_path = "NONE"
export(int) var swep_inv_slot = 1


# These must be defined for the ammo HUD display to work, but there is no
# obligation to actually use them.
var ammo = 0
var mags = 0


# NOTE: The wep's viewmodel must be facing in the -z direction and its mesh
# instance must only have visibility layer 2 checked.

# called when the weapon is activated
func raise_weapon():
	pass

# called when the weapon is put away
func lower_weapon():
	pass

# This should be used instead of _process because allows sweps to be disabled
# when appropriate (e.g., clicking in a menu should not cause weapons to shoot)
func swep_process(_delta):
	pass

func _process(_delta):
	if player.input_locked == false:
		swep_process(_delta)
	
