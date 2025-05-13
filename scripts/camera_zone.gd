# CameraZone.gd
extends Area2D

@export var camera_bounds: Rect2 = Rect2()


func _ready():
	print("CameraZone ready")

func _on_body_entered(body):
	print("ENTERED ZONE: ", body.name)
	if body.name == "Priff":
		var cam = body.get_node_or_null("Camera2D")
		if cam:
			# inside _on_body_entered:

			cam.limit_left = int(camera_bounds.position.x)
			cam.limit_top = int(camera_bounds.position.y)
			cam.limit_right = int(camera_bounds.position.x + camera_bounds.size.x)
			cam.limit_bottom = int(camera_bounds.position.y + camera_bounds.size.y)
			print("Camera limits updated to: ", camera_bounds)

func _draw():
	draw_rect(camera_bounds, Color.RED, false)
