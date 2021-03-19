extends Control

var props
onready var player = $"/root/World/map/Player"
onready var proplist = $"TabContainer/Props/HBoxContainer/PropList"

var fs_util = preload("res://util/file_util.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	props = FileUtil.list_files("res://props")
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
