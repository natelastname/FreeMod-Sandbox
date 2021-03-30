extends FreeModSwep
class_name MeleeWep

var anim_player
var viewmodel

export(String) var attack_anim = "NONE"
export(AudioStreamSample) var attack_audio_stream = null
export(float) var swing_range = 6
export(int) var damage_per_hit = 50

var bullethole = preload("res://particle/impact_dust.tscn")
var impact_audio_streams = [
	preload("res://weps/shared/ricochet0.wav"),
	preload("res://weps/shared/ricochet1.wav"),
	preload("res://weps/shared/ricochet2.wav"),
	preload("res://weps/shared/ricochet3.wav")
	]

func attack():
	AudioUtil.play_direct(attack_audio_stream)
	player.raycast.cast_to = Vector3(0,0,-swing_range)
	if not player.raycast.is_colliding():
		return

	var point_hit = player.raycast.get_collision_point()
	var hit_normal = player.raycast.get_collision_normal()
	var object_hit = player.raycast.get_collider()

	var impact_audio_stream = impact_audio_streams[randi() % 4]
	AudioUtil.play_at_pos(impact_audio_stream, point_hit)

	var impact_decal = bullethole.instance()
	object_hit.add_child(impact_decal)
	impact_decal.global_transform.origin = point_hit

	if hit_normal == Vector3.UP:
		# doesn't matter as long as it's in the xz-plane
		hit_normal = Vector3(1,0,0)
		impact_decal.look_at(point_hit + Vector3.UP, hit_normal)
	else:
		impact_decal.look_at(point_hit + hit_normal, Vector3.UP)

	if object_hit is generic_npc:
		object_hit.apply_damage(damage_per_hit)
		

func swep_process(_delta):
	if anim_player.is_playing():
		return
	else:
		anim_player.seek(0)
	if Input.is_action_just_pressed("wep_fire"):
		if attack_anim != "NONE":
			anim_player.play(attack_anim)
		attack()
			
func _ready():
	for child in get_children():
		if child is MeshInstance:
			viewmodel = child
			anim_player = child.get_children()[0]
	assert(anim_player is AnimationPlayer)
