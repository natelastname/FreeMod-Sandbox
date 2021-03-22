extends generic_npc

export(float) var walk_speed_sprint = 30
export(float) var walk_speed_normal = 20
export(float) var walk_speed_crouch = 10
export(float) var noclip_speed_normal = 10
export(float) var noclip_speed_crouch = 1

var is_noclip = false 
var crouching = false
var sprinting = false

var current_weps = []
var active_wep_slot = 0

var event = InputEventAction.new()
var mouse_motion = Vector2()

onready var head = $"Head"
onready var raycast = $"Head/RayCast"
onready var wep_select_bar = $"CanvasLayer/wep_menu" 
onready var active_wep_node = $"viewmodel_viewport/Camera/active_weapon"
onready var main_cam = $"camera_viewport/Camera"


var camera_pos_normal
var camera_pos_crouch

var active_wep_col = 0
var active_wep_row = 0

# Controls whether the player responds to WASD inputs.
var move_locked = false
# Controls whether the player responds to mouse movements. Setting this is NOT
# neccessary when opening a menu since changing the mouse mode has the same effect.
var mouse_locked = false
# Whether the player responds to wep_fire, wep_reload, any other kind of input.
var input_locked = false
# This is specifically for the physgun so it can use the mouse wheel w/o
# causing the player to change weapons
var scroll_wheel_locked = false

var wep_scenes

# Adds a FreeModSwep to current_weapons, updates wep_select_bar accordingly.
#    - swep_location is the directory of a .tscn file 
func add_wep(swep_location):
	if not swep_location in wep_scenes:
		print("Warning: could not add weapon: "+swep_location)
		return
	var wep_scene = wep_scenes[swep_location]
	var wep = wep_scene.instance()
	print("adding weapon "+swep_location+" in slot "+str(wep.swep_inv_slot) )
	current_weps[wep.swep_inv_slot-1].append(wep)
	wep_select_bar.add_weapon(wep)

# Returns [wep_col, wep_row] if there is a swep with the given value of swep_path
# in current_weps, null otherwise.
func get_wep_index(swep_path):
	for i in range(0, current_weps.size()):
		for j in range(0, current_weps[i].size()):
			var swep2 = current_weps[i][j]
			if swep2.swep_path == swep_path:
				return [i, j]
	return null

# Switch to the weapon in current_weps with the given value of swep_path.
# Returns true/false based on whether or not the weapon switch succeeded
func equip_wep_by_path(swep_path):
	var ind = get_wep_index(swep_path)
	if ind == null:
		return false
	active_wep_col = ind[0]
	active_wep_row = ind[1]
	wep_update()	
	return true

# removes a FreeModSwep from current_weapons, updates wep_select_bar accordingly.
func remove_wep(swep):
	print("removing "+swep.swep_path)

	var wep_row = 0
	var wep_col = 0

	for i in range(0, current_weps.size()):
		for j in range(0, current_weps[i].size()):
			var swep2 = current_weps[i][j]
			if swep2.swep_path == swep.swep_path:
				wep_col = i
				wep_row = j
				break
	
	assert(wep_row < current_weps[wep_col].size())
	assert(not ((wep_row == 0) and (wep_col == 0)))

	current_weps[wep_col].remove(wep_row)

	if wep_col == active_wep_col and wep_row == active_wep_row:
		active_wep_col = 0
		active_wep_row = 0
	elif wep_col == active_wep_col and wep_row < active_wep_row:
		active_wep_row = active_wep_row - 1
	wep_select_bar.remove_weapon(swep)

var debug1
func _ready():
	debug1 = Vector3(0,0,0)
	camera_pos_normal = head.transform.origin
	camera_pos_crouch = head.transform.origin-Vector3(0,1,0)
	raycast.collide_with_areas = false
	raycast.collide_with_bodies = true
	
	for col in range(0,6):
		current_weps.append([])
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	crouching = false
	sprinting = false
	
	
# Triggers a weapon switch according to current_weps, active_wep_col, active_wep_row
var first_wep_update = true
func wep_update():	
	if first_wep_update:
		first_wep_update = false
	else:
		# Calling this allows the SWEP to run code when it is put away, but it won't
		# have time to play any animations since it is removed the same frame.
		active_wep_node.lower_weapon()

	if active_wep_row >= current_weps[active_wep_col].size():
		# Reset active_wep_row to zero.
		# Set active_wep_col to the next non-empty column.
		active_wep_row = 0
		var index = 0
		for i in range(0,current_weps.size()):
			index = wrapi(active_wep_col+1+i, 0, current_weps.size())
			if current_weps[index].size() > 0:
				active_wep_col = index
				break
	elif active_wep_row < 0:
		# Set active_wep_col to the last non-empty column.
		# Set active_wep_row to the last index in that column.
		var index = 0
		for i in range(0,current_weps.size()):
			index = wrapi(active_wep_col-1-i, 0, current_weps.size())
			if current_weps[index].size() > 0:
				active_wep_row = current_weps[index].size()-1
				active_wep_col = index
				break
	
	wep_select_bar.highlight_wep(active_wep_col, active_wep_row)
	
	var weapon_parent = active_wep_node.get_parent()
	var new_wep = current_weps[active_wep_col][active_wep_row]
	weapon_parent.remove_child(active_wep_node)
	new_wep.name = active_wep_node.name
	weapon_parent.add_child(new_wep)
	active_wep_node = new_wep
	new_wep.raise_weapon()
	
