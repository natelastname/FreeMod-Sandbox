extends HBoxContainer

var kids = []
var timer


func remove_self():
	self.visible = false



func highlight_wep():
	self.visible = true
	timer.start()


# Called when the node enters the scene tree for the first time.
func _ready():
	kids = self.get_children()
	for i in range(0, kids.size()):
		kids[i].set_number(i+1)

	self.visible = false
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_autostart(false)
	timer.set_wait_time(5)
	timer.connect("timeout",self,"remove_self")
	add_child(timer)


	



	
	
