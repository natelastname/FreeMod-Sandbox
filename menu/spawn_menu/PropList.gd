extends ItemList

onready var player = $"/root/World/Player"
onready var prop_node = $"/root/World/map/props"

var sound_direct = preload("res://audio/sound_direct.tscn")
var sound_direct_fact 
var spawn_sound = preload("res://sounds/spawn.wav")

var LastItem = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_direct_fact = sound_direct.instance() 
	visible = true
	allow_rmb_select = true
	allow_reselect = true
	set_max_columns(5)
	set_same_column_width(true)
	#set_fixed_column_width(65)
	set_icon_mode(ItemList.ICON_MODE_TOP)

func set_props(props):
	var MaxSlots = 30
	var Item = load("res://icon.png")
	for x in props:
		if x != "":
			add_item(x,null,true)

func _spawn_prop(prop_name):
	var prop_dir = "res://props/"+prop_name+"/"+prop_name+".tscn" 
	print("spawning prop: "+prop_dir)
	var prop = load(prop_dir).instance()
	player.raycast.cast_to = Vector3(0,0,-25)
	var spawn_pos = Vector3(0,0,0)
	if player.raycast.is_colliding():
		spawn_pos = player.raycast.get_collision_point()
	else:
		spawn_pos = player.head.translation + player.head.to_global(Vector3(0,0,-25))
	
	# find the mesh instance of the prop
	var n=[]
	for c in prop.get_children():
		if c is MeshInstance:
			n.append(c)

	# Only one meshInstance allowed for each prop (for now.)
	assert(n.size() == 1)
		
	# find the minimum y of any vertex in the mesh
	var mdt = MeshDataTool.new() 
	var nd = n[0]
	var m = nd.get_mesh()
	mdt.create_from_surface(m, 0)
	var min_y = nd.transform.xform(mdt.get_vertex(0)).y
	for vtx in range(mdt.get_vertex_count()):
		var vert = mdt.get_vertex(vtx)
		var pos = nd.transform.xform(vert)
		if pos.y < min_y:
			min_y = pos.y

	# move the prop up s.t. the lowest vertex has y equal to spawn_pos.y
	prop.translation = spawn_pos-Vector3(0,min_y-0.05,0)
	prop_node.add_child(prop)
	
	var sound = sound_direct_fact.duplicate()
	add_child(sound)
	sound.play_sound(spawn_sound)




func _process(_delta):

	var Itm = get_item_at_position(get_local_mouse_position(),true)
	
	if Itm == -1:
		return

	if Input.is_action_just_pressed("wep_fire") and visible:
		_spawn_prop(get_item_text(Itm))
		LastItem = Itm
	
	# Highlight the last prop that was clicked
	if LastItem != Itm:
		for x in range(get_item_count()):
			if x == Itm:
				set_item_icon_modulate(x,Color(0.2,1,0.2,1))
			else:
				set_item_icon_modulate(x,Color(1,1,1,1))
			LastItem = Itm



		


