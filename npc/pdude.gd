extends KinematicBody

# Effects animation and movement speed. Serves as a difficulty adjustment. 
var speed_mult = 1
# Effects animation speed only. This should be set so that when speed_mult is equal
# to one and walk_speed is nominal, animations sync up with movement.
var anim_adjust_const = 0.5
# Effects how long the AI stays in a single state. 
var time_mult = 5/speed_mult
# TODO: the constant factor here should be the player's nominal walk speed.
var walk_speed = speed_mult*5.0


var rng = RandomNumberGenerator.new()
var velocity = Vector3()

# the position it is supposed to be walking towards.
var target_pos = Vector3()
# how close to the target pos do we need to be in order to be considered there?
var target_tolerance = 2.5

enum npc_state {NONE, A, B}
var current_state = npc_state.NONE
var prev_state = npc_state.NONE

var at_target_pos = false

onready var anim_player = $pdude001/AnimationPlayer
onready var timer = $Timer
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _clear_state():
	prev_state = current_state
	current_state = npc_state.NONE

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_clear_state")
	
func _physics_process(delta):

	if current_state == npc_state.B:		
		# project target position on to the XZ-plane to  if the target position is above the NPC.
		# This will not prevent running into a wall, but will prevent trying to levitate. 
		var target_pos_proj = target_pos
		target_pos_proj.y = self.translation.y

		var target_dir_proj = target_pos_proj - self.translation
		var target_dist = target_dir_proj.length()

		self.look_at(target_pos_proj, Vector3.UP)
			
		if target_dist < target_tolerance:
			print("arrived at target position.")
			trigger_timeout()
		else:
			velocity = (target_pos - self.translation).normalized()*walk_speed
		
	# This expects velocity to be set elsewhere.
	# Velocity is changed here by external forces such as friction.
	var friction = 0.95
	velocity.y -= gravity
	velocity = velocity*friction
	velocity = move_and_slide(Vector3(velocity.x, velocity.y, velocity.z), Vector3.UP)


		

# Set the AI's current state and set up a callback to handle if the next state takes too long. 
#   - state is an npc_state enum
#   - timeout is a float, the time to stay in this state before going to npc_state.NONE
func move_to_state(state, timeout):
	timer.stop()
	prev_state = current_state
	current_state = state
	timer.start(timeout)


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

	if anim_player.is_playing():
		pass

	if current_state == npc_state.NONE:
		# here is where we decide what state to transition to based on the
		# previous state (and other variables).
		if prev_state == npc_state.NONE:	
			target_pos.x = rng.randf_range(-1,1)*10+self.translation.x
			target_pos.z = rng.randf_range(-1,1)*10+self.translation.z
			target_pos.y = self.translation.y			
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.A:
			target_pos.x = rng.randf_range(-1,1)*10+self.translation.x
			target_pos.z = rng.randf_range(-1,1)*10+self.translation.z
			target_pos.y = self.translation.y
			move_to_state(npc_state.B, time_mult)
			
		if prev_state == npc_state.B:
			move_to_state(npc_state.A, time_mult)
			
	if current_state == npc_state.A:
		anim_player.play("stand.001",-1,speed_mult*anim_adjust_const)

	if current_state == npc_state.B:
		anim_player.play("walk.001",-1,speed_mult*anim_adjust_const)




	
	
