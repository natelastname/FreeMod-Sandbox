class_name pdude_ai
extends generic_npc

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
# speed_mult = 1.0 is considered nominal difficulty. The higher it is, the more difficult.
var speed_mult = 1
# Effects animation speed only. This should be set so that when speed_mult is equal
# to one and walk_speed is nominal, animations sync up with movement.
var anim_adjust_const = 0.5
# How long the AI stays in a single state. 
var time_mult = 5/speed_mult
# how close to the target pos do we need to be in order to be considered there?
var target_tolerance = 2.5

var walk_speed_sprint = 30*speed_mult
var walk_speed_normal = 20*speed_mult
var walk_speed_crouch = 10*speed_mult

var animation_queue = []
var animation_speed = 1.0

enum npc_state {NONE, A, B, DEAD}
var alert = false
var crouched = false
var current_state = npc_state.NONE
var prev_state = npc_state.NONE
var rng

var at_target_pos = false
var target_dir = Vector3(0,0,0)

onready var timer = $"./Timer"
onready var anim_player = $"./pdude001/AnimationPlayer"


# Called when the node enters the scene tree for the first time.
func _ready():
	#phys_disabled = true
	rng = RandomNumberGenerator.new()
	rng.randomize()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_clear_state")
	
	# If we have multiple instances of pdude, they will share the same
	# ArrayMesh resource and thus animating one of them will animate them all.

	var mesh = preload("res://npc/pdude/pdude.mesh").duplicate()
	$"pdude001".set_mesh(mesh)
	var material = preload("res://npc/pdude/pdude.tres").duplicate()
	$"pdude001".set_surface_material(0, material)

	#print("---------------------")
	#print($"pdude001".get_surface_material(0))
	#print($"pdude001".get_mesh())
	#print($"pdude001/AnimationPlayer")
		
func npc_damaged():
	alert = true

func remove_self():
	queue_free()
	
func trigger_death():
	current_state = npc_state.DEAD
	phys_disabled = true
	for kid in get_children():
		if kid is CollisionShape:
			kid.queue_free()
	
	if crouched:
		anim_player.play("deatha.001")
	else:
		var anim = FileUtil.rand_elt(death_anims_stand)
		anim_player.play(anim)

	timer.connect("timeout", self, "remove_self")
	timer.stop()
	timer.start(10)
	
func npc_physics_process(delta):
	var move_dir = Vector3(0,0,0)
	
	if current_state == npc_state.B:
		# Changes in direction should eventually be interpolated
		self.look_at(target_dir+self.global_transform.origin, Vector3.UP)

		var sum = Vector3(0,0,0)
		for i in range(0,get_slide_count()):
			var slide = get_slide_collision(i)
			if slide.normal.dot(Vector3.UP) < 0.1:
				sum += slide.normal

		if sum.length() > 0:
			sum = sum.normalized()
			var d = target_dir
			var n = sum
			target_dir = d - (2*d.dot(n)*n)				
				

		move_dir = target_dir
	
	if alert:
		movement_accel = walk_speed_sprint
	else:
		movement_accel = walk_speed_normal

	wish_dir = move_dir
	
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
			var angle = rng.randf_range(0,1)*2*PI
			target_dir.x = cos(angle)
			target_dir.z = sin(angle)
			target_dir.y = 0			
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.A:
			var angle = rng.randf_range(0,1)*2*PI
			target_dir.x = cos(angle)
			target_dir.z = sin(angle)
			target_dir.y = 0			
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.B:
			move_to_state(npc_state.A, time_mult)


	if anim_player.is_playing():
		return
	
