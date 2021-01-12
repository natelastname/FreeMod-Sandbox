extends Label
# Displays some useful debug information in a Label.
onready var player = $"../Player"

var current_weps = []
var active_wep = 0

func _process(_delta):
	
	if Input.is_action_just_released("wep_next"):
		active_wep = active_wep + 1
	if Input.is_action_just_released("wep_prev"):
		active_wep = active_wep - 1
	
	text = str(active_wep)
