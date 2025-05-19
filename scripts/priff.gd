# Player Script (CharacterBody2D)
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_manager = $DashManager  # Reference the DashManager
@onready var TSlow_overlay = get_node("../CanvasLayer/TSlowOverlay")
var spawn_point : Vector2

var JUMP_AMOUNT = 2  # Number of jumps allowed (reset on ground)
const JUMP_VELOCITY = -175.0
const JUMP_CUT_MULTIPLIER = 0.3
const GRAVITY = 400.0
const MAX_FALL_SPEED = 700.0

# Movement Variables
const MAX_SPEED = 80.0  
const ACCELERATION = 300.0
const DECELERATION = 400.0
const AIR_CONTROL = 200.0

# Coyote Time Variables
const COYOTE_TIME = 0.1
var coyote_timer = 0.0
var was_on_floor = false  

var is_slow_motion = false
var slow_motion_duration = 1.0
var slow_motion_scale = 0.3  # Slower = lower value (0.3 = 30% normal speed)
var slow_motion_timer := 0.0

func _ready():
	dash_manager.player = self  # Link Priff to DashManager
	
	# If there is a saved checkpoint, spawn at it
	if GameManager.checkpoint_position != Vector2.ZERO:
		global_position = GameManager.checkpoint_position
		spawn_point = GameManager.checkpoint_position

func _physics_process(delta: float) -> void:
	if is_on_floor():
		JUMP_AMOUNT = 2
		coyote_timer = COYOTE_TIME
		dash_manager.air_dashes_used = 0
		dash_manager.extra_air_dash = false   # ← clear the power‐up here
	elif coyote_timer > 0:
		coyote_timer -= delta
		
	# Jumping
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or JUMP_AMOUNT > 0 or coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		JUMP_AMOUNT -= 1  # Use a jump
		coyote_timer = 0  
		
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
		
	# Handle Dashing
	if Input.is_action_just_pressed("Dash"):
		dash_manager.try_dash()
 
	# Apply Gravity
	if not dash_manager.is_dashing:
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)  
		
	# Movement
	var direction := Input.get_axis("Move Left", "Move Right")
	if not dash_manager.is_dashing:
		var current_accel = ACCELERATION if is_on_floor() else AIR_CONTROL
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, current_accel * delta)
		animated_sprite_2d.flip_h = direction > 0 if direction != 0 else animated_sprite_2d.flip_h
		
	# Play Animations
	if dash_manager.is_dashing:
		animated_sprite_2d.play("dash")
	elif is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else: 
			animated_sprite_2d.play("run")
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("falling")
	
	move_and_slide()
	
func set_spawn_point(new_spawn_point: Vector2):
	print("Priff has gotten the coin")
	spawn_point = new_spawn_point

func die_and_respawn():
	global_position = spawn_point
	velocity = Vector2.ZERO
	
func _process(delta):
	if Input.is_action_just_pressed("time_slow") and not is_slow_motion:
		start_slow_motion()

	if is_slow_motion:
		slow_motion_timer -= delta
		if slow_motion_timer <= 0:
			stop_slow_motion()

func start_slow_motion():
	Engine.time_scale = slow_motion_scale
	slow_motion_timer = slow_motion_duration
	is_slow_motion = true
	TSlow_overlay.visible=true

func stop_slow_motion():
	Engine.time_scale = 1.0
	is_slow_motion = false
	TSlow_overlay.visible=false
