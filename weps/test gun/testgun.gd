# This is included as an example of what the FreeModSwep system can do.
# Code for generating blocks is derived from this project:
# https://godotengine.org/asset-library/asset/676
# The weapon viewmodel/sounds are from the game "Unvanquished."

extends FreeModSwep

onready var anim_player = $"blaster_view_MD5_Armature/AnimationPlayer"
onready var stream_player = $"AudioStreamPlayer"

var _selected_block
onready var selected_block_texture = $"SelectedBlock"

var fire_audio_stream = preload("res://weps/test gun/hit2.wav")
var place_audio_stream = preload("res://weps/test gun/hit.wav")
var miss_audio_stream = preload("res://weps/test gun/COCK2.wav")

const TEXTURE_SHEET_WIDTH = 8
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

onready var props_node = $"/root/World/map/props"

func raise_weapon():
	anim_player.play("(blaster_view)_blaster_view_raise.md5anim",-1,1)

func lower_weapon():
	anim_player.play("(blaster_view)_blaster_view_raise.md5anim",-1,-1,true)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	swep_name = "Test gun"
	swep_desc = "Incredible brown brick gameplay!"
	swep_desc += "\nFire: remove block"
	swep_desc += "\nAim: place block"
	
	swep_prop = "res://weps/test gun/testgun_prop.tscn"
	swep_path = "res://weps/test gun/testgun.tscn"

	_selected_block = 1
	var uv = calculate_block_uvs(_selected_block)
	selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)
	
	stream_player.volume_db = 1
	stream_player.pitch_scale = 1

func swep_process(_delta):
	
	if anim_player.is_playing():
		return
	
	if Input.is_action_pressed("wep_reload"):
		anim_player.play("(blaster_view)_blaster_view_reload.md5anim",-1,1)

	if Input.is_action_just_pressed("prev_block"):
		_selected_block -= 1
		_selected_block = wrapi(_selected_block, 1, 30)
		var uv = calculate_block_uvs(_selected_block)
		selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	if Input.is_action_just_pressed("next_block"):
		_selected_block += 1
		_selected_block = wrapi(_selected_block, 1, 30)
		var uv = calculate_block_uvs(_selected_block)
		selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	var breaking = Input.is_action_pressed("wep_fire")
	var placing = Input.is_action_pressed("wep_aim")

	if breaking == placing:
			return
	
	anim_player.play("(blaster_view)_blaster_view_fire.md5anim",-1,1)

	player.raycast.cast_to = Vector3(0,0,-10)
	if player.raycast.is_colliding():
		var position = player.raycast.get_collision_point()
		var normal = player.raycast.get_collision_normal()
		var obj = player.raycast.get_collider()

		var block_global_position = (position + normal / 2).floor()
		
		if breaking:
			if obj is RigidBody:
				stream_player.set_stream(fire_audio_stream)
				stream_player.play()
				obj.queue_free()
			else:
				stream_player.set_stream(miss_audio_stream)
				stream_player.play()				
		elif placing:
			stream_player.set_stream(place_audio_stream)
			stream_player.play()
			generate_block(block_global_position, _selected_block)
	else:
		stream_player.set_stream(miss_audio_stream)
		stream_player.play()

# ------ Block generation code ------
func _create_block_collider(block_sub_position):
	var collider = CollisionShape.new()
	collider.shape = BoxShape.new()
	collider.shape.extents = Vector3.ONE / 2
	collider.transform.origin = block_sub_position + Vector3.ONE / 2
	return collider

func calculate_block_verts(block_position):
	return [
		Vector3(block_position.x, block_position.y, block_position.z),
		Vector3(block_position.x, block_position.y, block_position.z + 1),
		Vector3(block_position.x, block_position.y + 1, block_position.z),
		Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y, block_position.z),
		Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
	]

func calculate_block_uvs(block_id):
	# This method only supports square texture sheets.
	var row = block_id / TEXTURE_SHEET_WIDTH
	var col = block_id % TEXTURE_SHEET_WIDTH

	return [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col, row + 1),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
	]

func _draw_block_face(surface_tool, verts, uvs):
	surface_tool.add_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.add_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.add_uv(uvs[3]); surface_tool.add_vertex(verts[3])

	surface_tool.add_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.add_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.add_uv(uvs[0]); surface_tool.add_vertex(verts[0])


func generate_block(block_position, block_id):
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var verts = calculate_block_verts(Vector3.ONE/-2)
	var uvs = calculate_block_uvs(block_id)
	var top_uvs = uvs
	var bottom_uvs = uvs
	
	# Bush blocks get drawn in their own special way.
	if block_id == 27 or block_id == 28:
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[7], verts[5]], uvs)
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[2], verts[0]], uvs)
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[6], verts[4]], uvs)
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[3], verts[1]], uvs)
	else:		
		# Allow some blocks to have different top/bottom textures.
		if block_id == 3: # Grass.
			top_uvs = calculate_block_uvs(0)
			bottom_uvs = calculate_block_uvs(2)
		elif block_id == 5: # Furnace.
			top_uvs = calculate_block_uvs(31)
			bottom_uvs = top_uvs
		elif block_id == 12: # Log.
			top_uvs = calculate_block_uvs(30)
			bottom_uvs = top_uvs
		elif block_id == 19: # Bookshelf.
			top_uvs = calculate_block_uvs(4)
			bottom_uvs = top_uvs

		# Main rendering code for normal blocks.
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], uvs)
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], uvs)
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], uvs)
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], uvs)
		_draw_block_face(surface_tool, [verts[4], verts[5], verts[0], verts[1]], bottom_uvs)
		_draw_block_face(surface_tool, [verts[2], verts[3], verts[6], verts[7]], top_uvs)


	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	surface_tool.index()

	var array_mesh = surface_tool.commit()
	var mi = MeshInstance.new()
	mi.mesh = array_mesh
	mi.material_override = preload("res://world/textures/material.tres")
	var collider = _create_block_collider(Vector3.ONE/-2)
	var rb = RigidBody.new()
	rb.global_transform.origin = block_position+(Vector3.ONE/2)
	rb.set_mode(1)
	rb.add_child(collider)
	rb.add_child(mi)
	props_node.add_child(rb)

	
