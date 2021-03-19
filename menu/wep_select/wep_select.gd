extends Label

onready var player = $"/root/World/map/Player"


func _init():
	._init()
	

func _process(_delta):
	text = str(player.active_wep_slot)+":"
	text += str(player.current_weps[player.active_wep_slot].swep_name)
