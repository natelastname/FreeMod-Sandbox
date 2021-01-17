extends FreeModSwep

onready var player = $"/root/World/Player"
onready var anim_player = $"blaster_view_MD5_Armature/AnimationPlayer"

# Called when the node enters the scene tree for the first time.1
func _ready():
	anim_player.play("(blaster_view)_blaster_view_raise.md5anim",-1,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("(blaster_view)_blaster_view_fire.md5anim",-1,1)
		
	if Input.is_action_pressed("wep_aim"):
		# TODO: we could do something with the camera here
		pass
		
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("(blaster_view)_blaster_view_reload.md5anim",-1,1)
