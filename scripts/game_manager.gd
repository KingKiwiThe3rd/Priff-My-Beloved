extends Node

@onready var coin_counter: Label = $CoinCounter

var score =0
var checkpoint_position: Vector2 = Vector2.ZERO
func add_point():
	score +=1
	coin_counter.text ="you're score is " + str(score)

#func _process(delta):
	#coin_counter.global_position = get_viewport().get_camera_2d().global_position + Vector2(-130, -90)
