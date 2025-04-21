extends Area2D

func _ready() -> void:
	print("im a coin")
	# Make sure collision is enabled
	monitoring = true
	monitorable = true


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Priff":
		emit_signal("coin_collected")
		
		# Optional: Play collection animation/sound
		# $AnimationPlayer.play("collect")
		# $AudioStreamPlayer.play()
		
		# Queue free with a slight delay if using animations
		# await $AnimationPlayer.animation_finished
		 # Try to get the UI Manager
		var player = body
		var ui_manager = player.get_node_or_null("UIManager")
		if ui_manager:
			print("UI Manager found! Adding point...")
			ui_manager.add_point()
		else:
			print("UI Manager NOT found on player!")
		queue_free()
