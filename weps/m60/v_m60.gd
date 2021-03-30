extends NavySealsGun

func _ready():
	shots_per_mag = 100
	default_num_mags = 1
	._ready()
	anim_player.set_animation_process_mode(AnimationPlayer.ANIMATION_PROCESS_MANUAL)
	anim_player.play("v_m60Action")
	
var time_accumulated = 0
var end_time = 0
func swep_process(_delta):
	if time_accumulated+_delta > end_time:
		time_accumulated = end_time
		# a bug causes the keyframes at the end of the animation to not work. 
		if ammo == 100:
			anim_player.seek(0, true)
		else:
			anim_player.seek(end_time, true)
	else:
		time_accumulated += _delta
		anim_player.advance(_delta)
		return
	
	if Input.is_action_pressed("wep_fire") and ammo > 0:
		if ammo > 8:
			anim_player.seek(0, true)
			time_accumulated = 0
			end_time = 0.08
		else:
			time_accumulated = (8 - ammo)*0.08
			anim_player.seek(time_accumulated, true)
			end_time = time_accumulated + 0.08
		
		ammo = ammo - 1
		AudioUtil.play_direct(fire_audio_stream)
		var fire_dir = calc_base_accuracy(Vector3(0,0,-500))
		fire_projectile(fire_dir)

	if Input.is_action_pressed("wep_reload") and mags > 0:
		mags = mags - 1
		ammo = shots_per_mag
		end_time = anim_player.get_current_animation_length()
		time_accumulated = 0
		anim_player.seek(0.6)
		AudioUtil.play_direct(load_audio_stream)

	if Input.is_action_pressed("wep_aim"):
		pass

