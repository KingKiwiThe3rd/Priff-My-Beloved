extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
var respawn_position: Vector2

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Priff":  # Ensure only Priff collects the power-up
		respawn_position = global_position
		body.set_spawn_point(respawn_position)
		GameManager.checkpoint_position = global_position
		print("body has toched the coin!!")
		flash_color()

func flash_color():
	sprite_2d.modulate = Color(0, 1, 0)
	await get_tree().create_timer(0.2).timeout
	sprite_2d.modulate = Color(1, 1, 1)
