extends Control

@export var slow_time_scale := 0.1
@export var stop_time := false
@export var fade_time := 0.12
@export var mouse_deadzone := 40.0
@export var wheel_scale := 0.55


@onready var slots: Array = $Center.get_children()

var is_open := false
var hovered := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	for slot in slots:
		slot.pivot_offset = slot.size / 2
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Vehicle Wheel") and not get_tree().paused:
		_open()
	elif Input.is_action_just_released("Vehicle Wheel") and is_open:
		_close()
	if is_open:
		_update_hover()

func _open() -> void:
	is_open = true
	GameManager.wheel_open = true
	hovered = GameManager.selected_vehicle
	_refresh_slots()

	# The screen's size in game pixels (640 x 360 now).
	var screen_size := get_viewport_rect().size

	# The root must cover the whole screen at normal size. Scaling it
	# would shrink everything toward the top-left corner.
	scale = Vector2.ONE
	position = Vector2.ZERO
	size = screen_size

	# Dim covers the whole screen.
	$Dim.position = Vector2.ZERO
	$Dim.size = screen_size

	# Center sits in the middle of the screen, and ONLY it is scaled, so the
	# slots shrink toward the middle. The root is at (0, 0) with normal scale,
	# so a position inside it is the same as a position on screen.
	$Center.position = screen_size / 2
	$Center.scale = Vector2(wheel_scale, wheel_scale)

	if not _using_controller():
		get_viewport().warp_mouse(screen_size / 2)

	if stop_time:
		get_tree().paused = true
	else:
		Engine.time_scale = slow_time_scale

	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	
func _close() -> void:
	is_open = false
	GameManager.wheel_open = false
	visible = false
	
	Engine.time_scale = 1.0
	if stop_time:
		get_tree().paused = false
		
	if hovered in GameManager.unlocked_vehicles and hovered != GameManager.selected_vehicle:
		GameManager._select_vehicle(hovered)
		if is_instance_valid(GameManager.player):
			GameManager.player._equip_loadout(GameManager.selected_vehicle)
	
func _refresh_slots() -> void:
	for i in slots.size():
		var unlocked: bool = i in GameManager.unlocked_vehicles
		if not unlocked:
			slots[i].modulate = Color(1,1,1,0.3)
			slots[i].scale = Vector2.ONE
		elif i == hovered:
			slots[i].modulate = Color(1.4,1.4,1.4,1)
			slots[i].scale = Vector2(1.15,1.15)
		else:
			slots[i].modulate = Color(1,1,1,1)
			slots[i].scale = Vector2.ONE
	
func _exit_tree() -> void:
	Engine.time_scale = 1.0
	GameManager.wheel_open = false

func _update_hover() -> void:
	var dir := Input.get_vector("Look Left","Look Right","Look Up","Look Down")
	
	if dir.length() < 0.5:
		if _using_controller():
			return
		var mouse_offset: Vector2 = get_viewport().get_mouse_position() - get_viewport_rect().size / 2
		if mouse_offset.length() > mouse_deadzone:
			dir = mouse_offset
		else:
			return
			
	var angle := dir.angle() + PI / 2
	
	var index := posmod(roundi(angle / (TAU / slots.size())), slots.size())
	
	if index != hovered:
		hovered = index
		_refresh_slots()
		
func _using_controller() -> bool:
	if not is_instance_valid(GameManager.player):
		return false
	return GameManager.player.using_controller
