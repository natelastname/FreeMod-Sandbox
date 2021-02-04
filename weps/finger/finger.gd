extends FreeModSwep

onready var player = $"/root/World/Player"
onready var anim_player = $"v_finger/AnimationPlayer"

func raise_weapon():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Finger"
	swep_desc = "Poke"
	#swep_prop = "res://weps/mp5/mp5_prop.tscn"
	swep_path = "res://weps/finger/finger.tscn"	

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_fire"):
		anim_player.play("v_fingerAction",-1,1)

	if Input.is_action_pressed("wep_aim"):
		pass
	
	if Input.is_action_pressed("wep_reload"):
		pass

