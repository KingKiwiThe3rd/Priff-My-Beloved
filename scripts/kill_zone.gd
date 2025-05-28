extends Area2D

@onready var timer: Timer = $Timer
@onready var priff = get_node("/root/Game/Priff")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# now “_delta” silences the warning
	pass


func _on_body_entered(body: Node2D) -> void:
	print("you died from killzone")
	Engine.time_scale = 0.25  # Slow down the game time during death
	body.get_node("CollisionShape2D").queue_free()  # Free the collider if needed
	timer.start()  # Start any timer for respawn or other purposes


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	priff.die_and_respawn()  # Call the fade-out respawn function
	get_tree().reload_current_scene()
	
