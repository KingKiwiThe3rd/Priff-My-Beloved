extends Node2D
@onready var player = get_node("/root/Game/Priff")
@onready var label =$Label


const base_text = "[E] to "

var active_areas = []
var can_interact = true

func _ready():
	add_to_group("player")
	print(">>> Player ready. in_group(\"player\"): ", is_in_group("player"))
	# … the rest of your _ready() …

func register_area(area):
	if not area in active_areas:
		active_areas.append(area)
		print("InteractionManager: registered area -> ", area.name,   #
			  " (now ", active_areas.size(), " areas)")     #


func unregister_area (area: InteractionArea):
	var index =active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		print("InteractionManager: unregistered area -> ", area.name,    #
		" (now ", active_areas.size(), " areas)")

func _process(delta):
	if active_areas.size() > 0 && can_interact:
		print("InteractionManager: have ", active_areas.size(), " areas; sorting…") #
		active_areas.sort_custom(_sort_by_distance_to_player)    #
		var a = active_areas[0]    #
		print(" → closest area is ", a.name, " at ", a.global_position)   #
		label.text = base_text + active_areas[0].action_name.capitalize()   #had an error here not sure if it means anything
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x /2
		label.show()
	else:
		label.hide()


func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player
	

func _input(event):
	if event.is_action_pressed("Interact") && can_interact:
		print("InteractionManager: Interact pressed; areas = ", active_areas)
		if active_areas.size() >0:
			can_interact =false
			label.hide()
			
			await  active_areas[0].interact.call()
			can_interact = true
