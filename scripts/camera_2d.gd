# SmoothCamera.gd
extends Camera2D

@export var follow_strength := 0.1  # 0 = locked, 1 = full follow

func _process(delta):
	if not is_instance_valid(get_parent()):
		return

	var target_pos = get_parent().global_position
	global_position = lerp(global_position, target_pos, follow_strength)
