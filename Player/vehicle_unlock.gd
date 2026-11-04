extends Node2D
@export var vehicleIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if vehicleIndex in GameManager.unlocked_vehicles:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		GameManager._unlock_vehicle(vehicleIndex)
		queue_free()
