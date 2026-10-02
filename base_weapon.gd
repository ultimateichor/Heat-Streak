class_name Weapon
extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.1       # seconds between shots
@export var damage := 10
@export var bullet_speed := 900.0
@export var automatic := true     

var cooldown := 0.0

@onready var muzzle: Marker2D = $Muzzle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown = max(cooldown - delta, 0.0)

func _try_fire(just_pressed: bool) -> void:
	if cooldown > 0.0:
		return
	if !automatic && !just_pressed:
		return
	cooldown = fire_rate
	_fire()
	
func _fire() -> void:
	_spawn_bullet(global_rotation)
	
func _spawn_bullet(angle: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = angle
	bullet.velocity = Vector2.from_angle(angle) * bullet_speed
	bullet.damage = damage
	
