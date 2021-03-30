extends FreeModSwep

class_name NavySealsGun

export(int) var shots_per_mag = 30
export(int) var default_num_mags = 3
export(int) var damage_per_hit = 20
export(int) var shotgun_num_projectiles = 1
# The radius of the cone measured at 10 units away from the player
export(float) var base_accuracy_cone_radius = 0.25

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

export(NodePath) var anim_player_path = null
export(NodePath) var mesh_path = null

var anim_player

var bullethole = preload("res://particle/impact_dust.tscn")
var beam = preload("res://weps/shared/beam_light.tscn")
var beam_fact

var impact_audio_streams = [
	preload("res://weps/shared/ricochet0.wav"),
	preload("res://weps/shared/ricochet1.wav"),
	preload("res://weps/shared/ricochet2.wav"),
	preload("res://weps/shared/ricochet3.wav")
	]

var click_timer 
var viewmodel
var rng = RandomNumberGenerator.new()

func _ready():

	rng.randomize()
	
	if click_audio_stream == null:
		click_audio_stream = preload("res://weps/shared/click.wav")
	if cock_audio_stream == null:
		cock_audio_stream = preload("res://weps/shared/m60in.wav")
		
	# This is done because it fixes a bug causing nothing to happen
	# when you shoot for the first time
	player.raycast.cast_to = Vector3(0,0,-500)

	beam_fact = beam.instance()
	ammo = shots_per_mag
	mags = default_num_mags
	
	viewmodel = get_node(mesh_path)
	anim_player = get_node(anim_player_path)
			
	assert(anim_player is AnimationPlayer)
	assert(viewmodel is MeshInstance)

	# For automatic weapons with high rate of fire, this prevents the
	# click sound from being played too often.
	click_timer = Timer.new()
	click_timer.set_wait_time(0.250)
	click_timer.connect("timeout", self, "_enable_click")
	click_timer.set_one_shot(true)
	add_child(click_timer)

# fire a single projectile
func fire_projectile(dir):
	player.raycast.cast_to = dir
	player.raycast.force_raycast_update()
	if not player.raycast.is_colliding():
		return

	var object_hit = player.raycast.get_collider()
	var hit_normal = player.raycast.get_collision_normal()
	var point_hit = player.raycast.get_collision_point()

	var impact_audio_stream = impact_audio_streams[randi() % 4]
	AudioUtil.play_at_pos(impact_audio_stream, point_hit)

	var impact_decal = bullethole.instance()
	object_hit.add_child(impact_decal)
	impact_decal.global_transform.origin = point_hit
	
	if hit_normal == Vector3.UP:
		# doesn't matter as long as it's in the xz-plane
		hit_normal = Vector3(1,0,0)
		impact_decal.look_at(point_hit + Vector3.UP, hit_normal)
	else:
		impact_decal.look_at(point_hit + hit_normal, Vector3.UP)

	if object_hit is generic_npc:
		object_hit.apply_damage(damage_per_hit)
 
func calc_base_accuracy(dir):
	# find a random point on the unit circle in the plane whose normal is dir_norm
	var dir_norm = dir.normalized()

	var r = base_accuracy_cone_radius*rng.randf_range(0, 1)
	var theta = rng.randf_range(0, 2*PI)
	var v1
	var v2
	if dir_norm != Vector3.UP:
		v1 = dir_norm.cross(Vector3(1,0,0)).normalized()
		v2 = dir_norm.cross(v1).normalized()
	else:
		v1 = Vector3(1,0,0)
		v2 = Vector3(0,0,1)
	
	var p1 = sin(theta)*r*v1
	var p2 = cos(theta)*r*v2
	var point_on_circle = 500*((10*dir_norm)+p1+p2)
	
	return point_on_circle

# called when the weapon is fired with atleast one shot in the mag
func fire_weapon():
	ammo = ammo - 1
	if fire_anim != "NONE":
		anim_player.play(fire_anim,-1,1)
	AudioUtil.play_direct(fire_audio_stream)

	for i in range(0, shotgun_num_projectiles):
		var shot_dir = calc_base_accuracy(Vector3(0,0,-500))
		fire_projectile(shot_dir)
	
func load_weapon():
	mags = mags - 1
	ammo = shots_per_mag

	if has_scope:
		viewmodel.visible = true
		player.main_cam.set_fov(75)
	if load_anim != "NONE":
		anim_player.play(load_anim,-1,1)

	AudioUtil.play_direct(load_audio_stream)

var curr_beam = null
var beam_enabled = false

func update_beam():
	if Input.is_action_just_pressed("toggle_flashlight"):
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

func raise_weapon():
	if cock_anim != "NONE":
		anim_player.play(cock_anim)
	if cock_audio_stream != null:
		AudioUtil.play_direct(cock_audio_stream)

func lower_weapon():
	if has_scope:
		player.main_cam.set_fov(75)


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
			fire_weapon()
		elif click_timer.get_time_left() == 0:
			if click_anim != "NONE":
				anim_player.play(click_anim,-1,1)
			AudioUtil.play_direct(click_audio_stream)
			click_timer.start()
	elif Input.is_action_just_pressed("wep_fire"):
		if ammo > 0:
			fire_weapon()
		else:
			if click_anim != "NONE":
				anim_player.play(click_anim,-1,1)
			AudioUtil.play_direct(click_audio_stream)

	if Input.is_action_pressed("wep_reload") and mags > 0:
		load_weapon()
		return
		
	if has_scope and Input.is_action_pressed("wep_aim"):
		player.main_cam.set_fov(30)
		viewmodel.visible = false

