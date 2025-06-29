extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_manager = $DashManager
@onready var TSlow_overlay = get_node("../CanvasLayer/TSlowOverlay")
@onready var tile_map: TileMap = $"../TileMap"
const HAZARD_TILE_IDS = [4]  # the Tile ID(s) you marked as “hazard” in your TileSet
var spawn_point : Vector2

const HAZARD_LAYER_BIT = 1 << 2  # if “Hazard” is layer 2 (zero-based bit 1)


var is_preparing_jump = false
var is_landing = false
var jump_prepare_timer = 0.0
const JUMP_PREPARE_DURATION = 0.05
const LAND_DURATION = 0.2

var landing_timer = 0.0

var JUMP_AMOUNT = 2
const JUMP_VELOCITY = -120.0
const JUMP_CUT_MULTIPLIER = 0.3
const GRAVITY = 300.0
const MAX_FALL_SPEED = 700.0

const MAX_SPEED = 50.0
const ACCELERATION = 400.0
const DECELERATION = 500.0
const AIR_CONTROL = 200.0

const COYOTE_TIME = 0.1
var coyote_timer = 0.0
var was_on_floor = false
const FAST_FALL_MULTIPLIER = 2.0  # 2× normal gravity when holding down

var is_slow_motion = false
var slow_motion_duration = 1.0
var slow_motion_scale = 0.3
var slow_motion_timer := 0.0

enum PlayerState { NORMAL, WALL_SLIDE }
var state = PlayerState.NORMAL

const WALL_SLIDE_SPEED = 30.0
const WALL_HANG_DURATION = 3.0
const WALL_JUMP_X = 40.0
const WALL_JUMP_Y = -120.0

var wall_dir = 0
var wall_hang_timer = WALL_HANG_DURATION

func _ready():
	add_to_group("player")
	# Force reset checkpoint if invalid
	if GameManager.checkpoint_position == Vector2.ZERO:
		GameManager.checkpoint_position = Vector2(91, 53)
	print("GameManager.checkpoint_position: ", GameManager.checkpoint_position)
	global_position = GameManager.checkpoint_position
	spawn_point = GameManager.checkpoint_position
	print("Player initialized at: ", global_position, " in group 'player': ", is_in_group("player"))
	dash_manager.player = self

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_axis("Move Left", "Move Right")

	# Reset on floor
	if is_on_floor():
		state = PlayerState.NORMAL
		wall_hang_timer = WALL_HANG_DURATION
		JUMP_AMOUNT = 2
		coyote_timer = COYOTE_TIME
		dash_manager.air_dashes_used = 0
		dash_manager.extra_air_dash = false
	elif coyote_timer > 0:
		coyote_timer -= delta

	# State‐machine
	match state:
		PlayerState.NORMAL:
			if not is_on_floor() and is_on_wall() and input_dir != 0 and wall_hang_timer > 0:
				wall_dir = 1 if input_dir > 0 else -1
				state = PlayerState.WALL_SLIDE
				dash_manager.reset_dash()
				print("⛰️ Entered WALL_SLIDE")
		PlayerState.WALL_SLIDE:
			# EXIT check
			if is_on_floor() or not is_on_wall() or input_dir == 0 or wall_hang_timer <= 0:
				state = PlayerState.NORMAL
			else:
				# only slide & bounce when you truly stay in WALL_SLIDE
				wall_hang_timer -= delta
				velocity.y = WALL_SLIDE_SPEED
				if Input.is_action_just_pressed("Jump"):
					velocity.x = -wall_dir * WALL_JUMP_X
					velocity.y = WALL_JUMP_Y
					state = PlayerState.NORMAL
				else:
					print("⛰️ Sliding, time left=", wall_hang_timer)
					animated_sprite_2d.play("wall_slide")
				move_and_slide()
				return  # skip the normal physics/gravity/jump below

	# gravity & quick‐fall (only here)
	# gravity & quick-fall (only here)
	if not dash_manager.is_dashing and not is_on_floor():
		# replace "fast_fall" with your actual InputMap action name
		var fall_mult = (FAST_FALL_MULTIPLIER if Input.is_action_pressed("Fast fall") and velocity.y > 0 else 1.0)
		velocity.y += GRAVITY * fall_mult * delta*0.9
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	move_and_slide()

	if Input.is_action_just_pressed("Jump") and (is_on_floor() or JUMP_AMOUNT > 0 or coyote_timer > 0) and not dash_manager.is_dashing and not is_preparing_jump:
		is_preparing_jump = true
		jump_prepare_timer = JUMP_PREPARE_DURATION
		animated_sprite_2d.play("jumpAnticipation")
		is_landing = false
		landing_timer = 0.0
	
	if is_preparing_jump:
		jump_prepare_timer -= delta
		if jump_prepare_timer <= 0:
			is_preparing_jump = false
			if (is_on_floor() or JUMP_AMOUNT > 0 or coyote_timer > 0) and not dash_manager.is_dashing:
				velocity.y = JUMP_VELOCITY
				JUMP_AMOUNT -= 1
				coyote_timer = 0
	
	var just_landed = is_on_floor() and not was_on_floor and velocity.y >= 0
	if just_landed and not dash_manager.is_dashing and not is_preparing_jump:
		is_landing = true
		landing_timer = LAND_DURATION
		animated_sprite_2d.play("fallingFollowThrough")
	
	if is_landing:
		landing_timer -= delta
		if landing_timer <= 0:
			is_landing = false
	
	if not is_on_floor() and is_landing:
		is_landing = false
		landing_timer = 0.0
	
	was_on_floor = is_on_floor()
	
	if Input.is_action_just_released("Jump") and velocity.y < 0 and not dash_manager.is_dashing:
		velocity.y *= JUMP_CUT_MULTIPLIER
	
	if Input.is_action_just_pressed("Dash"):
		dash_manager.try_dash()

	
	var direction := Input.get_axis("Move Left", "Move Right")
	if not dash_manager.is_dashing:
		var current_accel = ACCELERATION if is_on_floor() else AIR_CONTROL
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, current_accel * delta)
		animated_sprite_2d.flip_h = direction < 0 if direction != 0 else animated_sprite_2d.flip_h
	
	if dash_manager.is_dashing:
		animated_sprite_2d.play("dash")
	elif is_preparing_jump:
		pass
	elif state == PlayerState.WALL_SLIDE:
		animated_sprite_2d.play("wall_slide")
	elif is_landing:
		animated_sprite_2d.play("fallingFollowThrough")
	elif is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		if velocity.y < 25:
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
	print("Player respawned at: ", global_position)
	var areas = get_tree().get_nodes_in_group("room")
	for area in areas:
		if area is Area2D and area.has_method("check_player_inside"):
			area.check_player_inside()
						

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
	TSlow_overlay.visible = true

func stop_slow_motion():
	Engine.time_scale = 1.0
	is_slow_motion = false
	TSlow_overlay.visible = false
