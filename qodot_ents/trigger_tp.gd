class_name trigger_tp
extends Area
tool

export(Dictionary) var properties setget set_properties

func set_properties(new_properties : Dictionary) -> void:
	if(properties != new_properties):
		properties = new_properties
		update_properties()

func update_properties():
	pass
	
func _body_entered(body):
	if body.is_in_group("agent") == false:
		return
	
	var target_found = false
	var target_pos
	var target_angle

	var kids = get_parent().get_children()
	for kid in kids:
		if not "properties" in kid:
			continue
		elif kid.properties["classname"] != "info_teleport_destination":
			continue
		elif kid.properties["targetname"] != properties["target"]:
			continue
		elif target_found == true:
			print("ERROR: Multiple teleport targets found:"+properties["target"])
			return
		else:
			target_found = true
			#target_pos = kid.properties["origin"]
			target_pos = kid.global_transform.origin
			target_angle = float(kid.properties["angle"])/180
			target_angle = target_angle*PI
				
	if target_found == false:
		print("ERROR: teleport target not found:"+properties["target"])
		return
	#print("found teleport target")
	#target_pos = FileUtil.parse_vec3(target_pos)
	#target_pos = target_pos/16
	
	target_angle = target_angle + PI

	# This is a crude way of setting the player's azimuth.
	# Currently, there is not a consistent way to do this for all NPCs.
	if "mouse_motion" in body:
		body.mouse_motion.x = (target_angle)/-0.001
			
	body.velocity = Basis(Vector3.UP, target_angle)*(-1*body.velocity)
	body.velocity.y = 0
			
	target_pos.y += 2.05
	body.global_transform.origin = target_pos

func _ready():
	for kid in get_children():
		if kid is MeshInstance:
			kid.visible = false
	self.connect("body_entered", self, "_body_entered")

# not sure if this is needed
func get_class() -> String:
	return 'trigger_tp'
