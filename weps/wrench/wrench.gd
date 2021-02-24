extends FreeModSwep

onready var anim_player = $"v_span/AnimationPlayer"
onready var tool_node = $"active_tool"

var swing_sound = preload("res://weps/wrench/SWOOSH.WAV")
var raise_sound = preload("res://weps/wrench/tools.wav")

var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 

var tool_scripts = {}
var active_tool = null

func _init():
	var tool_names = FileUtil.list_files("res://tools")
	for t in tool_names:
		tool_scripts[t] = load("res://tools/"+t+"/"+t+".gd")

func set_tool(tname):	
	active_tool = tool_scripts[tname]
	tool_node.set_script(active_tool)

func play_fire_sound():
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -10
	sound.play_sound(swing_sound)
	return

func lower_weapon():
	if active_tool != null:
		tool_node.fmtool_unequipped()

func raise_weapon():
	if active_tool != null:
		tool_node.fmtool_equipped()
	
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.volume_db = -10
	sound.play_sound(raise_sound)
	
func _ready():
	sound_direct_fact = sound_direct.instance() 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func swep_process(_delta):

	if active_tool != null:
		tool_node.fmtool_process(_delta)

	if anim_player.is_playing():
		return
	
	if Input.is_action_just_pressed("wep_fire"):
		anim_player.play("fire.020",-1,1)
		play_fire_sound()
		if active_tool != null:
			tool_node.fmtool_use()
