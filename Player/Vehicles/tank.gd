extends Player

@export var acceleration = 900
@export var friction = 500
@export var steerSpeed = 3
@export var grip = 9
@export var driftGrip = 1
@export var ramDamage = 15
@export var ramKnockback := 1000.0 
@export var minRamSpeed := 100.0
@export var ramMinAngle := 30.0 
@export var ramMaxAngle := 70.0 
var currentGrip = grip
var cannonAngle = 0
	
	
func _ready() -> void:
	super()
	cannonAngle = $Cannon.global_rotation

func _move(direction: Vector2, delta: float) -> void:
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
	
	if Input.is_action_just_pressed("Special"):
		_shoot_primary()
	
func _take_damage(amount: int, type: int) -> void:
	if type == 1:
		amount = amount/3
	else:
		amount = amount/3
	currentHealth -= amount
	print(currentHealth)
	UI._decrease_health(currentHealth)
	if currentHealth <= 0:
		_die()
	
func _aim(direction: Vector2, delta: float) -> void:
	var aim := Input.get_vector("Look Left", "Look Right", "Look Up", "Look Down")
	#print(direction)
	if aim.length() > 0.3:
		using_controller_right = true
		target_angle = aim.angle()
	else:
		using_controller_right = false

	if using_controller:
		cannonAngle = lerp_angle(cannonAngle, target_angle, TURN_SPEED * delta)
	else:
		cannonAngle = (get_global_mouse_position() - $Cannon.global_position).angle()
	$Cannon.global_rotation = cannonAngle
	
func _shoot_primary():
	$Cannon/CannonSprite/BaseWeapon._try_fire(Input.is_action_just_pressed("Special"))

func _shoot_secondary():
	pass

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy"):
		return
	var enemy = area.get_parent()

	var speed := velocity.length()
	if speed < minRamSpeed:
		return 

	var nose := Vector2.from_angle(rotation)
	var to_enemy := global_position.direction_to(enemy.global_position)

	var side := signf(nose.cross(to_enemy))
	if side == 0.0:
		side = 1.0 if randf() < 0.5 else -1.0
	var angle := deg_to_rad(randf_range(ramMinAngle, ramMaxAngle)) * side

	var push_dir := nose.rotated(angle)
	var strength := ramKnockback * (speed / SPEED)

	enemy.apply_knockback(push_dir * strength)
	enemy._enemy_take_damage(ramDamage)
