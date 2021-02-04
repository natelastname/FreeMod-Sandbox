extends FreeModSwep

onready var player = $"/root/World/Player"
onready var anim_player = $"glv_mp5/AnimationPlayer"
onready var stream_player = $"AudioStreamPlayer3D"
onready var fire_stream_players = $"fire_players".get_children()
onready var impact_stream_players = $"impact_players".get_children()
onready var beam_light = $"beam_light"

onready var bullethole = preload("res://particle/impact_dust.tscn")

var fire_audio_stream = load("res://weps/mp5/MP5FIRE.wav")
var cock_audio_stream = load("res://weps/mp5/MP5OUT.WAV")
var load_audio_stream = load("res://weps/mp5/MP5RELOAD.wav")

var impact_audio_streams = [
	load("res://weps/shared/ricochet0.wav"),
	load("res://weps/shared/ricochet1.wav"),
	load("res://weps/shared/ricochet2.wav"),
	load("res://weps/shared/ricochet3.wav")
	]

var beam
var beam_enabled = false

func raise_weapon():
	stream_player.global_transform.origin = player.global_transform.origin
	stream_player.set_stream(cock_audio_stream)
	stream_player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "HK MP5"
	swep_desc = "Extremely bad ass"
	swep_prop = "res://weps/mp5/mp5_prop.tscn"
	swep_path = "res://weps/mp5/mp5_viewmodel.tscn"	

func play_impact_sound(position):
	for audio_player in impact_stream_players:
		if not audio_player.playing:
			var impact_audio_stream = impact_audio_streams[randi() % 4]
			audio_player.global_transform.origin = position
			audio_player.set_stream(impact_audio_stream)
			audio_player.play()
			return
		
func play_fire_sound():
	for audio_player in fire_stream_players:
		if not audio_player.playing:
			audio_player.global_transform.origin = player.global_transform.origin
			audio_player.set_stream(fire_audio_stream)
			audio_player.play()
			return

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	stream_player.global_transform.origin = player.global_transform.origin
		
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
		stream_player.global_transform.origin = player.global_transform.origin
		stream_player.set_stream(load_audio_stream)
		stream_player.play()

