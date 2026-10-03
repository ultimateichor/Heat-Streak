extends Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	if not is_visible_in_tree():
		return
		
	var focused_node: Control = get_viewport().gui_get_focus_owner()
	
	if focused_node is HSlider:
		var slider := focused_node as HSlider
		var axis: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		if axis != 0.0:
			var dynamic_range: float = slider.max_value - slider.min_value
			var target_fill_time: float = 2.0
			var speed: float = dynamic_range / target_fill_time
			var engine_delta: float = get_process_delta_time()
			slider.value += axis * speed * engine_delta

func _get_button():
	$VBoxContainer2/Start.grab_focus() 

func _on_menu_pressed() -> void:
	GameManager._end_game()
	get_tree().paused = !get_tree().paused
	#await %ColorRect._fadeOut()
	get_tree().change_scene_to_file("res://UI/Screens/MainMenu/Main Menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	get_tree().paused = !get_tree().paused
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true) 
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	await tween.finished
	tween.kill()
	visible = false


func _on_volume_pressed() -> void:
	$VBoxContainer/Volume_Slider.grab_focus() 
	$VBoxContainer2.visible = false
	$VBoxContainer.visible = true
	


func _on_button_pressed() -> void:
	$VBoxContainer2.visible = true
	$VBoxContainer.visible = false
	_get_button()
