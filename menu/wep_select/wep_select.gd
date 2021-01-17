# This stores the player's weapons and handles the weapon selection HUD.
extends Label

onready var player = $"/root/World/Player"

var current_weps = []
var active_wep_slot = 0


func _init():
	._init()
	

func _process(_delta):
	var changed = false

	if current_weps.size() == 0:
		var default_wep_scene = load("res://weps/test gun/testgun.tscn")
		var default_wep = default_wep_scene.instance()
		current_weps.append(default_wep)
		changed = true
		
	if Input.is_action_just_released("wep_next") and active_wep_slot < current_weps.size() - 1:
		active_wep_slot = active_wep_slot + 1
		changed = true
		
	if Input.is_action_just_released("wep_prev") and active_wep_slot > 0:
		active_wep_slot = active_wep_slot - 1
		changed = true

		
	if changed:
		# current path: /root/World/Player/wep_select
		var active_wep_node = $"../Head/Camera/active_weapon"
		active_wep_node.replace_by(current_weps[active_wep_slot])


		
	text = str(active_wep_slot)
