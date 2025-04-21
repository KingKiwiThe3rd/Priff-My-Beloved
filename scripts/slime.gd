extends Node2D

const SPEED =60
# Called when the node enters the scene tree for the first time.
var direction = 1

@onready var ray_cast_wall_right: RayCast2D = $RayCastWallRight
@onready var ray_cast_wall_left: RayCast2D = $RayCastWallLeft

@onready var ray_cast_right: RayCast2D = $RayCastFloorRight
@onready var ray_cast_left: RayCast2D = $RayCastFloorLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not ray_cast_right.is_colliding():
		direction =-1
		animated_sprite_2d.flip_h= true
		
	if not ray_cast_left.is_colliding():
		animated_sprite_2d.flip_h= false
		direction =1

	if  ray_cast_wall_right.is_colliding():
		direction =-1
		animated_sprite_2d.flip_h= true
		
	if ray_cast_wall_left.is_colliding():
		direction =1
		animated_sprite_2d.flip_h= false
		
	position.x += direction *SPEED *delta
	
