# Dash Manager Script
extends Node

var player: CharacterBody2D
const DASH_INITIAL_BOOST = 340.0
const DASH_DECAY = 1400.0
const DASH_TIME = 0.2
const DASH_COOLDOWN = 0.45
@onready var particles = get_node("/root/Game/Priff/CPUParticles2D")

@onready var priff = get_node("/root/Game/Priff")

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var gravity_disabled_timer = 0.0  
var extra_air_dash = false  # Power-up variable
var air_dashes_used = 0  # Track how many air dashes have been used

func _process(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if is_dashing:
		dash_timer -= delta
		player.velocity.y = 0
		player.velocity.x = move_toward(player.velocity.x, 0, DASH_DECAY * delta)
		
		if dash_timer <= 0:
			is_dashing = false
			gravity_disabled_timer = 0.1
			
	if gravity_disabled_timer > 0:
		gravity_disabled_timer -= delta

func try_dash():
	# Exit early if on cooldown
	if dash_cooldown_timer > 0:
		return
		
	# Calculate maximum allowed air dashes
	var max_air_dashes = 1
	if extra_air_dash:
		max_air_dashes = 3
		
	# Check if we can dash
	if player.is_on_floor() or air_dashes_used < max_air_dashes:
		start_dash()
		
		# Only increment air dash counter if we're in the air
		if not player.is_on_floor():
			air_dashes_used += 1

func start_dash():
	if(priff.is_slow_motion==true):
		priff.stop_slow_motion()
	is_dashing = true
	particles.emitting=true
	var dash_direction = 1 if not player.animated_sprite_2d.flip_h else -1
	player.velocity.x = dash_direction * DASH_INITIAL_BOOST
	player.velocity.y = 0
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN

func enable_extra_air_dash():
	extra_air_dash = true  # Allows two dashes in air
	
func reset_dash():
	air_dashes_used = 0  # Reset air dash counter
	dash_cooldown_timer = 0  # Remove dash cooldown
