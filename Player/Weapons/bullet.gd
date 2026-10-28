extends Area2D

@export var damage := 10
@export var lifetime := 10.0
@export var piercing = false


var velocity = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.get_parent().enemyHealth > 0:
			area.get_parent()._enemy_take_damage(damage)
			if piercing == false:
				queue_free()
			
func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Enemy") and !body.is_in_group("Player") and piercing == false:
		queue_free()
