class_name Player
extends CharacterBody2D

@export var SPEED : float = 425.0
var using_controller := true
var using_controller_right := false
var useleftrotation = true
var last_aim_angle : float = 0.0
@export var TURN_SPEED := 12.0
@export var LTURN_SPEED := 20.0
@export var maxHealth = 100
var currentHealth = -1
var damageTaken

var target_angle = rotation

@export var isRobot = true

var primaryWeapon : Weapon
var secondaryWeapon : Weapon


func _ready() -> void:
	GameManager.player = self
	if currentHealth < 0:
		currentHealth = maxHealth
	_equip_loadout(GameManager.selected_vehicle)
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
	_move(direction, delta)
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
		
	if Input.is_action_pressed("Shoot Secondary"):
		_shoot_secondary()
	
	if Input.is_action_just_pressed("Car"):
		if GameManager.selected_vehicle == 0:
			return
		GameManager.select_vehicle(0)
		_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Helicopter"):
		if !GameManager.unlocked_vehicles.has(1):
			return
		if GameManager.selected_vehicle == 1:
			return
		GameManager.select_vehicle(1)
		_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Tank"):
		if !GameManager.unlocked_vehicles.has(2):
			return
		if GameManager.selected_vehicle == 2:
			return
		GameManager.select_vehicle(2)
		_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Jet"):
		if !GameManager.unlocked_vehicles.has(3):
			return
		if GameManager.selected_vehicle == 3:
			return
		GameManager.select_vehicle(3)
		_equip_loadout(GameManager.selected_vehicle)
	
	if Input.is_action_just_pressed("Transform"):
		_transform()
		pass
	
	move_and_slide()
	
	
func _move(direction: Vector2, delta: float) -> void:
	if direction.length() > 0.3:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	
#Read the name
func _shoot_primary():
	primaryWeapon._try_fire(Input.is_action_just_pressed("Shoot Primary"))
	
#Read the name 2 Electric Boogaloo and Knuckles HD Deluxe with new Funky mode Featuring Dante from the Devil May Cry Series Definitive Edition HD Remix 2.8 Final Chapter Prologue Director's Cut: Game of the Year Edition Turbo HD Remix
func _shoot_secondary():
	secondaryWeapon._try_fire(Input.is_action_just_pressed("Shoot Secondary"))
	
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

func _equip_loadout(index: int) -> void:
	if !has_node("Loadouts"):
		return
	var loadouts = $Loadouts.get_children()
	
	if index >= loadouts.size():
		return
	for i in loadouts.size():
		var active: bool = (i == index)
		if active:
			loadouts[i].visible = true
			loadouts[i].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			loadouts[i].visible = false
			loadouts[i].process_mode = Node.PROCESS_MODE_DISABLED
	var current = loadouts[index]
	primaryWeapon = current.get_node_or_null("Primary")
	secondaryWeapon = current.get_node_or_null("Secondary")
	
	
	
func _transform() -> void:
	if isRobot:
		if GameManager.unlocked_vehicles.is_empty():
			return
		_swap_to(GameManager.Vehicle_Scenes[GameManager.selected_vehicle])
	else:
		_swap_to(GameManager.ROBOT_SCENE)

func _swap_to(path: String) -> void:
	var newForm: Player = load(path).instantiate()
	newForm.global_position = global_position
	newForm.rotaion = rotation
	newForm.currentHealth = currentHealth
	newForm.using_controller = using_controller
	
	set_physics_process(false)
	hide()
	$Area2D.set_deferred("monitorable", false)
	
	get_parent().add_child(newForm)
	queue_free()
		
