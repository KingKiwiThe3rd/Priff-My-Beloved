extends Camera2D

@export var target_path: NodePath = NodePath("Priff")
@export var deadzone_size: Vector2 = Vector2(200, 150)
@export var smooth_speed: float = 5.0
@export var vertical_offset_ratio: float = 0.3  # 30% of screen height

var target: Node2D

func _ready():
	make_current()
	target = get_node_or_null(target_path)

func _process(delta):
	if not target:
		return

	# 1) Compute Priff's target position with a vertical offset
	var viewport_h = get_viewport_rect().size.y
	var y_offset = viewport_h * vertical_offset_ratio
	var target_pos = target.global_position - Vector2(0, y_offset)

	# 2) How far that is from the camera center
	var cam_pos = global_position
	var diff = target_pos - cam_pos

	# 3) Only move outside the deadzone
	var dz = deadzone_size * 0.5
	var move = Vector2.ZERO
	if diff.x > dz.x:
		move.x = diff.x - dz.x
	elif diff.x < -dz.x:
		move.x = diff.x + dz.x
	if diff.y > dz.y:
		move.y = diff.y - dz.y
	elif diff.y < -dz.y:
		move.y = diff.y + dz.y

	# 4) Smoothly nudge the camera
	var desired = cam_pos + move
	global_position = cam_pos.linear_interpolate(desired, smooth_speed * delta)
