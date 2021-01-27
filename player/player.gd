extends KinematicBody

var is_noclip = false 

var current_weps = []
var active_wep_slot = 0

var velocity = Vector3()
var event = InputEventAction.new()

var _mouse_motion = Vector2()

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
onready var head = $Head
onready var raycast = $Head/RayCast
onready var selected_block_texture = $SelectedBlock
onready var voxel_world = $"../VoxelWorld"
onready var crosshair = $"../PauseMenu/Crosshair"
onready var active_wep_node = $"Head/Viewport/Camera/active_weapon"

# Adds a FreeModSwep to the player's current_weapons.
#    - swep_location is the directory of a .tscn file 
func add_wep(swep_location):
	var wep_scene = load(swep_location)
	var wep = wep_scene.instance()
	current_weps.append(wep)

func _ready():
	add_to_group("agent")
	add_to_group("human")
	if current_weps.size() == 0:
		# Eventually, this should only add the "unarmed" weapon.
		add_wep("res://weps/unarmed/unarmed.tscn")		
		add_wep("res://weps/test gun/testgun.tscn")
		add_wep("res://weps/striker/striker.tscn")
		wep_update()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	_mouse_motion.y = clamp(_mouse_motion.y, -1550, 1550)
	transform.basis = Basis(Vector3(0, _mouse_motion.x * -0.001, 0))
	head.transform.basis = Basis(Vector3(_mouse_motion.y * -0.001, 0, 0))

	if Input.is_action_just_pressed("noclip"):
		is_noclip = !is_noclip

	if Input.is_action_just_pressed("wep_yeet"):
		wep_yeet()
	
	if Input.is_action_just_released("wep_next"):
		active_wep_slot = active_wep_slot + 1
		active_wep_slot = wrapi(active_wep_slot, 0, current_weps.size())
		wep_update()

	if Input.is_action_just_released("wep_prev"):
		active_wep_slot = active_wep_slot - 1
		active_wep_slot = wrapi(active_wep_slot, 0, current_weps.size())
		wep_update()


# The code that handles walking. Mouse movements and camera rotations are handled separately.
# Called on physics_update when not in noclip mode.
func movement_normal(delta):
	# Crouching.
	var crouching = Input.is_action_pressed("crouch")
	if crouching:
		head.transform.origin = Vector3(0, 1.2, 0)
	else:
		head.transform.origin = Vector3(0, 1.6, 0)

	var W = Input.get_action_strength("move_forward")
	var A = Input.get_action_strength("move_left")
	var S = Input.get_action_strength("move_back")
	var D = Input.get_action_strength("move_right")

	var movement = Vector3(0,0,0)
	var walking = (W != 0) or (A != 0) or (S != 0) or (D != 0)
	var walk_speed = 5
	var friction = 1
	
	velocity.y -= gravity * delta

	if is_on_floor():
		if crouching:
			walk_speed = 1
		else:
			walk_speed = 5
		# TODO: friction should probably be a property of the floor material
		friction = 0.95
		if Input.is_action_pressed("jump"):
			velocity.y = 5

	if walking:
		movement = Vector3(D-A, 0, S-W).normalized()
		movement = transform.basis.xform(movement)
		# TODO: These constants should be put somewhere accessible
		var max_velocity = 5
		var accelDir = movement
		var prevVelocity = 0
		var speed = velocity.length()
		if speed != 0:
			var drop = speed * friction * delta
			prevVelocity = velocity * max(speed-drop, 0)/speed
			
		var accelerate = 15

		var projVel = prevVelocity.dot(accelDir)
		var accelVel = accelerate * delta
		if projVel + accelVel > max_velocity:
			accelVel = max_velocity - projVel

		velocity = prevVelocity + (accelDir*accelVel)
		movement = velocity
	else:
		movement = velocity*delta*friction
	
	#warning-ignore:return_value_discarded
	velocity = move_and_slide(Vector3(movement.x, velocity.y, movement.z), Vector3.UP)

func movement_noclip(delta):
	var W = Input.get_action_strength("move_forward")
	var A = Input.get_action_strength("move_left")
	var S = Input.get_action_strength("move_back")
	var D = Input.get_action_strength("move_right")

	var jump = Input.get_action_strength("jump")
	var crouch = Input.get_action_strength("crouch")

	
	var aim_dir = head.get_global_transform().basis.z
	var aim_right = head.get_global_transform().basis.x
	var movement = Vector3(D-A, 0, S-W).normalized()

	# TODO: Make the constant 10.0 settable
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
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_mouse_motion += event.relative


func chunk_pos():
	return (transform.origin / Chunk.CHUNK_SIZE).floor()
