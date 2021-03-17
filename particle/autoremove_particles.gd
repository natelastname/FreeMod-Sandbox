extends Spatial

onready var timer = $"Timer"
onready var particles = $"Particles"

func remove_self():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	#var down = to_local(Vector3(0,-1,0))
	#particles.process_material.gravity = Vector3(0,0,0)

	var lifetime = 0
	for kid in get_children():
		if kid is Particles:
			kid.set_one_shot(true)
			kid.set_emitting(true)
			if lifetime < kid.lifetime:
				lifetime = kid.lifetime

	timer.set_wait_time(lifetime)
	timer.connect("timeout",self,"remove_self")
	timer.start()
