# Blueberry Power-up Script
extends Area2D

@onready var sprite = $AnimatedSprite2D  
@onready var collision_shape = $CollisionShape2D  
const RESPAWN_TIME = 5.0  

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Priff":  # Ensure only Priff collects the power-up
		print("Blueberry collected!")  # Debugging
		
		var dash_manager = body.get_node("DashManager")  # Get DashManager
		if dash_manager:
			dash_manager.enable_extra_air_dash()  # Grant an extra air dash
			dash_manager.reset_dash()  # Reset dashes and cooldown
			
		# Change sprite animation to outline
		sprite.play("outline")
		
		# Disable collision
		collision_shape.set_deferred("disabled", true)  
		
		# Start respawn timer
		await get_tree().create_timer(RESPAWN_TIME).timeout
		
		# Respawn the blueberry
		sprite.play("default")  
		collision_shape.set_deferred("disabled", false)
