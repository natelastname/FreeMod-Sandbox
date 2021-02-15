extends FreeModSwep

onready var anim_player = $"v_finger/AnimationPlayer"
onready var beam_light = $"beam_light"

var scroll_wheel_dist_inc = 1
var cast_dist = 1000
# Whether or not we currently have a grabbed object
var is_object_grabbed = false
# a reference to the object being grabbed, may become null between frames
var grabbed_object
# The transform of grabbed_object when it was grabbed.
var grabbed_object_transform
var player_transform_initial

# The position (in the grabbed object's local coords) that is grabbed
var grab_pos
# How far the grabbed object is supposed to be
var target_dist

# Where to put the cursor/beam when it is "off"
var beam_off_pos

# This flag makes is so that if you hold down LMB then press RMB,
# it stays deactivated until you press LMB again. If this is true, the
# physgun will fire when the player hits LMB. 
var beam_active
var obj_froze

# If this is true, the player is holding E and rotating the object.
var is_rotating_object


var mouse_motion = Vector2()


func raise_weapon():
	is_object_grabbed = false
	beam_active = true
	is_rotating_object = false
	obj_froze = false
	mouse_motion = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Finger"
	swep_desc = "The finger of God"
	# Since this does not have a prop, it cannot be thrown
	#swep_prop = "res://weps/mp5/mp5_prop.tscn"
	swep_path = "res://weps/finger/finger.tscn"
	beam_off_pos = beam_light.translation
	beam_active = true
	is_rotating_object = false
	obj_froze = false
	mouse_motion = Vector2(0,0)
	
# The player is holding "E" to rotate an object
func rotate_obj():
	var event = player.event
	if event is InputEventMouseMotion and player.mouse_locked:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_motion += event.relative
	player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)

# The physgun is dragging something.
# An issue with this method is that there is no way to move_and_slide a rigid body
# set to MODE_KINEMATIC. In the future when this is implemented, we might want to
# use it. For now, we directly set the translation.
# See: https://github.com/godotengine/godot/issues/30824
func translate_obj():

	# Stops the scroll wheel from changing weapons while dragging an object
	player.scroll_wheel_locked = true

	# It must be MODE_STATIC or physics will break
	assert(grabbed_object.get_mode() == 1)
	
	if target_dist > 3 and Input.is_action_just_released("wep_prev"):
		target_dist -= scroll_wheel_dist_inc

	if Input.is_action_just_released("wep_next"):
		target_dist += scroll_wheel_dist_inc

	if Input.is_action_just_pressed("wep_aim"):
		# change mode to MODE_STATIC (i.e., freeze) and release the object.
		grabbed_object.set_mode(1)
		player.scroll_wheel_locked = false
		is_object_grabbed = false
		beam_light.translation = beam_off_pos
		beam_active = false
		obj_froze = true
		anim_player.play("v_fingerAction",-1,1)
		anim_player.seek(0.0, true)
		
	var target_pos = player.raycast.to_global(Vector3(0,0,-1*target_dist))
	
	var mouse_motion_total = player.mouse_motion + mouse_motion
	var P2 = Basis(Vector3(mouse_motion_total.y * -0.001, mouse_motion_total.x * -0.001, 0))
	#grabbed_object.global_transform.origin = target_pos
	var B0 = grabbed_object_transform
	var P = player_transform_initial
	var B1 = grabbed_object.transform.basis
	
	grabbed_object.transform.basis = P2*P.inverse()*B0
	beam_light.global_transform.origin = target_pos-((grabbed_object.transform.basis)*grab_pos)
	grabbed_object.global_transform.origin = target_pos-((grabbed_object.transform.basis)*grab_pos)

# The physgun is firing, may or may not be hitting something that can be grabbed.
func grab_obj():
	player.scroll_wheel_locked = false
	beam_light.translation = beam_off_pos
	player.raycast.cast_to = Vector3(0,0,-1*cast_dist)
	if player.raycast.is_colliding():
		var obj = player.raycast.get_collider()
		var aim_dir = player.head.get_global_transform().basis.z
		var hit_point = player.raycast.get_collision_point()		
		if obj.is_class("StaticBody"):
			# can't grab the map
			is_object_grabbed = false
			return
		
		is_object_grabbed = true
		grabbed_object_transform = obj.transform.basis

		var mouse_motion = player.mouse_motion
		player_transform_initial = Basis(Vector3(mouse_motion.y * -0.001, mouse_motion.x * -0.001, 0))

		grabbed_object = obj
		grab_pos = obj.to_local(hit_point)
		target_dist = (hit_point-(player.global_transform.origin)).length()
		
		# Set mode to MODE_KINEMATIC (i.e., take control of the rigid body.)
		#grabbed_object.set_mode(3)
		
		# Set mode to MODE_STATIC so that physics doesn't break
		grabbed_object.set_mode(1)
	else:
		is_object_grabbed = false


# This is called every frame when the player is dragging an object.
func dragging_object():
	if not is_instance_valid(grabbed_object):
		# The object was deleted. (TODO: Test this)
		player.scroll_wheel_locked = false
		is_object_grabbed = false
	elif Input.is_action_pressed("use"):
		# The object is being rotated.
		player.mouse_locked = true
		rotate_obj()
	else:
		# The player is dragging a valid object.
		player.mouse_locked = false
		translate_obj()

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):
	# We choose not to use the pointing animation for simpler code.
	# TODO: Code the animations better.
	
	if Input.is_action_just_released("wep_fire"):
		# Prevent holding down wep_fire from causing it to fire automatically
		beam_active = true
		mouse_motion = Vector2(0,0)
		if not is_instance_valid(grabbed_object):
			pass
		elif grabbed_object.get_mode() == 3:
			# If the object grabbed last was left in MODE_KINEMATIC, it was not frozen.
			grabbed_object.set_mode(0)
			grabbed_object = null
		elif not obj_froze:
			# Unfreeze the prop.
			grabbed_object.set_mode(0)
			grabbed_object = null
		elif obj_froze:
			# Leave the prop frozen.
			obj_froze = false
			grabbed_object.set_mode(1)
			grabbed_object = null
	
	if Input.is_action_pressed("wep_fire") and beam_active:
		# The player is firing the physgun.
		anim_player.play("v_fingerAction",-1,1)
		anim_player.seek(0.3, true)
		if is_object_grabbed:
			dragging_object()
		else:
			grab_obj()
	else:
		# The player is not firing the physgun.
		player.scroll_wheel_locked = false
		is_object_grabbed = false
		beam_light.translation = beam_off_pos
		anim_player.play("v_fingerAction",-1,1)
		anim_player.seek(0.0, true)
