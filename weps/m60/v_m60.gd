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
		play_direct_sound(fire_audio_stream)
		player.raycast.cast_to = Vector3(0,0,-500)
		if player.raycast.is_colliding():
			var object_hit = player.raycast.get_collider()
			var point_hit = player.raycast.get_collision_point()
			var hit_normal = player.raycast.get_collision_normal()
			var impact_decal = bullethole.instance()
			object_hit.add_child(impact_decal)
			impact_decal.global_transform.origin = point_hit
			if hit_normal == Vector3.UP:
				# doesn't matter as long as it's in the xz-plane
				hit_normal = Vector3(1,0,0)
				impact_decal.look_at(point_hit + Vector3.UP, hit_normal)
			else:
				impact_decal.look_at(point_hit + hit_normal, Vector3.UP)
				
			var impact_audio_stream = impact_audio_streams[randi() % 4]
			play_3d_sound(impact_audio_stream, point_hit)
			if object_hit is generic_npc:
				object_hit.apply_damage(35)

	if Input.is_action_pressed("wep_reload") and mags > 0:
		mags = mags - 1
		ammo = shots_per_mag
		end_time = anim_player.get_current_animation_length()
		time_accumulated = 0
		anim_player.seek(0.6)
		play_direct_sound(load_audio_stream)

	if Input.is_action_pressed("wep_aim"):
		pass

