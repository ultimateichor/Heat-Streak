extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node = $TextureRect/Sprite2D2
	# Repeat until there are no more parents (get_parent() returns null at the top).
	while node:
		# Only nodes with a rotation (Node2D and Control) are printed.
		if node is Node2D or node is Control:
			# Rotation is in radians. Anything not exactly 0 is the problem.
			print(node.name, " rotation: ", node.rotation)
		node = node.get_parent()
	$VBoxContainer/Retry.grab_focus() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	await $CanvasLayer/ColorRect._fadeOut()
	get_tree().change_scene_to_file("res://UI/Screens/MainMenu/Main Menu.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/test_room_1.tscn")
