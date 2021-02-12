extends FreeModSwep

onready var anim_player = $"v_finger/AnimationPlayer"
onready var beam_light = $"beam_light"

var scroll_wheel_dist_inc = 1
var cast_dist = 1000
# Whether or not we currently have a grabbed object
var is_object_grabbed = false
# a reference to the object being grabbed, if any
var grabbed_object
# The position (in the grabbed object's local coords) that is grabbed
var grab_pos
# How far the grabbed object is supposed to be
var target_dist


var beam_off_pos


func raise_weapon():
	is_object_grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Finger"
	swep_desc = "The finger of God"
	#swep_prop = "res://weps/mp5/mp5_prop.tscn"
	swep_path = "res://weps/finger/finger.tscn"
	beam_off_pos = beam_light.translation

# The physgun is dragging something
func translate_obj():
	player.scroll_wheel_locked = true

	if target_dist > 3:
		if Input.is_action_just_released("wep_next"):
			target_dist += scroll_wheel_dist_inc
		if Input.is_action_just_released("wep_prev"):
			target_dist -= scroll_wheel_dist_inc
	
	var target_pos = player.raycast.to_global(Vector3(0,0,-1*target_dist))
	beam_light.global_transform.origin = target_pos
	grabbed_object.global_transform.origin = target_pos-grab_pos
	
	

# The physgun is firing, but may or may not be hitting something
func grab_obj():
	player.scroll_wheel_locked = false
	beam_light.translation = beam_off_pos
	player.raycast.cast_to = Vector3(0,0,-1*cast_dist)
	if player.raycast.is_colliding():
		var obj = player.raycast.get_collider()
		var aim_dir = player.head.get_global_transform().basis.z
		var hit_point = player.raycast.get_collision_point()

		if obj.is_class("StaticBody"):
			is_object_grabbed = false
			return
		
		is_object_grabbed = true
		grabbed_object = obj
		grab_pos = hit_point-obj.global_transform.origin
		target_dist = (hit_point-(player.global_transform.origin)).length()
		
		#if obj.is_class("RigidBody"):
			#obj.apply_central_impulse(aim_dir*-5)
		#if obj.is_class("KinematicBody"):
			#obj.velocity += aim_dir.normalized()*-50.0
	else:
		is_object_grabbed = false
		

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):
	# We choose not to use the pointing animation for responsiveness and simpler code.
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("v_fingerAction",-1,1)
		anim_player.seek(0.3, true)
		if is_object_grabbed:
			# TODO: Test if the grabbed object has been removed or something
			translate_obj()
		else:
			grab_obj()
		return
	player.scroll_wheel_locked = false
	is_object_grabbed = false
	beam_light.translation = beam_off_pos
	anim_player.play("v_fingerAction",-1,1)
	anim_player.seek(0.0, true)
