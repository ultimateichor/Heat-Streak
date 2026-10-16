extends Player


func _shoot_primary():
	pass
func _shoot_secondary():
	pass
func _take_damage(amount: int, type: int) -> void:
	if type == 2:
		amount = amount/1.5
	currentHealth -= amount
	print(currentHealth)
	UI._decrease_health(currentHealth)
	if currentHealth <= 0:
		_die()
