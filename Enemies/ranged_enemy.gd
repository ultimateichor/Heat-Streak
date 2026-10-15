extends Enemy


@export var bullet : PackedScene
@export var playerDistance = 350
@export var fireRate = 1.5
@export var bulletSpeed = 500
var shotCooldown = 0


func _physics_process(delta: float) -> void:
	player = GameManager.player
	if !is_instance_valid(player):
		return
		
	var to_player: Vector2 = player.global_position - global_position
	var distance = to_player.length()
	var direction = to_player.normalized()
	
	rotation = direction.angle()
	
	if distance > playerDistance + 30:
		velocity = direction * SPEED
	elif distance < playerDistance -30:
		velocity = -direction *SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	shotCooldown -= delta
	if shotCooldown <= 0:
		shotCooldown = fireRate
		_shoot(direction)
		
func _shoot(direction: Vector2) -> void:
	var bullet = bullet.instantiate()
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $Muzzle.global_position
	bullet.rotation = direction.angle()
	bullet.velocity = direction * bulletSpeed
	bullet.damage = enemyDamage
