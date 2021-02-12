extends FreeModSwep

onready var anim_player = $"blaster_view_MD5_Armature/AnimationPlayer"
onready var stream_player = $"AudioStreamPlayer"

var _selected_block
var selected_block_texture

var fire_audio_stream
var place_audio_stream
var miss_audio_stream

func raise_weapon():
	anim_player.play("(blaster_view)_blaster_view_raise.md5anim",-1,1)

func lower_weapon():
	anim_player.play("(blaster_view)_blaster_view_raise.md5anim",-1,-1,true)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Test gun"
	swep_desc = "Incredible brown brick gameplay!"
	swep_desc += "\nFire: remove block"
	swep_desc += "\nAim: place block"
	
	swep_prop = "res://weps/test gun/testgun_prop.tscn"
	swep_path = "res://weps/test gun/testgun.tscn"

	_selected_block = 1

	selected_block_texture = player.selected_block_texture

	fire_audio_stream = load("res://weps/test gun/hit2.wav")
	place_audio_stream = load("res://weps/test gun/hit.wav")
	miss_audio_stream = load("res://weps/test gun/COCK2.wav")
	stream_player.volume_db = 1
	stream_player.pitch_scale = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("(blaster_view)_blaster_view_reload.md5anim",-1,1)

	if Input.is_action_just_pressed("prev_block"):
		_selected_block -= 1
		_selected_block = wrapi(_selected_block, 1, 30)
		var uv = Chunk.calculate_block_uvs(_selected_block)
		selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	if Input.is_action_just_pressed("next_block"):
		_selected_block += 1
		_selected_block = wrapi(_selected_block, 1, 30)
		var uv = Chunk.calculate_block_uvs(_selected_block)
		selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	var breaking = Input.is_action_pressed("wep_fire")
	var placing = Input.is_action_pressed("wep_aim")

	if breaking == placing:
			return
	
	anim_player.play("(blaster_view)_blaster_view_fire.md5anim",-1,1)

	player.raycast.cast_to = Vector3(0,0,-5)
	if player.crosshair.visible and player.raycast.is_colliding():
		var position = player.raycast.get_collision_point()
		var normal = player.raycast.get_collision_normal()
		
		if breaking:
			var block_global_position = (position - normal / 2).floor()
			if player.voxel_world.get_block_global_position(block_global_position) != 0:
				stream_player.set_stream(fire_audio_stream)
				stream_player.play()
				player.voxel_world.set_block_global_position(block_global_position, 0)
			else:
				stream_player.set_stream(miss_audio_stream)
				stream_player.play()				
		elif placing:
			stream_player.set_stream(place_audio_stream)
			stream_player.play()
			var block_global_position = (position + normal / 2).floor()
			player.voxel_world.set_block_global_position(block_global_position, _selected_block)
	else:
		stream_player.set_stream(miss_audio_stream)
		stream_player.play()
