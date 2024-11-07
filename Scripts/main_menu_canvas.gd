extends CanvasLayer


func _ready() -> void:
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Play.grab_focus()
	$Options_Container/Options_panel/VBoxContainer/Sprint_toggle.button_pressed = PlayerStats.toggle_to_sprint
	$Options_Container/Options_panel/VBoxContainer/Show_timer.button_pressed = PlayerStats.show_timer
	$Options_Container/Options_panel/VBoxContainer/Skip_dialog.button_pressed = PlayerStats.no_dialog
	$Options_Container/Options_panel/VBoxContainer/HBoxContainer/Bullet_time_slider.value = 120 - (PlayerStats.bullet_time_value * 100)

func _on_play_pressed() -> void:
	PlayerStats.cursed_mode = false
	get_tree().change_scene_to_file("res://Scenes/Levels/testlevel.tscn")


func _on_cursed_mode_pressed() -> void:
	PlayerStats.cursed_mode = true
	get_tree().change_scene_to_file("res://Scenes/Levels/testlevel.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	$Options_Container.visible = true
	$Options_Container/Options_panel/VBoxContainer/Sprint_toggle.grab_focus()




func _on_sprint_toggle_toggled(toggled_on: bool) -> void:
	PlayerStats.toggle_to_sprint = toggled_on


func _on_show_timer_toggled(toggled_on: bool) -> void:
	PlayerStats.show_timer = toggled_on


func _on_skip_dialog_toggled(toggled_on: bool) -> void:
	PlayerStats.no_dialog = toggled_on


func _on_bullet_time_slider_value_changed(value: float) -> void:
	PlayerStats.bullet_time_value = (120 - value) / 100
	


func _on_return_pressed() -> void:
	$Options_Container.visible = false
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Play.grab_focus()
	
