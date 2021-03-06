extends FreeModSwep

onready var anim_player = $"v_finger/AnimationPlayer"
onready var beam_light = $"beam_light"

var scroll_wheel_dist_inc = 1
var cast_dist = 1000
# Whether or not we currently have a grabbed object
var is_object_grabbed = false
# a reference to the object being grabbed, may become null between frames
var grabbed_object
# The rotation matrix of grabbed_object when it was grabbed.
var obj_rotate_initial
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
# This is not implemented right now, but perhaps it should be 
var is_rotating_object

var obj_rotate

var mouse_motion = Vector2()

func raise_weapon():
	is_object_grabbed = false
	beam_active = true
	is_rotating_object = false
	obj_froze = false
	mouse_motion = Vector2(0,0)
	player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)
	obj_rotate = Basis(Vector3(0, 0, 0))

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.set_animation_process_mode(AnimationPlayer.ANIMATION_PROCESS_MANUAL)
	anim_player.play("v_fingerAction",-1,1)

	beam_off_pos = beam_light.translation
	beam_active = true
	is_rotating_object = false
	obj_froze = false
	mouse_motion = Vector2(0,0)
	player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)
	obj_rotate = Basis(Vector3(0, 0, 0))
	beam_light.visible = false

var in_snap_mode = false
# The player is holding "E" to rotate an object
func rotate_obj():
	var event = player.event
	if event is InputEventMouseMotion and player.mouse_locked:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_motion += event.relative
	
	var p_rotate = Basis(Vector3(player.mouse_motion.y * -0.001, player.mouse_motion.x * -0.001, 0))
			
	var a = mouse_motion.y*-0.001
	var b = mouse_motion.x*-0.001
	# Snap to 45 degree = PI/4 increments
	if Input.is_action_pressed("run"):
		in_snap_mode = true
		a = round(a/(PI/4))*(PI/4)
		b = round(b/(PI/4))*(PI/4)
		obj_rotate_initial = Basis(Vector3(0,0,0))
		player_transform_initial = Basis(Vector3(0,0,0))
		grab_pos = Vector3(0,0,0)
		var v = Vector3(a, b, 0)
		obj_rotate = (p_rotate.inverse())*Basis(v)
		player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)
		translate_obj()
		return
	elif in_snap_mode == true:
		in_snap_mode = false
		obj_rotate_initial = grabbed_object.transform.basis
		var m_motion = player.mouse_motion
		player_transform_initial = Basis(Vector3(m_motion.y * -0.001, m_motion.x * -0.001, 0))
		a = 0
		b = 0
		mouse_motion = Vector2(0,0)

	var v = Vector3(a, b, 0)
	obj_rotate = Basis(v)
	player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)
	translate_obj()

# The physgun is dragging something.
# An issue with this method is that there is no way to move_and_slide a rigid body
# set to MODE_KINEMATIC. In the future when this is implemented, we might want to
# use it. For now, we directly set the translation.
# See: https://github.com/godotengine/godot/issues/30824
func translate_obj():

	# Stops the scroll wheel from changing weapons while dragging an object
	player.scroll_wheel_locked = true

	if grabbed_object.is_class("RigidBody"):
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
	# used to rotate the object around the player
	var p_rotate = Basis(Vector3(player.mouse_motion.y * -0.001, player.mouse_motion.x * -0.001, 0))

	# Apply the object's rotation, and then the rotation of the player's head.
	p_rotate = p_rotate * obj_rotate
	var B0 = obj_rotate_initial
	var P = player_transform_initial

	# These two factors allow the object to be affected by its initial rotation.
	# E.g., if you grab an object that is upside down, it will stay that way.
	grabbed_object.transform.basis = p_rotate*P.inverse()*B0

	grabbed_object.global_transform.origin = target_pos-((grabbed_object.transform.basis)*grab_pos)
	beam_light.global_transform.origin = target_pos-((grabbed_object.transform.basis)*grab_pos)	

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
		obj_rotate_initial = obj.transform.basis

		var m_motion = player.mouse_motion
		player_transform_initial = Basis(Vector3(m_motion.y * -0.001, m_motion.x * -0.001, 0))
		
		grabbed_object = obj
		grab_pos = obj.to_local(hit_point)
		target_dist = (hit_point-(player.global_transform.origin)).length()

		if obj.is_class("RigidBody"):
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
		in_snap_mode = false
		player.mouse_locked = false
		translate_obj()

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
var time_accumulated = 0
var end_time = 0
func swep_process(_delta):
	if end_time < time_accumulated:
		time_accumulated = end_time
		anim_player.seek(end_time, true)
		
	if time_accumulated+_delta > end_time:
		time_accumulated = end_time
		anim_player.seek(end_time, true)
	else:
		time_accumulated += _delta
		anim_player.advance(_delta)
		return
	
	if Input.is_action_just_pressed("jump"):
		print("accumulated:"+str(time_accumulated))
		print("end:"+str(end_time))

	# We choose not to use the pointing animation for simpler code.
	# TODO: Code the animations better.
	if Input.is_action_just_released("wep_fire"):
		beam_light.visible = false
		# Prevent holding down wep_fire from causing it to fire every frame.
		beam_active = true
		player.debug1 = Vector3(mouse_motion.x, mouse_motion.y, 0.0)
		player.mouse_locked = false
		obj_rotate = Basis(Vector3(0, 0, 0))
		if not is_instance_valid(grabbed_object):
			pass
		elif grabbed_object.is_class("KinematicBody"):
			grabbed_object = null
		elif grabbed_object.get_mode() == 3:
			# If the object grabbed last was left in MODE_KINEMATIC, it was not frozen.
			grabbed_object.set_mode(0)
			grabbed_object = null
		elif not obj_froze:
			# Unfreeze the prop.
			grabbed_object.set_mode(0)
			# This should force the physics to be updated
			grabbed_object.apply_central_impulse(Vector3(0,0.001,0))
			grabbed_object.apply_central_impulse(Vector3(0,-0.001,0))
			grabbed_object = null
		elif obj_froze:
			# Leave the prop frozen.
			obj_froze = false
			grabbed_object.set_mode(1)
			grabbed_object = null
	
	if Input.is_action_pressed("wep_fire") and beam_active:
		end_time = 0.28
		if time_accumulated > end_time:
			anim_player.seek(0.0)
			time_accumulated = 0
		# The player is firing the physgun.
		if is_object_grabbed:
			beam_light.visible = true
			dragging_object()
		else:
			beam_light.visible = false
			grab_obj()
	else:
		# The player is not firing the physgun.
		player.scroll_wheel_locked = false
		is_object_grabbed = false
		beam_light.translation = beam_off_pos
		if time_accumulated > 0:
			end_time = anim_player.get_current_animation_length()
