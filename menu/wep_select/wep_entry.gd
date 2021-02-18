extends VBoxContainer


onready var title_lbl = $"title"
onready var desc_lbl = $"description"

var title = ""
var desc = ""

# Set the FreeModSwep corresponding to this entry
func set_wep(swep):
	title = swep.swep_name
	desc = swep.swep_desc
	title_lbl.text = title
	desc_lbl.text = desc

# Indicate that this weapon is being hovered over 
func set_hover(state):
	assert(state is bool)
	if state:
		desc_lbl.visible = true
		title_lbl.visible = true
	else:
		desc_lbl.visible = false
		title_lbl.visible = true

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#title_lbl.text = title
	#desc_lbl.text = desc
