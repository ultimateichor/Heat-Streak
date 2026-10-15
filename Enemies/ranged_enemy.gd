extends Enemy


@export var bullet : PackedScene
@export var playerDistance = 350
@export var fireRate = 1.5
@export var bulletSpeed = 500
var shotCooldown = 0
@export var bullet_scene: PackedScene
@export var distance_variation := 80.0   
@export var orbit_speed := 0.3          
@export var separation_radius := 120.0  
@export var separation_strength := 1.5  

var orbit_angle := 0.0  
var orbit_dir := 1.0     
var my_distance := 0.0

func _ready() -> void:
	super()
	add_to_group("RangedEnemy")
	orbit_angle= randf() * TAU
	orbit_dir = 1.0 if randf() < 0.5 else -1.0
	my_distance = playerDistance + randf_range(-distance_variation, distance_variation)
	shotCooldown = randf_range(0.0, fireRate)

func _physics_process(delta: float) -> void:
	player = GameManager.player
	if !is_instance_valid(player):
		return
	
	if knockback.length() > 10.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery * delta)
		move_and_slide()
		return
		
	orbit_angle += orbit_speed * orbit_dir * delta
	var target: Vector2 = player.global_position + Vector2.from_angle(orbit_angle) * my_distance

	var to_target := target - global_position
	var move_dir := Vector2.ZERO
	if to_target.length() > 20.0:
		move_dir = to_target.normalized()
	move_dir = (move_dir + _get_separation() * separation_strength).limit_length(1.0)
	velocity = move_dir * SPEED
	move_and_slide()

	var to_player: Vector2 = player.global_position - global_position
	var aim_dir := to_player.normalized()
	rotation = aim_dir.angle()

	shotCooldown -= delta
	if shotCooldown <= 0.0:
		shotCooldown = fireRate
		_shoot(aim_dir)
		
func _get_separation() -> Vector2:
	var push := Vector2.ZERO
	for other in get_tree().get_nodes_in_group("RangedEnemy"):
		if other == self:
			continue 
		var offset: Vector2 = global_position - other.global_position
		var dist := offset.length()
		if dist > 0.0 and dist < separation_radius:
			push += offset.normalized() * (1.0 - dist / separation_radius)
	return push
		
func _shoot(direction: Vector2) -> void:
	var bullet = bullet.instantiate()
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $Muzzle.global_position
	bullet.rotation = direction.angle()
	bullet.velocity = direction * bulletSpeed
	bullet.damage = enemyDamage
