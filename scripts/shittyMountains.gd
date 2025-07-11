extends ParallaxLayer
@onready var sprite = $Sprite2D 

func _ready():
	var screen_size = get_viewport().size
	var zoom_factor = 3.0 # Camera zoom from Inspector
	sprite.scale = Vector2(1.0 / zoom_factor, 1.0 / zoom_factor) # 0.333 for 1152x648
	sprite.position = screen_size / (2 * zoom_factor) # (192, 108) for 384x216 view
	motion_scale = Vector2(0, 0) # Static
	sprite.visible = true
	sprite.modulate = Color(1, 1, 1, 1)
	z_index = -1
	print("Viewport Size:", screen_size)
	print("Texture Size:", sprite.texture.get_size())
	print("Sprite Scale:", sprite.scale)
	print("Sprite Position:", sprite.position)
