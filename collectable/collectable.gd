extends RigidBody

onready var player = $"/root/World/Player"

var add_wep_on_collect = "res://weps/unarmed/unarmed.tscn"

func on_body_entered(body):
	if body.is_in_group("human"):
		player.add_wep(add_wep_on_collect)
		queue_free()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.contacts_reported = 5
	self.connect("body_entered",self,"on_body_entered")
