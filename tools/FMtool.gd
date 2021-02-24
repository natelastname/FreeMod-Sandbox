extends Spatial

# A FreeModTool can be thought of as a piece of code that gets called when the
# player equips it through the tool selection menu and uses it through the
# wrench SWEP. Because this is all managed automatically, the amount of code
# needed to implement a tool is small. All you need to do is write a script that
# extends FreeModTool, and make sure it is located in the directory
# "res://tools/[toolname]/[toolname].gd".

# Note: because of the way that FreeModTools are handled, _init() is called
# when a tool is activated for the first time and _ready() is never called. As
# a result of this, "onready var ..." does not work. Instead, if you want to
# access something like the player inside of a FreeModTool, you must set the
# variable "player" inside of _init.

class_name FreeModTool

export(String) var fmtool_name = "Default FMTool name"
export(bool) var fmtool_use_cursor = true

# When the tool is equipped by the player, this will be called.
func fmtool_equipped():
	pass

# When the tool is unequipped by the player, this will be called.
func fmtool_unequipped():
	pass

# Called when the player swings the wrench.
func fmtool_use():
	pass

# Called every frame that the tool is active.
# For example, if the tool is supposed to highlight the object it is pointed at,
# this functionality can be implemented by providing an fmtool_process method.
# For many tools, this is not needed because you can just use fmtool_use().
func fmtool_process(_delta):
	pass
