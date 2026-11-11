class_name Player
extends CharacterBody2D

@export var use_debug_unlocks := false
@export_flags("Car", "Helicopter", "Tank", "Jet") var debug_unlocked_vehicles := 0
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
@onready var Pause: Control = $"../CanvasLayer/Pause"

var target_angle = rotation

@export var isRobot = true
@onready var UI = $"../CanvasLayer/UI"

var primaryWeapon : Weapon
var secondaryWeapon : Weapon
var firePrimary = false
var fireSecondary = false

var primaryCooldown
var secondaryCooldown

@export var limitUsage = true


func _ready() -> void:
	GameManager.player = self
	_apply_debug_unlocks()
	maxHealth = GameManager.maxPlayerHealth
	if currentHealth < 0:
		currentHealth = GameManager.currentPlayerHealth
	target_angle = rotation
	last_aim_angle = rotation
	_equip_loadout(GameManager.selected_vehicle)
	UI._decrease_health(GameManager.currentPlayerHealth)

#checks current input method
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		using_controller = false
	if event is InputEventJoypadMotion and abs(event.axis_value) > 0.3:
		using_controller = true
	if event is InputEventJoypadButton:
		using_controller = true

func _physics_process(delta: float) -> void:
	#movement
	var last_pos := Vector2.ZERO
	var direction := Vector2(
	Input.get_axis("Left", "Right"),
	Input.get_axis("Up", "Down")
	).limit_length(1.0)
	_move(direction, delta)
	if not GameManager.wheel_open:
		#Rotation
		_aim(direction, delta)
		#Shooting
		if Input.is_action_pressed("Shoot Primary"):
			if limitUsage and fireSecondary:
				return
			firePrimary = true
			_shoot_primary()
		if Input.is_action_just_released("Shoot Primary"):
			firePrimary = false
			
		if Input.is_action_pressed("Shoot Secondary"):
			if limitUsage and firePrimary:
				return
			fireSecondary = true
			_shoot_secondary()
		if Input.is_action_just_released("Shoot Secondary"):
			fireSecondary = false
	
	
	if Input.is_action_just_pressed("Car"):
		if !GameManager.selected_vehicle == 0:
			GameManager._select_vehicle(0)
			_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Helicopter"):
		if GameManager.unlocked_vehicles.has(1):
			if !GameManager.selected_vehicle == 1:
				GameManager._select_vehicle(1)
				_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Tank"):
		if GameManager.unlocked_vehicles.has(2):
			if !GameManager.selected_vehicle == 2:
				GameManager._select_vehicle(2)
				_equip_loadout(GameManager.selected_vehicle)
	elif Input.is_action_just_pressed("Jet"):
		if GameManager.unlocked_vehicles.has(3):
			if !GameManager.selected_vehicle == 3:
				GameManager._select_vehicle(3)
				_equip_loadout(GameManager.selected_vehicle)
	
	if Input.is_action_just_pressed("Transform"):
		_transform()
		pass
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		Pause.modulate.a = 0.0
		Pause.visible = true
		Pause._get_button()
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(Pause, "modulate:a", 1.0, 0.25)
		
	
	move_and_slide()
	
	
func _move(direction: Vector2, delta: float) -> void:
	if direction.length() > 0.3:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
func _aim(direction: Vector2, delta: float) -> void:
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
			$RotationTimer.stop()
		elif !$RotationTimer.time_left:
			$RotationTimer.start()
		if useleftrotation and !using_controller_right:
			if direction.length() >0.3:
				target_angle = direction.angle()
			rotation = lerp_angle(rotation, target_angle, LTURN_SPEED * delta)
		else:
			rotation = lerp_angle(rotation, target_angle, TURN_SPEED * delta)
	else:
		look_at(get_global_mouse_position())
		
	
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
func _take_damage(amount: int, type: int) -> void:
	currentHealth -= amount
	GameManager.currentPlayerHealth = currentHealth
	print(currentHealth)
	UI._decrease_health(currentHealth)
	if currentHealth <= 0:
		_die()

func _die():
	print("death is upon us")
	GameManager._end_game()
	GameManager._reset()
	get_tree().call_deferred("change_scene_to_file", 'res://UI/Screens/Lose/Game_Over.tscn')

func _equip_loadout(index: int) -> void:
	if has_node("Loadouts"):
		var loadouts = $Loadouts.get_children()
		if index <= loadouts.size():
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
		_swap_to(GameManager.VEHICLE_SCENES[GameManager.selected_vehicle])
	else:
		_swap_to(GameManager.ROBOT_SCENE)

func _swap_to(path: String) -> void:
	var newForm: Player = load(path).instantiate()
	newForm.position = position
	newForm.rotation = rotation
	newForm.currentHealth = GameManager.currentPlayerHealth
	newForm.using_controller = using_controller
	
	set_physics_process(false)
	hide()
	$Area2D.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)

	get_parent().add_child(newForm)
	queue_free()
	
func _restore_health(amount: int):
	if currentHealth < maxHealth:
		currentHealth = min(currentHealth + amount, maxHealth)
		GameManager.currentPlayerHealth = currentHealth
		UI._decrease_health(GameManager.currentPlayerHealth)

func _increase_max_health(amount: int):
	maxHealth += amount
	currentHealth += amount
	GameManager.maxPlayerHealth = maxHealth
	GameManager.currentPlayerHealth = currentHealth
	UI._decrease_health(GameManager.currentPlayerHealth)
		
func _apply_debug_unlocks() -> void:
	# Skip if it's turned off, already applied this run, or this is an
	# exported build (OS.is_debug_build() is only true when running
	# from the editor, so players can never trigger this).
	if not use_debug_unlocks or GameManager.debug_unlocks_applied or not OS.is_debug_build():
		return
	GameManager.debug_unlocks_applied = true

	# Replace the unlocked list with exactly what's checked.
	GameManager.unlocked_vehicles.clear()
	for i in GameManager.VEHICLE_SCENES.size():
		# 1 << i = the bit for vehicle i (1, 2, 4, 8...).
		# & checks whether that bit is set, i.e. whether that box is checked.
		if debug_unlocked_vehicles & (1 << i):
			GameManager.unlocked_vehicles.append(i)

	# If the selected vehicle isn't unlocked, select the first one that is.
	if not GameManager.selected_vehicle in GameManager.unlocked_vehicles \
			and not GameManager.unlocked_vehicles.is_empty():
		GameManager.selected_vehicle = GameManager.unlocked_vehicles[0]
