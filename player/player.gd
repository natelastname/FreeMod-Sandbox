extends KinematicBody

var is_noclip = false 

var current_weps = []
var active_wep_slot = 0

var crouching = false
var sprinting = false
var velocity = Vector3()

var event = InputEventAction.new()
var mouse_motion = Vector2()

onready var head = $"Head"
onready var raycast = $Head/RayCast
#onready var selected_block_texture = $SelectedBlock
#onready var crosshair = $"../PauseMenu/Crosshair"
onready var active_wep_node = $"viewmodel_viewport/Camera/active_weapon"
onready var main_cam = $"camera_viewport/Camera"

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_velocity = 5
var max_velocity = 5
var movement_accel = 15
var noclip_speed_normal = 10
var noclip_speed_crouch = 1
var walk_speed_normal = 5
var walk_speed_crouch = 2.5
var walk_speed_sprint = 7.5
# TODO: this should probably be a property of the floor material
var friction_floor = 5
var friction_air = 0
var friction = friction_air

var on_floor = false

var camera_pos_normal
var camera_pos_crouch 

# Controls whether the player responds to WASD inputs.
var move_locked = false
# Controls whether the player responds to mouse movements. Setting this is NOT
# neccessary when opening a menu since changing the mouse mode has the same effect.
var mouse_locked = false
# Whether the player responds to wep_fire, wep_reload, any other kind of input.
var input_locked = false
# This is specifically for the physgun so it can use the mouse wheel
var scroll_wheel_locked = false


# Adds a FreeModSwep to the player's current_weapons.
#    - swep_location is the directory of a .tscn file 
func add_wep(swep_location):
	var wep_scene = load(swep_location)
	var wep = wep_scene.instance()
	current_weps.append(wep)	

var debug1
func _ready():
	debug1 = Vector3(0,0,0)
	camera_pos_normal = head.transform.origin
	camera_pos_crouch = head.transform.origin-Vector3(0,1,0)
	raycast.collide_with_areas = false
	raycast.collide_with_bodies = true
	add_to_group("agent")
	add_to_group("human")
	if current_weps.size() == 0:
		# Eventually, this should only add the "unarmed" weapon.
		add_wep("res://weps/unarmed/unarmed.tscn")		
		add_wep("res://weps/finger/finger.tscn")		
		add_wep("res://weps/wrench/wrench.tscn")		
		#add_wep("res://weps/test gun/testgun.tscn")
		add_wep("res://weps/mp5/mp5_viewmodel.tscn")
		wep_update()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	crouching = false
	sprinting = false

	
# Triggers a weapon switch according to the values of current_weps and active_wep_slot
var first_wep_update = true
func wep_update():
	if first_wep_update:
		first_wep_update = false
	else:
		active_wep_node.lower_weapon()
	var weapon_parent = active_wep_node.get_parent()
	var new_wep = current_weps[active_wep_slot]
	weapon_parent.remove_child(active_wep_node)
	new_wep.name = active_wep_node.name
	weapon_parent.add_child(new_wep)
	active_wep_node = new_wep
	new_wep.raise_weapon()
	
# throws the current weapon
func wep_yeet():
	if current_weps[active_wep_slot].swep_prop == "NONE":
		print("Can't throw wep with no prop.")
		return

	# spawn the current weapon's prop with some forward velocity
	# somehow make this prop collectable
	var prop = load(active_wep_node.swep_prop).instance()
	var aim_dir = head.get_global_transform().basis.z

	# spawn 1.0 units in the aim direction, throw with 5.0 units of force
	
	var prop_spawn_pos = self.translation+head.translation-aim_dir
	var prop_spawn_dir = -aim_dir + to_global(Vector3(1.0,0.0,0.0))
	var prop_spawn_up = Vector3(0.0,1.0,0.0)
	prop.look_at_from_position(prop_spawn_pos, prop_spawn_dir, prop_spawn_up)
	prop.apply_central_impulse(aim_dir*-5)

	# TODO: Preload this? May be causing a lag spike
	var collectable_script = load("res://collectable/collectable.gd")
	prop.set_script(collectable_script)
	prop.add_wep_on_collect = active_wep_node.swep_path
	
	self.get_parent().add_child(prop)
	# remove weapon, switch to Unarmed
	current_weps.remove(active_wep_slot)
	active_wep_slot = 0
	wep_update()	

