#extends Camera2D
#
#@export var target_path: NodePath = NodePath("Priff")
#@export var deadzone_size: Vector2 = Vector2(200, 150)
#@export var smooth_speed: float = 5.0
#@export var vertical_offset_ratio: float = 0.3  # 30% of screen height
#
#var target: Node2D
#
#func _ready():
	#make_current()
	#target = get_node_or_null(target_path)
#
#func _process(delta):
	#if not target:
		#return
#
	## 1) Compute Priff's target position with a vertical offset
	#var viewport_h = get_viewport_rect().size.y
	#var y_offset = viewport_h * vertical_offset_ratio
	#var target_pos = target.global_position - Vector2(0, y_offset)
#
	## 2) How far that is from the camera center
	#var cam_pos = global_position
	#var diff = target_pos - cam_pos
#
	## 3) Only move outside the deadzone
	#var dz = deadzone_size * 0.5
	#var move = Vector2.ZERO
	#if diff.x > dz.x:
		#move.x = diff.x - dz.x
	#elif diff.x < -dz.x:
		#move.x = diff.x + dz.x
	#if diff.y > dz.y:
		#move.y = diff.y - dz.y
	#elif diff.y < -dz.y:
		#move.y = diff.y + dz.y
#
	## 4) Smoothly nudge the camera
	#var desired = cam_pos + move
	#global_position = cam_pos.linear_interpolate(desired, smooth_speed * delta)






extends Camera2D

var target_position: Vector2 = Vector2.ZERO
var transitioning: bool = false
var player: Node = null

func _ready():
	player = get_parent()  # Assume player is the parent
	target_position = global_position
	global_position = global_position.round()
	print("Camera initialized at: ", global_position, " zoom: ", zoom, " parent: ", player.name)

func _physics_process(delta):
	# Keep camera locked to target_position (anchor) without following player
	global_position = global_position.lerp(target_position, 10.0 * delta).round()
	# Ensure pixel-perfect rendering
	global_position = global_position.round()

func transition_to_room(new_anchor: Vector2, bounds: Rect2, duration: float = 0.3):
	if transitioning:
		print("Camera transition skipped: already transitioning")
		return
	transitioning = true
	print("Camera transitioning to: ", new_anchor, " from: ", global_position)

	# Set camera limits
	limit_left = bounds.position.x
	limit_right = bounds.position.x + bounds.size.x
	limit_top = bounds.position.y
	limit_bottom = bounds.position.y + bounds.size.y
	print("Camera limits set: left=", limit_left, " right=", limit_right, " top=", limit_top, " bottom=", limit_bottom)

	# Tween to new anchor (player physics remains enabled for control)
	var tween = create_tween()
	tween.tween_property(self, "target_position", new_anchor, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_transition_complete)

func _on_transition_complete():
	transitioning = false
	target_position = target_position.round()
	global_position = target_position
	print("Camera transition complete to: ", target_position)
