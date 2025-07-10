extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_2d: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
var interact_count := 0

const lines: Array[String] =[
	"Kys",
	"quickly",
	"please",
	"thanks"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact():
	DialogManager.start_dialog(global_position, lines)
	await DialogManager.dialog_finished
	



## Sign.gd
#extends Area2D
#class_name Sign
#
#@export var state_dialogs: Array = [
	#["This is the first message."],        # state 0
	#["This is the follow-up message."]     # state 1
#]
#
#var state_index := 0
#@onready var interaction_area: InteractionArea = $InteractionArea
#
#func _ready():
	## wire up the interaction callback
	#interaction_area.interact = Callable(self, "_on_interact")
	## ensure the area is monitoring collisions
	#interaction_area.monitoring = true
#
#func _on_interact():
	#if state_index < state_dialogs.size():
		## launch the dialog for this state
		#DialogManager.start_dialog(global_position, state_dialogs[state_index])
		#await DialogManager.dialog_finished
		#state_index += 1
		#return
	## once you've exhausted all states, turn off the area
	#interaction_area.monitoring = false
	#queue_free()
