extends Control

var props
onready var player = $"/root/World/Player"
onready var proplist = $"TabContainer/Props/PropList"

func list_dir(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)

	while true:
		var file = dir.get_next()
		files.append(file)
		print(file)
		if file == "":
			break
	
	dir.list_dir_end()
	
	return files

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	props = list_dir("res://props")
	proplist.set_props(props)	
	
func _process(delta):
	if Input.is_action_just_pressed("prop_menu"):
		visible = !visible
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			player.input_locked = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			player.input_locked = false
