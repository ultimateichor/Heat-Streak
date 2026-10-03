extends Control

@export var winTimer : Label
@export var health : Label
@export var counter = 40
@export var healthCounter = 100

@onready var timer = $Timer

var winCheck = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	winTimer.text = str(counter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if counter == 0 and winCheck == false:
		winCheck = true
		timer.paused = true
		winTimer.text = str("Win")
		# Land animation / walk off time
		
		#await get_tree().create_timer(1.0).timeout
	#	await %ColorRect._fadeOut()
		GameManager._end_game()
		get_tree().change_scene_to_file("res://UI/Screens/Win/Win_Screen.tscn")
		
#	$livesCounter.text = str(livesCounter)

func _decrease_health(amount: int):
	health.text = str(amount)

func _on_timer_timeout() -> void:
	counter -= 1
	winTimer.text = str(counter)
	
