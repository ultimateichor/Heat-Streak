extends "res://Player/Weapons/bullet.gd"

@export var explosionDamage = 50
@export var minDamagePercent := 0.6
@export var explosionKnockback := 1200.0
@export var minKnockbackPercent := 1

var explode = false
var hit_enemies: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if explode:
		return
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		_explode()

func _explode() -> void:
	$Explosion/Sprite2D.visible = true
	if explode:
		return
	explode = true
	velocity = Vector2.ZERO
	set_deferred("monitoring", false) 
	$Explosion.set_deferred("monitoring", true)  
	$Timer.start()  

func _on_area_entered(area: Area2D) -> void:
	if explode:
		return
	if area.is_in_group("Enemy"):
		var enemy = area.get_parent()
		if enemy.enemyHealth > 0:
			enemy._enemy_take_damage(damage)
		_explode()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy"):
		return
	var enemy = area.get_parent()
	if enemy in hit_enemies:
		return
	hit_enemies.append(enemy)

	var offset: Vector2 = enemy.global_position - $Explosion.global_position
	var t := clampf(offset.length() / _get_explosion_radius(), 0.0, 1.0)
	var damage_amount := roundi(explosionDamage * lerpf(1.0, minDamagePercent, t))
	var push_strength := explosionKnockback * lerpf(1.0, minKnockbackPercent, t)
	var push_dir: Vector2
	if offset.length() > 0.0:
		push_dir = offset.normalized()
	else:
		push_dir = Vector2.from_angle(randf() * TAU)
	enemy.apply_knockback(push_dir * push_strength)
	if enemy.enemyHealth > 0:
		enemy._enemy_take_damage(damage_amount)
			
func _get_explosion_radius() -> float:
	var shape= $Explosion/CollisionShape2D.shape
	if shape is CircleShape2D:
		return shape.radius * $Explosion.global_scale.x
	return 64
		
func _on_body_entered(body: Node2D) -> void:
	if explode:
		return
	if !body.is_in_group("Enemy") and !body.is_in_group("Player") and piercing == false:
		_explode()

func _on_timer_timeout() -> void:
	queue_free()
