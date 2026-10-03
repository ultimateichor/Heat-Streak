extends CharacterBody2D

@export var maxEnemyHealth = 30
var enemyHealth
@export var enemyDamage = 25

@export var SPEED = 250
var damageTime = true

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	enemyHealth = maxEnemyHealth

func _physics_process(delta: float) -> void:
	if not player:
		return

	#chases player
	var direction := global_position.direction_to(player.global_position)
	if damageTime == true:
		velocity = direction * SPEED
		rotation = direction.angle()  
		move_and_slide()
	
	#Checks for player and calls damage function
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("Player") && damageTime == true:
			area.get_parent()._take_damage(enemyDamage)
			damageTime = false
			$DamageTimer.start()
			break
	
	
func _enemy_take_damage(damage: int) -> void:
	enemyHealth -= damage
	if enemyHealth <= 0:
		_enemy_die()
		
func _enemy_die() -> void:
	queue_free()
#Stops movement and ability to damage until timeout
func _on_damage_timer_timeout() -> void:
	damageTime = true
