extends Viewport

onready var skybox_cam = $"Camera"
onready var player = $"/root/World/Player"
var cam_pos

func _ready():
	cam_pos = skybox_cam.global_transform.origin
	
func _process(delta):
	skybox_cam.transform = player.head.global_transform
	skybox_cam.global_transform.origin = cam_pos
