# GameManager.gd (autoloaded as “GameManager”)
extends Node

var coins: int = 0
var checkpoint_position: Vector2 = Vector2.ZERO

func add_point():
	coins += 1
	if coins >= 1:
		_on_ten_coins_reached()

func reset_coins():
	coins = 0

func _on_ten_coins_reached() -> void:
	print("you win! here's your PRIZE [ :")
	# show red overlay, wait 3s, respawn Priff, reset coins
	var scene = get_tree().get_current_scene()
	var overlay = scene.get_node_or_null("CanvasLayer/RedOverlay")
	if overlay:
		overlay.visible = true
	await get_tree().create_timer(3.0).timeout
	if overlay:
		overlay.visible = false

	var priff = scene.get_node_or_null("Priff")
	if priff:
		priff.die_and_respawn()
	else:
		push_error("Could not find Priff for respawn!")

	reset_coins()
