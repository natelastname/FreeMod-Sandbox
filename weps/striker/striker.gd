extends FreeModSwep

onready var player = $"/root/World/Player"
onready var anim_player = $"V_ASHOT/AnimationPlayer"
onready var stream_player = $"strikerStreamPlayer"
onready var stream_player3d = $"AudioStreamPlayer3D"
onready var bullethole = preload("res://decal/bullet_decal.tscn")

var fire_audio_stream
var cock_audio_stream

func raise_weapon():
	stream_player.set_stream(cock_audio_stream)
	stream_player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Striker"
	swep_desc = "Extremely bad ass"
	swep_prop = "res://weps/striker/striker_prop.tscn"
	swep_path = "res://weps/striker/striker.tscn"
	
	fire_audio_stream = load("res://weps/striker/terrgun.wav")
	cock_audio_stream = load("res://weps/striker/ASHOTCOK.wav")
	stream_player.volume_db = 1
	stream_player.pitch_scale = 1

	stream_player3d.max_db = 15
	stream_player3d.max_distance = 50

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("sample",-1,1)
		stream_player.set_stream(fire_audio_stream)
		#stream_player.play()
		player.raycast.cast_to = Vector3(0,0,-500)
		if player.raycast.is_colliding():
			var object_hit = player.raycast.get_collider()
			var point_hit = player.raycast.get_collision_point()
			var hit_normal = player.raycast.get_collision_normal()

			stream_player3d.translation = point_hit
			stream_player3d.set_stream(fire_audio_stream)
			stream_player3d.play()
			
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
		pass
