extends Spatial

class_name FreeModSwep

onready var player = $"/root/World/Player"

export(String) var swep_name = "Default SWEP name"
export(String) var swep_desc = "Default SWEP description"
export(String) var swep_prop = "NONE"
export(String) var swep_path = "NONE"
export(int) var swep_inv_slot = 1


func raise_weapon():
	pass

func lower_weapon():
	pass

# This should be used instead of _process because allows sweps to be disabled
# when appropriate (e.g., clicking in a menu should not cause weapons to shoot)
func swep_process(_delta):
	pass

func _process(_delta):
	if player.input_locked == false:
		swep_process(_delta)
	
