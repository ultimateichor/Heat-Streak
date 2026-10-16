extends Weapon
@export var pellets := 6              
@export var spread_degrees := 30.0     
@export var speed_variation := 0.15 
@export var pellet_lifetime := 0.35

func _fire() -> void:
	for i in pellets:
		var t = float(i) / max(pellets - 1, 1)  # 0.0 for the first pellet, 1.0 for the last
		var even := lerpf(-spread_degrees / 2, spread_degrees / 2, t)
		var offset := deg_to_rad(even + randf_range(-3.0, 3.0))
		var bullet = _spawn_bullet(global_rotation + offset)
		
		bullet.lifetime = pellet_lifetime
