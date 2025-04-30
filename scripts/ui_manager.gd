# UIManager.gd (attached to a Node under Priff)
extends Node

@onready var coin_counter: Label = $CoinCounter

func add_point():
	# read the global coin count and display it
	coin_counter.text = "Coins: " + str(GameManager.coins)
