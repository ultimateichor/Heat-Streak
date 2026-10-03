extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	await $CanvasLayer/ColorRect._fadeOut()
	get_tree().change_scene_to_file("res://UI/Screens/MainMenu/Main Menu.tscn")
