extends Control

onready var player = $"/root/World/Player"
onready var ammo_label = $"Panel/bullets"
onready var mags_label = $"Panel/mags"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ammo_label.text = str(player.active_wep_node.ammo)
	mags_label.text = str(player.active_wep_node.mags)
