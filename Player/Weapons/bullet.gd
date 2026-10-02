extends Area2D

@export var damage := 10
@export var lifetime := 10.0


var velocity = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		queue_free()
