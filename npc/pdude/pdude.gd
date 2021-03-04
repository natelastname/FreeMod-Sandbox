extends generic_npc


# deatha.001 - crouch
# deathc.001 - stand
# deathd.001 - stand
# deathe.001 - stand
# deathf.001 - stand

# paina.001 - crouch
# painb.001 - crouch
# painc.001 - stand
# paind.001 - stand
# paine.001 - stand

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
# TODO: the constant factor here should be the player's nominal walk speed.

var rng = RandomNumberGenerator.new()

# how close to the target pos do we need to be in order to be considered there?
var target_tolerance = 2.5

enum npc_state {NONE, A, B}
var alert = false
var crouched = false
var current_state = npc_state.NONE
var prev_state = npc_state.NONE

var at_target_pos = false
var target_pos = Vector3(0,0,0)

onready var anim_player = $pdude001/AnimationPlayer
onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_clear_state")

func npc_physics_process(delta):

	var target_dir_proj = Vector3(0,0,0)
	
	if current_state == npc_state.B:
		# project target position on to the XZ-plane.
		# This will not prevent running into a wall, but will prevent trying to levitate. 
		var target_pos_proj = target_pos
		target_dir_proj = target_pos_proj - self.translation
		target_pos_proj.y = self.translation.y

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

	if state == npc_state.NONE:
		anim_player.play("stand.001")
	
	# shoot/idle
	if state == npc_state.A:
		if alert:
			var rando = rng.randi_range(0,1)
			#var rando = 0
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


func apply_damage(amt):
	pass


	
func _process(_delta):

	# Alternate between two states, A and B.
	# If we are alert:
	#    - A is "target" (or, "shoot")
	#    - B is "run"
	# If we are not alert:
	#    - A is "idle"
	#    - B is "walk"
	
	# (currently this is not fully implemented)
	
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
	
