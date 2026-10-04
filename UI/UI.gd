extends Control

@export var winCounter : Label
@export var health : Label
@export var counter = 40
@export var healthCounter = 100
var enemiesKilled
var enemiesNeeded = 80

@onready var timer = $Timer

var winCheck = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	winCounter.text = str(enemiesNeeded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	winCounter.text = str(enemiesNeeded)
	if enemiesNeeded == 0 and winCheck == false:
		winCheck = true
		winCounter.text = str("Win")
		# Land animation / walk off time
		
		#await get_tree().create_timer(1.0).timeout
	#	await %ColorRect._fadeOut()
		GameManager._end_game()
		get_tree().change_scene_to_file("res://UI/Screens/Win/Win_Screen.tscn")
		
#	$livesCounter.text = str(livesCounter)

func _decrease_health(amount: int):
	health.text = str(amount)


	
