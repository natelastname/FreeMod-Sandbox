extends HBoxContainer

var kids = []
var timer
var entry = preload("res://menu/wep_select/wep_entry.tscn")

func hide_self():
	self.visible = false

func highlight_wep(active_wep_col, active_wep_row):
	self.visible = true
	# Unhighlight all weapons, this is more idiot proof than keeping track of
	# the last highlighted entry.
	for col in kids:
		for kid in col.get_children():
			if kid is Label:
				continue
			else:
				kid.set_hover(false)	

	var ents = kids[active_wep_col].get_children()
	assert(active_wep_row >= 0 and active_wep_row < ents.size())
	ents[active_wep_row+1].set_hover(true)

	timer.start()

func add_weapon(swep):
	var col = kids[swep.swep_inv_slot-1]
	var swep_entry = entry.instance()
	col.add_child(swep_entry)
	swep_entry.set_wep(swep)
	
func remove_weapon(swep):
	var col = kids[swep.swep_inv_slot-1]
	for ent in col.get_children():
		if ent is Label:
			continue
		else:
			if ent.path == swep.swep_path:
				ent.queue_free()

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
	timer.connect("timeout",self,"hide_self")
	add_child(timer)
	
