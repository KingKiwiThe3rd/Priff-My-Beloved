extends ParallaxLayer

@onready var sprite = $Sprite2D

func _ready():
	var screen_size = get_viewport().size
	var camera_zoom = 3.6 # Camera is zoomed 3x
	var sprite_scale = 1.0 / camera_zoom # Scale sprite down to compensate
	var texture_size = sprite.texture.get_size()
	print(texture_size)
	
	# Scale sprite down by 1/3 to compensate for camera zoom
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	
	# Center vertically in the visible area
	sprite.position = Vector2(screen_size.x/camera_zoom/2, screen_size.y /camera_zoom/2)
	
	# Scroll slower than camera
	motion_scale = Vector2(0.2, 0)
	
	# Motion mirroring needs to use the effective width after scaling
	# Since the sprite is scaled down, we need unscaled mirroring
	motion_mirroring = Vector2(texture_size.x/camera_zoom, 0)
	
	sprite.visible = true
	sprite.modulate = Color(1, 1, 1, 1)
	z_index = -1
	
	print("Viewport Size:", screen_size)
	print("Texture Size:", texture_size)
	print("Camera Zoom:", camera_zoom)
	print("Sprite Scale:", sprite.scale)
	print("Sprite Position:", sprite.position)
	print("Motion Mirroring:", motion_mirroring)
