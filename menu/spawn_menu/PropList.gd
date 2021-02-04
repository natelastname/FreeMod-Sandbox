extends ItemList

var LastItem = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	allow_rmb_select = true
	allow_reselect = true
	set_max_columns(6)
	set_same_column_width(true)
	set_fixed_column_width(65)
	set_icon_mode(ItemList.ICON_MODE_TOP)
	var MaxSlots = 30
	var Item = load("res://icon.png")
	for x in range(MaxSlots):
		add_item("My Item "+String(x),Item,true)

	
func _process(delta):	
	var Itm = get_item_at_position(get_local_mouse_position(),true)
	#Set Color Modulate
	if LastItem != Itm:
		for x in range(get_item_count()):
			if x == Itm:
				set_item_icon_modulate(x,Color(0.2,1,0.2,1))
			else:
				set_item_icon_modulate(x,Color(1,1,1,1))
			LastItem = Itm


