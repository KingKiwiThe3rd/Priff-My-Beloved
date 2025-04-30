extends Area2D

func _ready():
	# ensure you’ve hooked up the “body_entered” signal in the editor
	print("im a coin")
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Priff":
		# 1) update GameManager
		GameManager.add_point()
	# 2) update UI under Priff
	var ui = body.get_node_or_null("UIManager")
	if ui:
		ui.add_point()
	else:
		print("UIManager not found under Priff!")
	queue_free()