# throws the current weapon
# This function is of very questionable utility and it causes lags spikes.
# Although it is mostly harmless, it is a likely candidate for removal.
func wep_yeet():
	if current_weps[active_wep_col][active_wep_row].swep_prop == "NONE":
		print("Cannot throw a swep without an associated prop.")
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
	remove_wep(active_wep_node)

	wep_update()	

func wep_slot_input(slot_num):
	if active_wep_col == slot_num-1:
		active_wep_row = wrapi(active_wep_row+1, 0, len(current_weps[active_wep_col]))
	else:
		active_wep_col = slot_num-1
		active_wep_row = 0		
	wep_update()
		
func _process(_delta):
	mouse_motion.y = clamp(mouse_motion.y, -1550, 1550)
	if mouse_locked == false:
		transform.basis = Basis(Vector3(0, mouse_motion.x * -0.001, 0))
		head.transform.basis = Basis(Vector3(mouse_motion.y * -0.001, 0, 0))

	if input_locked:
		return
	
	if Input.is_action_just_pressed("noclip"):
		is_noclip = !is_noclip
		phys_disabled = is_noclip

	if Input.is_action_just_pressed("wep_yeet"):
		wep_yeet()
			
	if scroll_wheel_locked == false:
		if Input.is_action_just_released("wep_next"):
			active_wep_row -= 1
			wep_update()
			return
		if Input.is_action_just_released("wep_prev"):
			active_wep_row += 1
			wep_update()
			return

	if Input.is_action_just_pressed("wep_slot_1"):
		wep_slot_input(1)
	elif Input.is_action_just_pressed("wep_slot_2"):
		wep_slot_input(2)
	elif Input.is_action_just_pressed("wep_slot_3"):
		wep_slot_input(3)
	elif Input.is_action_just_pressed("wep_slot_4"):
		wep_slot_input(4)
	elif Input.is_action_just_pressed("wep_slot_5"):
		wep_slot_input(5)
	elif Input.is_action_just_pressed("wep_slot_6"):
		wep_slot_input(6)

# This handles walking. Mouse movements and camera rotations are handled separately.
# Called on physics_update when not in noclip mode.
func player_movement_normal(delta):
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
	
	if crouching:
		movement_accel = walk_speed_crouch
	elif sprinting:
		movement_accel = walk_speed_sprint
	else:
		movement_accel = walk_speed_normal

	wish_dir = transform.basis.xform(Vector3(D-A, 0, S-W).normalized())
	friction = friction_air	
	if on_floor and Input.is_action_pressed("jump"):
		velocity.y = jump_velocity
	
func movement_noclip(delta):
	if move_locked:
		return
	
	velocity = Vector3(0,0,0)
	var W = Input.get_action_strength("move_forward")
	var A = Input.get_action_strength("move_left")
	var S = Input.get_action_strength("move_back")
	var D = Input.get_action_strength("move_right")
	
	var jump = Input.get_action_strength("jump")
	var crouch = Input.get_action_strength("crouch")
	var sprint = Input.get_action_strength("run")

	var aim_dir = head.get_global_transform().basis.z
	var aim_right = head.get_global_transform().basis.x
	var movement = Vector3(D-A, 0, S-W).normalized()

	var move_speed = 0
	
	if crouch:
		move_speed = noclip_speed_crouch
	elif sprint:
		move_speed = noclip_speed_normal * 2
	else:
		move_speed = noclip_speed_normal
	
	# possibly a bug:
	# If you look up and press jump at the same time, you move faster	
	self.translation += aim_dir*(S-W)*move_speed*delta
	self.translation += aim_right*(D-A)*move_speed*delta
	self.translation += (Vector3.UP)*(jump)*move_speed*delta
	
func _physics_process(delta):
	if is_noclip:
		movement_noclip(delta)
	else:
		player_movement_normal(delta)

func _input(ev):
	event = ev
	if event is InputEventMouseMotion and mouse_locked == false:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_motion += event.relative

func npc_damaged():
	pass

func trigger_death():
	pass
