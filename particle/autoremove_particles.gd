extends Spatial

onready var timer = $"Timer"
onready var particles = $"Particles"

func remove_self():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(particles.lifetime)
	timer.connect("timeout",self,"remove_self")
	#var down = to_local(Vector3(0,-1,0))
	#particles.process_material.gravity = Vector3(0,0,0)
	particles.set_one_shot(true)
	particles.set_emitting(true)
	timer.start()
