extends Control


onready var progress_bar = $"CenterContainer/VBoxContainer/TextureProgress"
onready var info_label = $"CenterContainer/VBoxContainer/Label2"


func set_info(text):
	info_label.text = str(text)
	

func _ready():
	pass

