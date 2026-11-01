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
@export var minSpeed = 700
var currentSpeed = 0
var currentGrip = grip
	
func _move(direction: Vector2, delta: float) -> void:
	var throttle
	var steer = Input.get_axis("Left", "Right")
	if using_controller:
		throttle = Input.get_axis("Shoot Secondary", "Shoot Primary")
	else:
		throttle = Input.get_axis("Down", "Up")

	var nose = Vector2.from_angle(rotation)

	var speed: float = velocity.length()

	#if Input.is_action_pressed("Special"):
		#currentGrip = driftGrip
	#if Input.is_action_just_released("Special"):
		#currentGrip = grip

	if throttle > 0:
		velocity += nose * throttle * acceleration * delta
	elif throttle < 0 and speed > minSpeed:
		velocity += nose * throttle * (acceleration / 2) * delta
	elif speed > minSpeed:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity += nose * (acceleration / 2) * delta

	velocity = velocity.limit_length(SPEED)

	var forward_speed = velocity.dot(nose)
	var speed_factor = clampf(absf(forward_speed) / SPEED, 0.0, 1.0)
	rotation += steer * steerSpeed * speed_factor * signf(forward_speed) * delta

	nose = Vector2.from_angle(rotation)
	forward_speed = velocity.dot(nose)
	velocity = velocity.lerp(nose * forward_speed, currentGrip * delta)
	
func _take_damage(amount: int, type: int) -> void:
	if type == 2:
		amount = amount/1.5
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
