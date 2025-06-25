extends Area2D

@export var bounce_velocity := -150.0

func _ready():
	# make sure this Area2D actually sees the player
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		# immediately slam their Y-velocity upward
		body.velocity.y = bounce_velocity
		# reset double-jump / dash if you like:
		body.JUMP_AMOUNT = 2
		if body.dash_manager:
			body.dash_manager.reset_dash()
