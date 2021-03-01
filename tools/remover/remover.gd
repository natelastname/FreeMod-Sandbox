extends FreeModTool

var remove_sound = preload("res://sounds/spark.wav")
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

var player
var tool_hud

var cursor = preload("res://weps/shared/beam_light.tscn")
var cursor_fact
var active_cursor

func _init():
	sound_direct_fact = sound_direct.instance() 
	player = $"/root/World/Player"
	tool_hud = $"/root/World/CanvasLayer/tool_hud"
	cursor_fact = cursor.instance()
	active_cursor = cursor_fact.duplicate()
	player.add_child(active_cursor)
	tool_hud.set_message("Select an object to remove.")
	tool_hud.visible = true

	
func fmtool_equipped():
	active_cursor = cursor_fact.duplicate()
	player.add_child(active_cursor)
	tool_hud.visible = true
	print("tool equipped")

func fmtool_unequipped():
	active_cursor.queue_free()
	tool_hud.visible = false
	print("tool unequipped")

func fmtool_use():
	player.raycast.cast_to = Vector3(0,0,-500)
	var removed_something = false
	if player.raycast.is_colliding():
		var object_hit = player.raycast.get_collider()
		if object_hit is RigidBody:
			object_hit.queue_free()
			removed_something = true
		if object_hit is KinematicBody:
			object_hit.queue_free()
			removed_something = true

	if removed_something:
		var sound = sound_direct_fact.duplicate()
		add_child(sound)
		sound.volume_db = -5
		sound.play_sound(remove_sound)

func fmtool_process(_delta):
	player.raycast.cast_to = Vector3(0,0,-500)
	if player.raycast.is_colliding():
		var point_hit = player.raycast.get_collision_point()
		active_cursor.global_transform.origin = point_hit
		active_cursor.visible = true
	else:
		active_cursor.visible = false