# called every frame
func _process(_delta):
	# Mouse movement.
	mouse_motion.y = clamp(mouse_motion.y, -1550, 1550)
	if mouse_locked == false:
		transform.basis = Basis(Vector3(0, mouse_motion.x * -0.001, 0))
		head.transform.basis = Basis(Vector3(mouse_motion.y * -0.001, 0, 0))

	if input_locked:
		return
	
	if Input.is_action_just_pressed("noclip"):
		is_noclip = !is_noclip

	if Input.is_action_just_pressed("wep_yeet"):
		wep_yeet()
			
	if scroll_wheel_locked == false:
		if Input.is_action_just_released("wep_next"):
			active_wep_slot = active_wep_slot + 1
			active_wep_slot = wrapi(active_wep_slot, 0, current_weps.size())
			wep_update()

		if Input.is_action_just_released("wep_prev"):
			active_wep_slot = active_wep_slot - 1
			active_wep_slot = wrapi(active_wep_slot, 0, current_weps.size())
			wep_update()


func _friction(vel, delta):

	var speed = vel.length()
	if speed == 0:
		return Vector3(0,0,0)

	var ctl = min(speed, max_velocity)
	var newspeed = speed - (delta*friction*ctl)
	if newspeed < 0:
		newspeed = 0

	return (velocity/speed)*newspeed

# The code that handles walking. Mouse movements and camera rotations are handled separately.
# Called on physics_update when not in noclip mode.
func movement_normal(delta):


	sprinting = Input.is_action_pressed("run")
	# this doesn't effect the player's hitbox
	crouching = Input.is_action_pressed("crouch")
	if crouching:
		head.transform.origin = camera_pos_crouch
	else:
		head.transform.origin = camera_pos_normal

	var W = Input.get_action_strength("move_forward")
	var A = Input.get_action_strength("move_left")
	var S = Input.get_action_strength("move_back")
	var D = Input.get_action_strength("move_right")

	# Guarentees that having movement locked doesn't change physics.
	if move_locked:
		W = 0
		A = 0
		S = 0
		D = 0
	
	var is_walking = (D-A) != 0 or (S-W) != 0
	var walk_speed = 0	
	var wish_dir = Vector3(D-A, 0, S-W).normalized()
	wish_dir = transform.basis.xform(wish_dir)

	friction = friction_air
	# gravity needs to be applied here for is_on_floor to work.
	velocity.y -= gravity * delta
	on_floor = is_on_floor()
	if on_floor:
		friction = friction_floor
		if crouching:
			walk_speed = walk_speed_crouch
		elif sprinting:
			walk_speed = walk_speed_sprint
		else:
			walk_speed = walk_speed_normal
		

	velocity = _friction(velocity,delta)		

	# How fast the player is going in the direction that they want to go
	var current_speed = velocity.dot(wish_dir)

	# How hard the player is pushing to go the direction they want to move
	var accelVel = movement_accel * delta

	if current_speed + accelVel > max_velocity:
		accelVel = max_velocity - current_speed
	
	if on_floor and Input.is_action_pressed("jump"):
		velocity.y = jump_velocity

	velocity = velocity + (wish_dir*accelVel)		
	velocity = move_and_slide(velocity, Vector3.UP)


func movement_noclip(delta):
	
	if move_locked:
		return

	var W = Input.get_action_strength("move_forward")
	var A = Input.get_action_strength("move_left")
	var S = Input.get_action_strength("move_back")
	var D = Input.get_action_strength("move_right")
	
	var jump = Input.get_action_strength("jump")
	var crouch = Input.get_action_strength("crouch")
	
	var aim_dir = head.get_global_transform().basis.z
	var aim_right = head.get_global_transform().basis.x
	var movement = Vector3(D-A, 0, S-W).normalized()

	var move_speed = noclip_speed_normal
	
	if crouch:
		move_speed = noclip_speed_crouch

	# possibly a bug:
	# If you look up and press jump at the same time, you move faster
	
	self.translation += aim_dir*(S-W)*10.0*delta
	self.translation += aim_right*(D-A)*10.0*delta
	self.translation += (Vector3.UP)*(jump-crouch)*10.0*delta
	
func _physics_process(delta):
	if is_noclip:
		movement_noclip(delta)
	else:
		movement_normal(delta)


func _input(ev):
	event = ev
	if event is InputEventMouseMotion and mouse_locked == false:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_motion += event.relative

# unused?
func chunk_pos():
	return (transform.origin / Chunk.CHUNK_SIZE).floor()
