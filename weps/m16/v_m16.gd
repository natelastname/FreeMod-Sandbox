extends FreeModSwep

onready var anim_player = $"V_M16/AnimationPlayer"
onready var bullethole = preload("res://particle/impact_dust.tscn")
var fire_audio_stream = preload("res://weps/m16/M16FIRE.WAV")
var cock_audio_stream = preload("res://weps/mp5/MP5OUT.WAV")
var load_audio_stream = preload("res://weps/mp5/MP5RELOAD.wav")

var sound3d = preload("res://audio/sound3d.tscn")
var sound3d_fact 
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact

var impact_audio_streams = [
	preload("res://weps/shared/ricochet0.wav"),
	preload("res://weps/shared/ricochet1.wav"),
	preload("res://weps/shared/ricochet2.wav"),
	preload("res://weps/shared/ricochet3.wav")
	]


func play_impact_sound(position):
	var sound = sound3d_fact.duplicate()
	add_child(sound)
	var impact_audio_stream = impact_audio_streams[randi() % 4]
	sound.global_transform.origin = position
	sound.play(impact_audio_stream)
	return

func play_direct_sound(audio_stream):
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -15
	sound.play_sound(audio_stream)
	return

func _ready():
	ammo = 30
	mags = 3
	sound3d_fact = sound3d.instance()
	sound_direct_fact = sound_direct.instance() 

func swep_process(_delta):
	if anim_player.is_playing():
		return

	if Input.is_action_pressed("wep_fire") and ammo > 0:
		ammo = ammo - 1
		anim_player.play("fire",-1,1)
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

			if object_hit is generic_npc:
				object_hit.apply_damage(50)


	if Input.is_action_pressed("wep_reload") and mags > 0:
		mags = mags - 1
		ammo = 30
		anim_player.play("reload",-1,1)
		var sound = sound_direct_fact.duplicate()
		add_child(sound)
		sound.volume_db = -15
		sound.offset = 0.4
		sound.play_sound(load_audio_stream)

	if Input.is_action_pressed("wep_aim"):
		pass

