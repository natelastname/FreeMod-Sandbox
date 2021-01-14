# This stores the player's weapons and handles the weapon selection HUD.
extends Label

onready var player = $"../Player"

var current_weps = []
var active_wep_slot = 0


func _init():
	print("test")	
	._init()
	

func _process(_delta):

	if current_weps.size() == 0:
		var default = load("res://weps/unarmed/unarmed.gd")
		current_weps.append(default)

	if Input.is_action_just_released("wep_next") and active_wep_slot < current_weps.size() - 1:
		active_wep_slot = active_wep_slot + 1
	if Input.is_action_just_released("wep_prev") and active_wep_slot > 0:
		active_wep_slot = active_wep_slot - 1


		
	text = str(active_wep_slot)
