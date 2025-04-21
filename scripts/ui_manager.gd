extends Node

var coins = 0
var coin_label = null

func _ready():
	print("UIManager _ready called")
	print("Children of UIManager:")
	for child in get_children():
		print(" - ", child.name)
	
	# Try to find the label directly
	coin_label = find_label_node()
	
	if coin_label:
		update_coin_display()
	else:
		# Create a label if none exists
		create_coin_label()
		update_coin_display()

# Helper function to find any Label node
func find_label_node():
	for child in get_children():
		if child is Label:
			print("Found a Label: ", child.name)
			return child
	return null

# Create a label if none exists
func create_coin_label():
	print("Creating new coin label")
	var new_label = Label.new()
	new_label.name = "CoinCounter"
	new_label.text = "Coins: 0"
	# Set position and other properties
	new_label.position = Vector2(10, 10)
	add_child(new_label)
	coin_label = new_label

func add_point():
	coins += 1
	update_coin_display()

func reset_coins():
	coins = 0
	update_coin_display()

func update_coin_display():
	if coin_label:
		coin_label.text = "Coins: " + str(coins)
	else:
		print("ERROR: coin_label is still null!")
