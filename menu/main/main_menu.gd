extends Control

onready var tree = get_tree()

onready var initial = $InitialButtons
onready var start = $StartGame
onready var options = $Options
onready var loading = $LoadingScreen
onready var multiplayer_screen = $multiplayer

func _on_Start_pressed():
	start.visible = true

func _on_Options_pressed():
	initial.visible = false
	options.visible = true
	options.prev_menu = initial

func _on_Exit_pressed():
	tree.quit()

func _on_BackToTitle_pressed():
	initial.visible = true
	options.visible = false
	start.visible = false
	loading.visible = false
	multiplayer_screen.visible = false

func _on_multiplayer_pressed():
	initial.visible = false
	options.visible = false
	start.visible = false
	loading.visible = false
	multiplayer_screen.visible = true

	return

func _on_singleplayer_pressed():
	initial.visible = false
	options.visible = false
	start.visible = false
	loading.visible = true
	multiplayer_screen.visible = false

	goto_scene("res://world/world.tscn")
	
var loader
var wait_frames
var time_max = 100

func goto_scene(path):
	loader = ResourceLoader.load_interactive(path)
	set_process(true)
	wait_frames = 100

func update_progress():
	var progress = float(loader.get_stage()+1) / loader.get_stage_count()
	loading.progress_bar.value = progress*100

func _ready():
	set_process(false)

# If we switch to a scene with a large number of stages, the 100 frame wait time
# between polls could possibly add up to something significant.
func _process(time):

	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()	
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			# Finished loading resource.
			var resource = loader.get_resource().instance()
			get_node("/root").add_child(resource)
			self.queue_free()
			break
		elif err == OK:
			# not done loading, timed out.
			update_progress()
			wait_frames = 100
		else:
			# Encountered an error
			print("Error encountered.")
			set_process(false)
			break
