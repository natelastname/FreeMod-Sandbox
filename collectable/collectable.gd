extends RigidBody

onready var player = $"/root/World/map/Player"
var add_wep_on_collect = "res://weps/unarmed/unarmed.tscn"
var timer

func on_body_entered(body):
	if body.is_in_group("agent"):
		player.add_wep(add_wep_on_collect)
		queue_free()

var collectable = false
var mesh = null
var mesh_basis
func set_collectable():
	print("setting to collectable")
	for kid in get_children():
		if kid is MeshInstance:
			mesh = kid
		else:
			kid.queue_free()

	if mesh == null:
		return

	#self.set_mode(RigidBody.MODE_RIGID)
	self.look_at(Vector3(0,0,1), Vector3.UP)
	mesh_basis = mesh.transform.basis
	
	var collider = CollisionShape.new()
	collider.shape = BoxShape.new()
	collider.shape.extents = Vector3(1,1,1)
	#mesh.transform.origin += Vector3(0,2,0)
	self.global_transform.origin += Vector3(1,1,1)/2
	add_child(collider)
	
	self.connect("body_entered",self,"on_body_entered")
	collectable = true
	
var theta = 0
func _process(_delta):
	if not collectable:
		return

	theta += _delta*2*PI
	mesh.global_transform.basis = mesh_basis.rotated(Vector3.UP, theta)
	mesh.translation.y = sin(theta)/3
	
			
# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.contacts_reported = 5

	# give the collectable some iframes to prevent it from being collected
	# by the player throwing it
	timer = Timer.new()
	self.add_child(timer)
	timer.set_one_shot(true)
	timer.set_wait_time(1.0)
	timer.connect("timeout",self,"set_collectable")
	timer.start()


	
