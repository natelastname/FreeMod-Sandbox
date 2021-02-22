extends GridContainer

onready var col_num_lbl = $"col_num"

func set_number(num):
	col_num_lbl.text = str(num)

func _ready():
	pass
