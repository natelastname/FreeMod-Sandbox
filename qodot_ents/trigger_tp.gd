class_name trigger_tp
extends Area
tool

func _body_entered(body):
	if body.is_in_group("npc"):
		print("body entered")

func _ready():
	if not Engine.editor_hint:
		# Code to execute when in game.
		self.connect("body_entered", self, "_body_entered")

	
	
func update_properties():
	for child in get_children():
		#remove_child(child)
		#child.queue_free()
		pass
		
	#var light_node = Spatial.new()
	#add_child(light_node)
	
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			var edited_scene_root = tree.get_edited_scene_root()
			if edited_scene_root:
				#light_node.set_owner(edited_scene_root)
				pass
