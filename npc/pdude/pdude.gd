class_name pdude_ai
extends generic_npc

var walk_speed_sprint = 30
var walk_speed_normal = 20
var walk_speed_crouch = 10

var death_anims_stand = ["deathc.001","deathd.001","deathe.001","deathf.001"]
var death_anims_crouch = ["paina.001", "painb.001"]
var pain_anims_crouch = ["deatha.001"]
var pain_anims_stand = ["painc.001","paind.001","paine.001"]

# drawa.001 - draw two handed
# drawb.001 - draw one handed
var draw_anims = ["drawa.001", "drawb.001"]

# firea.001 - shooting two handed
# fireb.001 - shooting one handed
# firec.001 - shooting while walking 
# fired.001 - shooting while crouched
var fire_anims = ["firea.001", "fireb.001", "firec.001", "fired.001"]

# Effects animation and movement speed. Serves as a difficulty adjustment. 
var speed_mult = 1
# Effects animation speed only. This should be set so that when speed_mult is equal
# to one and walk_speed is nominal, animations sync up with movement.
var anim_adjust_const = 0.5
# Effects how long the AI stays in a single state. 
var time_mult = 5/speed_mult
# how close to the target pos do we need to be in order to be considered there?
var target_tolerance = 2.5

enum npc_state {NONE, A, B, DEAD}
var alert = false
var crouched = false
var current_state = npc_state.NONE
var prev_state = npc_state.NONE
var rng

var at_target_pos = false
var target_pos = Vector3(0,0,0)

onready var timer = $"./Timer"
onready var anim_player = $"./pdude001/AnimationPlayer"


# Called when the node enters the scene tree for the first time.
func _ready():
	phys_disabled = true
	rng = RandomNumberGenerator.new()
	rng.randomize()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_clear_state")


	var material = preload("res://npc/pdude/pdude.tres").duplicate()
	var mesh = preload("res://npc/pdude/pdude.mesh").duplicate()

	$"pdude001".set_mesh(mesh)
	$"pdude001".set_surface_material(0, material)

	print("---------------------")
	var material2 = $"pdude001".get_surface_material(0)
	print($"pdude001".get_surface_material(0))
	print($"pdude001".get_mesh())
	print($"pdude001/AnimationPlayer")
		
func npc_damaged():
	print("hurt:"+str(self))
	alert = true

func remove_self():
	queue_free()
	
func trigger_death():
	print("hurt:"+str(self))

	current_state = npc_state.DEAD
	phys_disabled = true
	for kid in get_children():
		if kid is CollisionShape:
			#kid.queue_free()
			pass
	
	if crouched:
		anim_player.play("deatha.001")
	else:
		var anim = FileUtil.rand_elt(death_anims_stand)
		anim_player.play(anim)

	timer.connect("timeout", self, "remove_self")
	timer.stop()
	timer.start(10)
	
func npc_physics_process(delta):

	var target_dir_proj = Vector3(0,0,0)
	
	if current_state == npc_state.B:
		# project target position on to the XZ-plane.
		# This will not prevent running into a wall, but will prevent trying to levitate. 
		var target_pos_proj = target_pos
		target_dir_proj = target_pos_proj - self.translation
		target_pos_proj.y = self.global_transform.origin.y

		var target_dist = target_dir_proj.length()
		# Changes in direction should eventually be interpolated
		self.look_at(target_pos_proj, Vector3.UP)
		if target_dist < target_tolerance:
			trigger_timeout()

	if alert:
		movement_accel = walk_speed_sprint
	else:
		movement_accel = walk_speed_normal

	target_dir_proj.y = 0
	wish_dir = target_dir_proj
	
# Set the AI's current state and set up a callback to handle if the next state takes too long. 
#   - state is an npc_state enum
#   - timeout is a float, the time to stay in this state before going to npc_state.NONE
func move_to_state(state, timeout):

	if state == npc_state.DEAD:
		return

	if state == npc_state.NONE:
		anim_player.play("stand.001")
	
	# shoot/idle
	if state == npc_state.A:
		if alert:
			var rando = rng.randi_range(0,1)
			if rando == 1:
				crouched = true
				anim_player.play("roll.001")
				anim_player.queue("fired.001")
				anim_player.queue("fired.001")
				anim_player.queue("fired.001")
				anim_player.queue("fired.001")
				anim_player.queue("fired.001")
			else:
				anim_player.play("drawa.001")
				anim_player.queue("firea.001")
				anim_player.queue("firea.001")
				anim_player.queue("firea.001")
				anim_player.queue("firea.001")
				anim_player.queue("firea.001")
		else:
			anim_player.play("stand.001")
	# run/walk
	if state == npc_state.B:
		if alert:
			anim_player.play("run.001")
		else:
			anim_player.play("walk.001")
	
	timer.stop()
	prev_state = current_state
	current_state = state
	timer.start(timeout)


func _clear_state():
	prev_state = current_state
	current_state = npc_state.NONE

# Calling this function manually triggers a timeout, which forces the AI to choose what to do next.
# The state can also be changed manually by calling move_to_state.
func trigger_timeout():
	timer.stop()
	_clear_state()

	
func _process(_delta):

	# Alternate between two states, A and B.
	# If we are alert:
	#    - A is "target" (or, "shoot")
	#    - B is "run"
	# If we are not alert:
	#    - A is "idle"
	#    - B is "walk"
	# (currently this is not fully implemented)

	
	if current_state == npc_state.DEAD:
		return
	
	if current_state == npc_state.NONE:
		# here is where we decide what state to transition to based on the
		# previous state (and other variables).
		
		if prev_state == npc_state.NONE:	
			target_pos.x = rng.randf_range(-1,1)*25+self.translation.x
			target_pos.z = rng.randf_range(-1,1)*25+self.translation.z
			target_pos.y = self.translation.y			
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.A:
			target_pos.x = rng.randf_range(-1,1)*25+self.translation.x
			target_pos.z = rng.randf_range(-1,1)*25+self.translation.z
			target_pos.y = self.translation.y
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.B:
			move_to_state(npc_state.A, time_mult)


	if anim_player.is_playing():
		return
	
