extends FreeModSwep

onready var anim_player = $"v_rangem/AnimationPlayer"
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_direct_fact = sound_direct.instance()

func swep_process(_delta):
	if anim_player.is_playing():
		return
	
	if Input.is_action_just_pressed("wep_fire"):
		anim_player.play("v_rangemAction.005",-1,1)
		return
	
	if Input.is_action_just_pressed("wep_reload"):
		anim_player.play("v_rangemAction.002",-1,1)
		return
