extends Area2D

@export var camera_bounds: Rect2
@onready var collision_shape = $CollisionShape2D
var camera_anchors: Array[Node] = []
var current_anchor: Node = null
var player: Node = null
const ANCHOR_SWITCH_THRESHOLD: float = 100.0

func _ready():
	add_to_group("room")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for child in get_children():
		if child is Marker2D and "CameraAnchor" in child.name:
			camera_anchors.append(child)
			print("Found anchor: ", child.name, " at global: ", child.global_position)
	
	# Calculate bounds based on collision shape
	if collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		var size = shape.extents * 2
		camera_bounds = Rect2(global_position - shape.extents, size)
		print("Room bounds: ", camera_bounds, " at global_position: ", global_position)
	
	# Check for player on start
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			player = body
			set_physics_process(true)
			update_camera_anchor(true)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		set_physics_process(true)
		update_camera_anchor(true)

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		player = null
		set_physics_process(false)

func _physics_process(delta):
	if player:
		update_camera_anchor()

func update_camera_anchor(force_initial: bool = false):  # Changed from level_initial to force_initial
	if camera_anchors.is_empty():
		print("No camera anchors found in room: ", name)
		return
	var player_pos = player.global_position
	var closest_anchor = camera_anchors[0]
	var min_distance = player_pos.distance_to(closest_anchor.global_position)
	for anchor in camera_anchors:
		var distance = player_pos.distance_to(anchor.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_anchor = anchor
	if force_initial or (closest_anchor != current_anchor and min_distance < ANCHOR_SWITCH_THRESHOLD):
		current_anchor = closest_anchor
		var camera = player.get_node("Camera2D")
		if camera and camera.has_method("transition_to_room"):
			camera.transition_to_room(closest_anchor.global_position, camera_bounds)
		else:
			print("Error: Camera not found or missing transition_to_room method")

func check_player_inside():
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			player = body
			set_physics_process(true)
			update_camera_anchor(true)
