extends FreeModSwep

onready var anim_player = $"v_deagle/AnimationPlayer"

func _ready():
	pass 

func raise_weapon():
	#stream_player.set_stream(cock_audio_stream)
	#stream_player.play()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):
	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("fire.003",-1,1)
		
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("reload.003",-1,1)

	# other animations:
	# "empty"
	# "base.002"
