extends FreeModTool

var remove_sound = preload("res://sounds/spark.wav")
var sound_direct = preload("res://audio/sound_direct.tscn")
var player
var sound_direct_fact 

func _init():
	sound_direct_fact = sound_direct.instance() 
	player = $"/root/World/Player"
	
func fmtool_equipped():
	print("tool equipped")

func fmtool_unequipped():
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
	if Input.is_action_just_pressed("wep_fire"):
		pass
