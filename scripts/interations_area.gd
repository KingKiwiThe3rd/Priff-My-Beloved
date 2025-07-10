extends Area2D
class_name InteractionArea

@export var action_name: String= "interact"

var interact: Callable = func():
	pass

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))
	print("%s ready, action_name = %s" % [name, action_name])

func _on_body_entered(body):
	print("🔍 raw body_entered on ", name, ": ", body.name)
	if body.is_in_group("player"):
		print("🔵 registering AREA → ", name)
		InteractionManager.register_area(self)


func _on_body_exited(body):
	print("🔍 raw body_exited on ", name, ": ", body.name)
	if body.is_in_group("player"):
		print("🔴 unregistering AREA → ", name)
		InteractionManager.unregister_area(self)
