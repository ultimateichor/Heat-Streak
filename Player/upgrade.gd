extends Node2D

@export_enum("Health", "Damage", "Range", "Fire Rate") var upgradeOptions = 0
@export_enum("Base", "Car", "Helicopter", "Tank", "Jet") var form := 0
@export_enum("Primary", "Secondary") var weapon = 0

@export var healthAmount = 20
@export var damageAmount = 1
@export var rangeAmount = 0.03
@export var fireRateAmount = 0.03
@export var bulletSpeedAmount = 10
@export var isAutomatic = true     
@export var sizeAmount = 1

const LOADOUT_NAMES := ["", "CarLoadout", "HeliLoadout", "TankLoadout", "JetLoadout"]
const WEAPON_NAMES := ["Primary", "Secondary"]


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Player"):
		return
	var player = area.get_parent()

	if upgradeOptions == 0:
		player._increase_max_health(healthAmount)
		queue_free()
		return

	var loadout_name: String = LOADOUT_NAMES[form]
	if loadout_name == "":
		push_warning("Weapon upgrade has no loadout chosen; set its Form in the Inspector.")
		return

	var weapon_id: String = loadout_name + "/" + WEAPON_NAMES[weapon]

	match upgradeOptions:
		1:
			GameManager.add_weapon_upgrade(weapon_id, "damage", damageAmount)
		2:
			GameManager.add_weapon_upgrade(weapon_id, "range", rangeAmount)
		3:
			GameManager.add_weapon_upgrade(weapon_id, "fire_rate", -fireRateAmount)

	var active_weapon = player.get_node_or_null("Loadouts/" + weapon_id)
	if active_weapon:
		active_weapon.apply_upgrades()

	queue_free()
