extends Node2D
@export var counter = 1000
var winCheck = false
@onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = str(counter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if counter == 0 and winCheck == false:
		winCheck = true
		timer.paused = true
		%floorCounter.text = str("Win")
		# Land animation / walk off time
		
		await get_tree().create_timer(1.0).timeout
		await %ColorRect._fadeOut()
		GameManager._end_game()
		get_tree().change_scene_to_file("res://UI/Screens/Win/Win_Screen.tscn")


func _on_timer_timeout() -> void:
	counter -= 1
	%floorCounter.text = str(counter)
	if $Timer.wait_time >= 0.1:
		$Timer.wait_time -= 0.1
