extends FreeModSwep

onready var anim_player = $"v_fist/AnimationPlayer"
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_direct_fact = sound_direct.instance()



var punch_done = false	
func swep_process(_delta):
	if anim_player.is_playing():
		return

	if punch_done == true:
		punch_done = false
		anim_player.play("base.003",-1,1)
		return

	
	if Input.is_action_just_pressed("wep_fire"):
		anim_player.play("lpunch.005",-1,1)
		punch_done = true

		return
	
	if Input.is_action_just_pressed("wep_aim"):
		anim_player.play("rpunch.004",-1,1)
		punch_done = true
		return
