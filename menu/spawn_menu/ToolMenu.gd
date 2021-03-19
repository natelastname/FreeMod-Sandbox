extends ItemList

var fs_util = preload("res://util/file_util.gd")

var LastItem = -1
var FMtools = []

# Called when the node enters the scene tree for the first time.
func _ready():	
	visible = true
	allow_rmb_select = true
	allow_reselect = true
	set_max_columns(1)
	set_same_column_width(true)
	#set_fixed_column_width(65)
	set_icon_mode(ItemList.ICON_MODE_TOP)

	FMtools = FileUtil.list_files("res://tools")
	for FMtool in FMtools:
		add_item(FMtool, null, true)

func _equip_tool(tool_name):
	var player = get_node("/root/World/map/Player")
	print("equipping tool "+tool_name+"...")
	var status = player.equip_wep_by_path("res://weps/wrench/wrench.tscn")

	if status == false:
		print("player does not have wrench.")
		return

	var wrench = player.active_wep_node
	wrench.set_tool(tool_name)
	
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var Itm = get_item_at_position(get_local_mouse_position(),true)
	
	if Itm == -1:
		return

	if Input.is_action_just_pressed("wep_fire") and visible:
		var tool_name = get_item_text(Itm)
		_equip_tool(tool_name)
		LastItem = Itm
	
	# Highlight the last prop that was clicked
	if LastItem != Itm:
		for x in range(get_item_count()):
			if x == Itm:
				set_item_icon_modulate(x,Color(0.2,1,0.2,1))
			else:
				set_item_icon_modulate(x,Color(1,1,1,1))
		LastItem = Itm
