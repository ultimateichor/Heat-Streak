extends Enemy
const SWARM_SCENE = preload("res://Enemies/SWenemy.tscn")

func _on_timer_timeout() -> void:
	spawn_minion()

func spawn_minion() -> void:
	
	var SWARM = SWARM_SCENE.instantiate()
	
	
	SWARM.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	
	 
	get_tree().current_scene.add_child(SWARM)
