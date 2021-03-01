extends FreeModTool

var remove_sound = preload("res://sounds/spark.wav")
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

var prop_node
var player
var tool_hud

var cursor = preload("res://weps/shared/beam_light.tscn")
var cursor_fact
var active_cursor

var object_A
var object_B

func _init():
	sound_direct_fact = sound_direct.instance() 
	player = $"/root/World/Player"
	tool_hud = $"/root/World/CanvasLayer/tool_hud"
	prop_node = $"/root/World/props"
	cursor_fact = cursor.instance()
	active_cursor = cursor_fact.duplicate()
	player.add_child(active_cursor)
	tool_hud.set_message("Select object A.")
	tool_hud.visible = true

func fmtool_equipped():
	active_cursor = cursor_fact.duplicate()
	player.add_child(active_cursor)
	tool_hud.visible = true

func fmtool_unequipped():
	active_cursor.queue_free()
	tool_hud.visible = false

func weld_objects():
	
	for child in object_B.get_children():
		object_B.remove_child(child)
		object_A.add_child(child)
		child.set_owner(object_A)
		
		print("------------------")
		var A = object_B.transform.xform(child.transform.origin)
		var B = object_A.transform.xform_inv(A)
		child.transform.origin = B
		var X = child.transform.basis
		var Y = object_A.transform.basis
		child.transform.basis = (Y.inverse())*X
		

	#object_A.queue_free()
	#object_B.queue_free()
		
	object_A = null
	object_B = null
	tool_hud.set_message("Select object A.")

	
func fmtool_use():
	player.raycast.cast_to = Vector3(0,0,-500)
	var removed_something = false
	if player.raycast.is_colliding():
		var object_hit = player.raycast.get_collider()
		if object_hit is RigidBody:
			if is_instance_valid(object_A):
				object_B = object_hit
				weld_objects()
			else:
				object_A = object_hit
				tool_hud.set_message("Select object B.")
		
	#var sound = sound_direct_fact.duplicate()
	#add_child(sound)
	#sound.volume_db = -5
	#sound.play_sound(remove_sound)

func fmtool_process(_delta):
	player.raycast.cast_to = Vector3(0,0,-500)
	if player.raycast.is_colliding():
		var point_hit = player.raycast.get_collision_point()
		active_cursor.global_transform.origin = point_hit
		active_cursor.visible = true
	else:
		active_cursor.visible = false
