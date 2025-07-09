extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_2d: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

const lines: Array[String] =[
	"Kys"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	DialogManager.start_dialog(global_position, lines)
	sprite.flip_h = true if interaction_area.get_overlapping_boddies()[0].global_position.x < global_position.x else false
	await DialogManager.dialog_finished
	
