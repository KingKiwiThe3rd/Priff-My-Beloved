extends Area2D

@export var message : String = "Hello, world!"

var player_near := false

# Cache exactly the nodes you refer to below:
@onready var prompt      : Label          = get_node("/root/Game/UI/PromptLabel")
@onready var dialog      : PanelContainer = get_node("/root/Game/UI/SignDialog")
@onready var dialog_text : Label          = get_node("/root/Game/UI/SignDialog/VBoxContainer/DialogText")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))
	# ensure they start hidden
	prompt.visible = false
	dialog.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		prompt.text    = "Press [E] to read"
		prompt.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near    = false
		prompt.visible = false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		_show_message()

func _show_message():
	dialog_text.text = message
	dialog.visible   = true
	prompt.visible   = false
