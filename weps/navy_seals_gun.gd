extends FreeModSwep

class_name NavySealsGun

export(int) var shots_per_mag = 30
export(int) var default_num_mags = 3
export(int) var damage_per_hit = 20

export(String) var fire_anim = "NONE"
export(String) var cock_anim = "NONE"
export(String) var load_anim = "NONE"
export(String) var click_anim = "NONE"

export(AudioStreamSample) var fire_audio_stream = null
export(AudioStreamSample) var cock_audio_stream = null
export(AudioStreamSample) var load_audio_stream = null
export(AudioStreamSample) var click_audio_stream = null

export(bool) var has_scope = false
export(bool) var has_beam = false
export(bool) var full_auto = false

var bullethole = preload("res://particle/impact_dust.tscn")
var beam = preload("res://weps/shared/beam_light.tscn")
var beam_fact

var impact_audio_streams = [
	preload("res://weps/shared/ricochet0.wav"),
	preload("res://weps/shared/ricochet1.wav"),
	preload("res://weps/shared/ricochet2.wav"),
	preload("res://weps/shared/ricochet3.wav")
	]

var sound3d = preload("res://audio/sound3d.tscn")
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound3d_fact 
var sound_direct_fact
var anim_player

func play_3d_sound(audio_stream, position):
	if audio_stream == null:
		return
	var sound = sound3d_fact.duplicate()
	add_child(sound)
	sound.global_transform.origin = position
	sound.play_stream(audio_stream)
	return

func play_direct_sound(audio_stream):
	if audio_stream == null:
		return
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -15
	sound.play_sound(audio_stream)

var timer 
var viewmodel

func _ready():
	sound3d_fact = sound3d.instance()
	sound_direct_fact = sound_direct.instance()
	beam_fact = beam.instance()
	ammo = shots_per_mag
	mags = default_num_mags
	for child in get_children():
		if child is MeshInstance:
			viewmodel = child
			anim_player = child.get_children()[0]
	assert(anim_player is AnimationPlayer)

	timer = Timer.new()
	timer.set_wait_time(0.250)
	timer.connect("timeout", self, "_enable_click")
	timer.set_one_shot(true)
	add_child(timer)
	
func raise_weapon():
	if cock_anim != "NONE":
		anim_player.play(cock_anim)
	if cock_audio_stream != null:
		play_direct_sound(cock_audio_stream)

func lower_weapon():
	if has_scope:
		player.main_cam.set_fov(75)

# called when the weapon is fired with atleast one shot in the mag
func fire_weapon():
	
	if fire_anim != "NONE":
		anim_player.play(fire_anim,-1,1)

	play_direct_sound(fire_audio_stream)

	player.raycast.cast_to = Vector3(0,0,-500)
	if not player.raycast.is_colliding():
		return
	
	var object_hit = player.raycast.get_collider()

	if object_hit is generic_npc:
		object_hit.apply_damage(damage_per_hit)
	
	var hit_normal = player.raycast.get_collision_normal()
	var point_hit = player.raycast.get_collision_point()

	var impact_audio_stream = impact_audio_streams[randi() % 4]
	play_3d_sound(impact_audio_stream, point_hit)

	var impact_decal = bullethole.instance()
	object_hit.add_child(impact_decal)
	impact_decal.global_transform.origin = point_hit
	
	if hit_normal == Vector3.UP:
		# doesn't matter as long as it's in the xz-plane
		hit_normal = Vector3(1,0,0)
		impact_decal.look_at(point_hit + Vector3.UP, hit_normal)
	else:
		impact_decal.look_at(point_hit + hit_normal, Vector3.UP)

func load_weapon():

	if has_scope:
		viewmodel.visible = true
		player.main_cam.set_fov(75)
	
	if load_anim != "NONE":
		anim_player.play(load_anim,-1,1)

	play_direct_sound(load_audio_stream)

var curr_beam = null
var beam_enabled = false

func update_beam():
	if Input.is_action_pressed("toggle_flashlight"):
		if beam_enabled == true:
			curr_beam.queue_free()
		if beam_enabled == false:
			curr_beam = beam_fact.duplicate()
			add_child(curr_beam)
		beam_enabled = !beam_enabled
			
	if beam_enabled == false:
		return
	
	player.raycast.cast_to = Vector3(0,0,-500)
	if player.raycast.is_colliding():
		var point_hit = player.raycast.get_collision_point()
		curr_beam.global_transform.origin = point_hit

var click_cooldown = true
func _enable_click():
	click_cooldown = true
	
func swep_process(_delta):
	if has_beam:
		update_beam()
	
	if has_scope and Input.is_action_just_released("wep_aim"):
		player.main_cam.set_fov(75)
		viewmodel.visible = true

	if anim_player.is_playing():
		return
	
	if full_auto and Input.is_action_pressed("wep_fire"):
		if ammo > 0:
			ammo = ammo - 1
			fire_weapon()
		elif timer.get_time_left() == 0:
			if click_anim != "NONE":
				anim_player.play(click_anim,-1,1)
			play_direct_sound(click_audio_stream)
			timer.start()
	elif Input.is_action_just_pressed("wep_fire"):
		if ammo > 0:
			ammo = ammo - 1
			fire_weapon()
		else:
			if click_anim != "NONE":
				anim_player.play(click_anim,-1,1)
			play_direct_sound(click_audio_stream)

	if Input.is_action_pressed("wep_reload") and mags > 0:
		mags = mags - 1
		ammo = shots_per_mag
		load_weapon()
		return
		
	if has_scope and Input.is_action_pressed("wep_aim"):
		player.main_cam.set_fov(30)
		viewmodel.visible = false

