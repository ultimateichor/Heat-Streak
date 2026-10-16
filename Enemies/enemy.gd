class_name Enemy

extends CharacterBody2D
@export var knockback_recovery := 1500.0
@export var maxEnemyHealth = 30
var enemyHealth
@export var enemyDamage = 25
@export var type = 1
@export var SPEED = 250
var damageTime = true
var knockback := Vector2.ZERO
var player: CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var UI: Control 

func _ready() -> void:
	UI = get_tree().get_first_node_in_group("UI")
	player = get_tree().get_first_node_in_group("Player")
	enemyHealth = maxEnemyHealth

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return

	#chases player
	var direction := global_position.direction_to(player.global_position)
	var knocked_back := knockback.length() > 10.0

	if knocked_back:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery * delta)
		move_and_slide()
	elif damageTime == true:
		velocity = direction * SPEED
		rotation = direction.angle()
		move_and_slide()

	if not knocked_back:
		for area in $Area2D.get_overlapping_areas():
			if area.is_in_group("Player") && damageTime == true:
				area.get_parent()._take_damage(enemyDamage, type)
				damageTime = false
				$DamageTimer.start()
				break
	
	
func _enemy_take_damage(damage: int) -> void:
	if enemyHealth > 0:
		enemyHealth -= damage
	if enemyHealth <= 0:
		_enemy_die()
		
func _enemy_die() -> void:
	UI.enemiesNeeded -= 1
	queue_free()
#Stops movement and ability to damage until timeout
func _on_damage_timer_timeout() -> void:
	damageTime = true
	
func apply_knockback(force: Vector2) -> void:
	knockback = force
