extends Camera2D

# Checked = follow the player. Unchecked = stay where it's placed in the editor.
@export var follow_player := true

# The position the camera was placed at in the editor.
var start_position := Vector2.ZERO

func _ready() -> void:
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	# Remember where it was placed, before anything moves it.
	start_position = global_position

func _physics_process(_delta: float) -> void:
	if follow_player:
		if is_instance_valid(GameManager.player):
			global_position = GameManager.player.global_position
	else:
		# Stay at (or return to) the spot it was placed in the editor.
		global_position = start_position
