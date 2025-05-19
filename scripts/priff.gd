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

# at top of your CharacterBody2D script:

enum PlayerState { NORMAL, WALL_SLIDE }
var state = PlayerState.NORMAL

const WALL_SLIDE_SPEED = 50.0
const WALL_HANG_TIME   = 3.0
const WALL_JUMP_X      = 300.0  # ↑ increase this to round corners
const WALL_JUMP_Y      = -250.0 # ↓ decrease (make less negative) to trade vertical

var wall_dir = 0          # +1 if hanging on right wall, -1 on left
var hang_timer = WALL_HANG_TIME


func _ready():
	dash_manager.player = self  # Link Priff to DashManager
	
	# If there is a saved checkpoint, spawn at it
	if GameManager.checkpoint_position != Vector2.ZERO:
		global_position = GameManager.checkpoint_position
		spawn_point = GameManager.checkpoint_position

func _physics_process(delta: float) -> void:
	# 1) Read input_dir *once*, at the top
	var input_dir = Input.get_axis("Move Left", "Move Right")

	# 2) Your existing floor‐reset logic…
	if is_on_floor():
		state = PlayerState.NORMAL
		hang_timer = WALL_HANG_TIME
		JUMP_AMOUNT = 2
		coyote_timer = COYOTE_TIME
		dash_manager.air_dashes_used = 0
		dash_manager.extra_air_dash = false
	elif coyote_timer > 0:
		coyote_timer -= delta

	# 3) Now use input_dir inside the state machine
	match state:
		PlayerState.NORMAL:
			if not is_on_floor() and is_on_wall() and input_dir != 0:
				wall_dir = (1 if input_dir > 0 else -1)
				state = PlayerState.WALL_SLIDE
				dash_manager.reset_dash()
		# else: fall through to normal movement/gravity below
		PlayerState.WALL_SLIDE:
			# clamp vertical speed
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
			velocity.x = 0
			# on jump, bounce off
			if Input.is_action_just_pressed("Jump"):
				velocity.x = -wall_dir * WALL_JUMP_X
				velocity.y = WALL_JUMP_Y
				state = PlayerState.NORMAL
			else:
				# count down your hang time
				hang_timer -= delta
				if hang_timer <= 0:
					state = PlayerState.NORMAL
				# slide movement only
			move_and_slide()
			return  # skip the rest while in wall‐slide
			
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
