extends Player

@export var acceleration = 900
@export var friction = 500
@export var steerSpeed = 3
@export var grip = 9
@export var driftGrip = 1
@export var drillDamage = 10
@export var underDrillDamage = 4
@export var underDrillKnockback := 850.0
@export var drillKnockback := 850.0 
@export var minRamSpeed := 100.0
@export var ramMinAngle := 30.0 
@export var ramMaxAngle := 70.0 
@export var surfaceDamage = 50
@export var surfaceKnockback = 1000
var currentGrip = grip
var isDig = false
var canDrill = true
var explode = false
var hit_enemies: Array = []
@export var drillTickInterval := 0.25
var drillClock := 0.0
var lastDrillHit := {}
@export var digSpeed = 425
	
	
func _ready() -> void:
	super()

func _move(direction: Vector2, delta: float) -> void:
	if !isDig:
		var throttle = Input.get_axis("Down", "Up")
		var steer = Input.get_axis("Left", "Right")
		
		var nose = Vector2.from_angle(rotation)
		
		if Input.is_action_pressed("Special"):
			currentGrip = driftGrip
		if Input.is_action_just_released("Special"):
			currentGrip = grip
		
		if throttle != 0:
			if throttle > 0:
				velocity += nose * throttle * acceleration * delta
			if throttle < 0:
				velocity += nose * throttle * (acceleration/2) * delta
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		velocity = velocity.limit_length(SPEED)
		
		var forward_speed = velocity.dot(nose)
		var speed_factor = clampf(absf(forward_speed)/ SPEED, 0.0,1.0)
		rotation += steer * steerSpeed * delta
		
		nose = Vector2.from_angle(rotation)
		forward_speed = velocity.dot(nose)
		velocity = velocity.lerp(nose * forward_speed, currentGrip * delta)
	else:
		if direction.length() > 0.3:
			velocity = direction * digSpeed
		else:
			velocity = velocity.move_toward(Vector2.ZERO, digSpeed)
	
	if Input.is_action_just_pressed("Special") and canDrill:
		if !isDig:
			_dig()
		else:
			$DrillTimer.stop()
			_surface()
			
	
func _physics_process(delta: float) -> void:
	# Run the player's _physics_process first (movement, aiming,
	# transforming). Without this, the vehicle wouldn't move at all.
	super(delta)

	drillClock += delta
	# Every area currently inside the drill's area.
	for area in $Area2D2.get_overlapping_areas():
		if not area.is_in_group("Enemy"):
			continue  # skip it and check the next one
		var enemy = area.get_parent()
		# get_instance_id() = a number unique to this enemy. Using it as the
		# key (instead of the enemy itself) avoids problems once an enemy
		# has been deleted.
		var id = enemy.get_instance_id()
		# .get(id, -INF): an enemy never hit before has no entry, so it gets
		# -INF (negative infinity), meaning it's always ready to be hit.
		if drillClock - lastDrillHit.get(id, -INF) >= drillTickInterval:
			lastDrillHit[id] = drillClock
			_drill_hit(enemy)
	
func _take_damage(amount: int, type: int) -> void:
	if type == 1:
		amount = amount/4
	else:
		amount = amount/4
	currentHealth -= amount
	GameManager.currentPlayerHealth = currentHealth
	print(currentHealth)
	UI._decrease_health(currentHealth)
	if currentHealth <= 0:
		_die()
	
func _aim(direction: Vector2, delta: float) -> void:
	pass
	
func _shoot_primary():
	pass

func _shoot_secondary():
	pass

func _dig():
	$Area2D.set_collision_layer_value(8, true)
	$Area2D.set_collision_layer_value(6, false)
	$".".set_collision_mask_value(3, false)
	$Area2D2.monitoring = false
	isDig = true
	$DrillTimer.start()
	
func _surface():
	$Area2D.set_collision_layer_value(8, false)
	$Area2D.set_collision_layer_value(6, true)
	$".".set_collision_mask_value(3, true)
	isDig = false
	canDrill = false
	$DrillCooldown.start()
	$Explosion.monitoring = true
	$SurfaceDamageTime.start()
	$Area2D2.monitoring = true

func _drill_hit(enemy) -> void:
	var currentDrillDamage
	var currentDrillKnockback
	if isDig:
		currentDrillDamage = underDrillDamage
		currentDrillKnockback = underDrillKnockback
	else:
		currentDrillDamage = drillDamage
		currentDrillKnockback = drillKnockback

	var speed := velocity.length()

	var nose := Vector2.from_angle(rotation)
	var to_enemy := global_position.direction_to(enemy.global_position)

	var side := signf(nose.cross(to_enemy))
	if side == 0.0:
		side = 1.0 if randf() < 0.5 else -1.0
	var angle := deg_to_rad(randf_range(ramMinAngle, ramMaxAngle)) * side

	var push_dir := nose.rotated(angle)
	var strength = currentDrillKnockback

	enemy.apply_knockback(push_dir * strength)
	enemy._enemy_take_damage(currentDrillDamage)


func _on_drill_timer_timeout() -> void:
	_surface()


func _on_drill_cooldown_timeout() -> void:
	canDrill = true

func _on_explosion_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy"):
		return
	var enemy = area.get_parent()
	if enemy in hit_enemies:
		return
	hit_enemies.append(enemy)

	var offset: Vector2 = enemy.global_position - $Explosion.global_position
	#var t := clampf(offset.length() / _get_explosion_radius(), 0.0, 1.0)
	#var damage_amount := roundi(explosionDamage * lerpf(1.0, minDamagePercent, t))
	#var push_strength := explosionKnockback * lerpf(1.0, minKnockbackPercent, t)
	var push_dir: Vector2
	if offset.length() > 0.0:
		push_dir = offset.normalized()
	else:
		push_dir = Vector2.from_angle(randf() * TAU)
	enemy.apply_knockback(push_dir * surfaceKnockback)
	if enemy.enemyHealth > 0:
		enemy._enemy_take_damage(surfaceDamage)


func _on_surface_damage_time_timeout() -> void:
	$Explosion.monitoring = false
