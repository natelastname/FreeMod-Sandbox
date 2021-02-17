extends FreeModSwep

onready var anim_player = $"v_span/AnimationPlayer"
var swing_sound = preload("res://weps/wrench/SWOOSH.WAV")

var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

func play_fire_sound():
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -15
	sound.play_sound(swing_sound)
	return

func raise_weapon():
	pass

func _ready():
	swep_name = "Magic Wand"
	swep_desc = "Not a wrench"
	# Since this does not have a prop, it cannot be thrown
	swep_prop = "res://weps/wrench/wrench_prop.tscn"
	swep_path = "res://weps/wrench/wrench.tscn"
	sound_direct_fact = sound_direct.instance() 



# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):
	if anim_player.is_playing():
		return
	
	if Input.is_action_just_pressed("wep_fire"):
		anim_player.play("fire.020",-1,1)
		play_fire_sound()
