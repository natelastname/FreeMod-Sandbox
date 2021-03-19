extends RigidBody

onready var player = $"/root/World/map/Player"

var add_wep_on_collect = "res://weps/unarmed/unarmed.tscn"

var timer

var is_collectable = false

func on_body_entered(body):
	if body.is_in_group("human") and is_collectable:
		player.add_wep(add_wep_on_collect)
		queue_free()

func set_collectable():
	is_collectable = true		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.contacts_reported = 5
	self.connect("body_entered",self,"on_body_entered")

	# give the collectable some iframes to prevent it from being collected
	# by the player throwing it
	timer = Timer.new()
	self.add_child(timer)
	timer.set_one_shot(true)
	timer.set_wait_time(1.0)
	timer.connect("timeout",self,"set_collectable")
	timer.start()


	
