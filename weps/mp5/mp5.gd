extends FreeModSwep

onready var anim_player = $"glv_mp5/AnimationPlayer"
onready var stream_player = $"AudioStreamPlayer"
onready var beam_light = $"beam_light"

onready var bullethole = preload("res://particle/impact_dust.tscn")

var fire_audio_stream = preload("res://weps/mp5/MP5FIRE.wav")
var cock_audio_stream = preload("res://weps/mp5/MP5OUT.WAV")
var load_audio_stream = preload("res://weps/mp5/MP5RELOAD.wav")

var impact_audio_streams = [
	preload("res://weps/shared/ricochet0.wav"),
	preload("res://weps/shared/ricochet1.wav"),
	preload("res://weps/shared/ricochet2.wav"),
	preload("res://weps/shared/ricochet3.wav")
	]

var beam
var beam_enabled = false

var sound3d = preload("res://audio/sound3d.tscn")
var sound3d_fact 
var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 



func raise_weapon():
	stream_player.set_stream(cock_audio_stream)
	stream_player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	sound3d_fact = sound3d.instance()
	sound_direct_fact = sound_direct.instance() 

	
func play_impact_sound(position):
	var sound = sound3d_fact.duplicate()
	add_child(sound)
	var impact_audio_stream = impact_audio_streams[randi() % 4]
	sound.global_transform.origin = position
	sound.play(impact_audio_stream)
	return

func play_fire_sound():
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -15
	sound.play_sound(fire_audio_stream)
	return

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):		
	# Problems:
	# - beam is present even when reloading/shooting/moving weapon
	if beam_enabled:
		player.raycast.cast_to = Vector3(0,0,-500)
		if player.raycast.is_colliding():
			var point_hit = player.raycast.get_collision_point()
			point_hit - player.translation
			beam_light.global_transform.origin = point_hit
			if beam_light.visible == false:
				beam_light.visible = true
		elif beam_light.visible == true:
			beam_light.visible = false

	if anim_player.is_playing():
		return
	
	# Problem: holding down toggle_flashlight causes it to change every frame.
	if Input.is_action_pressed("toggle_flashlight"):
		beam_enabled = !beam_enabled
		beam_light.visible = beam_enabled

	if Input.is_action_pressed("wep_fire"):
		anim_player.play("fire.002",-1,1)
		play_fire_sound()
		player.raycast.cast_to = Vector3(0,0,-500)
		if player.raycast.is_colliding():
			var object_hit = player.raycast.get_collider()
			var point_hit = player.raycast.get_collision_point()
			var hit_normal = player.raycast.get_collision_normal()
			play_impact_sound(point_hit)
			var impact_decal = bullethole.instance()
			object_hit.add_child(impact_decal)
			impact_decal.global_transform.origin = point_hit
			if hit_normal == Vector3.UP:
				# doesn't matter as long as it's in the xz-plane
				hit_normal = Vector3(1,0,0)
				impact_decal.look_at(point_hit + Vector3.UP, hit_normal)

			else:
				impact_decal.look_at(point_hit + hit_normal, Vector3.UP)


	if Input.is_action_pressed("wep_aim"):
		# TODO: we could do something with the camera here
		pass
			
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("reload",-1,1)
		stream_player.set_stream(load_audio_stream)
		stream_player.play()

