extends FreeModSwep

onready var player = $"/root/World/Player"
onready var anim_player = $"V_ASHOT/AnimationPlayer"
onready var stream_player = $"strikerStreamPlayer"

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("sample",-1,1)
		stream_player.set_stream(fire_audio_stream)
		stream_player.play()

	if Input.is_action_pressed("wep_aim"):
		# TODO: we could do something with the camera here
		pass
		
	if Input.is_action_pressed("wep_reload"):
		pass
