class_name Player
extends CharacterBody2D

const SPEED : float = 425.0
var using_controller := true
var using_controller_right := false
var useleftrotation = true
var last_aim_angle : float = 0.0
const TURN_SPEED := 12.0
const LTURN_SPEED := 20.0
const maxHealth = 100
var currentHealth
var damageTaken

var target_angle = rotation


func _ready() -> void:
	GameManager.player = self
	currentHealth = maxHealth
	print(currentHealth)

#checks current input method
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		using_controller = false
	if event is InputEventJoypadMotion:
		using_controller = true
	if event is InputEventJoypadButton:
		using_controller = true

func _physics_process(delta: float) -> void:
	#movement
	var direction := Vector2(
	Input.get_axis("Left", "Right"),
	Input.get_axis("Up", "Down")
).limit_length(1.0)
	if direction.length() > 0.3:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	#Rotation
	var aim := Input.get_vector("Look Left", "Look Right", "Look Up", "Look Down")
	#print(direction)
	if aim.length() > 0.3:
		using_controller_right = true
		useleftrotation = false
		last_aim_angle = aim.angle()
	else:
		using_controller_right = false

	if using_controller:
		if using_controller_right:
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
	#Shooting
	if Input.is_action_pressed("Shoot Primary"):
		_shoot_primary()
	
	move_and_slide()
	
#Read the name
func _shoot_primary():
	print("bullet")
	
#Read the name 2 Electric Boogaloo and Knuckles HD Deluxe with new Funky mode Featuring Dante from the Devil May Cry Series Definitive Edition HD Remix 2.8 Final Chapter Prologue Director's Cut: Game of the Year Edition Turbo HD Remix
func _shoot_secondary():
	pass
#Timer for changing rotation back to movement
func _on_rotation_timer_timeout() -> void:
	useleftrotation = true

#Takes the damage from enemies and calls die() if health is <= 0
func _take_damage(amount: int) -> void:
	currentHealth -= amount
	print(currentHealth)
	if currentHealth <= 0:
		_die()

func _die():
	print("death is upon us")
	GameManager._end_game()
	queue_free()
	#get_tree().call_deferred("change_scene_to_file", 'res://UI/Screens/Lose/Game_Over.tscn')

		
