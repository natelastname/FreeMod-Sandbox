extends FreeModSwep

onready var anim_player = $"v_deagle/AnimationPlayer"

var fire_audio_stream = preload("res://weps/deagle/deagle.wav")
var empty_audio_stream = preload("res://weps/deagle/click.wav")
var load_audio_stream = preload("res://weps/deagle/reload.WAV")

var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

func play_direct_sound(sound_stream):
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -15
	sound.play_sound(sound_stream)
	return

func _ready():
	sound_direct_fact = sound_direct.instance() 

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
		play_direct_sound(fire_audio_stream)
		player.raycast.cast_to = Vector3(0,0,-500)
		if player.raycast.is_colliding():
			var object_hit = player.raycast.get_collider()
			if object_hit.is_in_group("npc"):
				object_hit.alert = !object_hit.alert

		
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("reload.003",-1,1)
		play_direct_sound(load_audio_stream)


	# other animations:
	# "empty"
	# "base.002"
