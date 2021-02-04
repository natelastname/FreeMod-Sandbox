extends Control

var props
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
	
	
func _process(delta):
	if Input.is_action_just_pressed("prop_menu"):
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_released("prop_menu"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		visible = false
