extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Test Level.tscn")
	


func _on_quit_pressed() -> void:
	get_tree().quit()

func _get_button():
	$VBoxContainer2/Start.grab_focus() 

func _on_settings_button_down() -> void:
	$VBoxContainer/Volume_Slider.grab_focus() 
	$VBoxContainer2.visible = false
	$VBoxContainer.visible = true
	
func _on_button_pressed() -> void:
	$VBoxContainer2.visible = true
	$VBoxContainer.visible = false
	_get_button()
