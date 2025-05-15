# CameraZone.gd
extends Area2D

@export var camera_bounds: Rect2 = Rect2()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Priff":
		var cam = body.get_node("Camera2D")
		cam.limit_left   = int(camera_bounds.position.x)
		cam.limit_top    = int(camera_bounds.position.y)
		cam.limit_right  = int(camera_bounds.position.x + camera_bounds.size.x)
		cam.limit_bottom = int(camera_bounds.position.y + camera_bounds.size.y)

func _on_body_exited(body):
	if body.name == "Priff":
		var cam = body.get_node("Camera2D")
		# “Disable” clamping by using huge limits:
		cam.limit_left   = -100000
		cam.limit_top    = -100000
		cam.limit_right  =  100000
		cam.limit_bottom =  100000
