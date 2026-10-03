extends Node2D

@export var enemy_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_enemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = $".".global_position

func _on_spawn_timer_timeout() -> void:
	$SpawnTimer.wait_time -= 0.5
	_spawn_enemy()
