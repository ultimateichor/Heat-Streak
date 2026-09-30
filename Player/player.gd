extends CharacterBody2D

const SPEED : float = 425.0
var using_controller := true
var using_controller_right := false
var useleftrotation = true
var last_aim_angle : float = 0.0
const TURN_SPEED := 12.0
const LTURN_SPEED := 20.0

var target_angle = rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		using_controller = false
	if event is InputEventJoypadMotion:
		using_controller = true
	if event is InputEventJoypadButton:
		using_controller = true

func _physics_process(delta: float) -> void:
	var direction := Vector2(
	Input.get_axis("Left", "Right"),
	Input.get_axis("Up", "Down")
).limit_length(1.0)
	if direction.length() > 0.3:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	var aim := Input.get_vector("Look Left", "Look Right", "Look Up", "Look Down")
	print(direction)
	if aim.length() > 0.3:
		using_controller_right = true
		useleftrotation = false
		last_aim_angle = aim.angle()
	else:
		using_controller_right = false

	if using_controller:
		if using_controller_right:
			#rotation = last_aim_angle
			target_angle = last_aim_angle
			rotation = lerp_angle(rotation, target_angle, TURN_SPEED * delta)
		elif !$RotationTimer.time_left:
			$RotationTimer.start()
		if useleftrotation and !using_controller_right:
			if direction.length() >0.3:
				target_angle = direction.angle()
			rotation = lerp_angle(rotation, target_angle, LTURN_SPEED * delta)
	else:
		look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("Shoot Primary"):
		_shoot_primary()
	
	move_and_slide()
	
func _shoot_primary():
	print("bullet")

func _on_rotation_timer_timeout() -> void:
	useleftrotation = true
