extends CanvasLayer

@onready var orb_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Orb_label
@onready var deaths_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Deaths_label
@onready var score_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer2/Score_label
@onready var time_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer3/Time_label
@onready var timer: Panel = get_node("/root/Testlevel/Misc_canvas/Timer")
@onready var continue_button: Button = $VBoxContainer/HBoxContainer/Continue_button
@onready var retry_button: Button = $VBoxContainer/HBoxContainer/Retry_button
@onready var quit_button: Button = $VBoxContainer/HBoxContainer/Quit_button
@onready var player: CharacterBody2D = $"../Player"

func _on_goal_body_entered(_body: Node2D) -> void:
	show()


func _on_visibility_changed() -> void:
	
	player.controllable = !player.controllable
	player.velocity = Vector2.ZERO
	var score: int = 0
	orb_label.text = "0 Orbs"
	deaths_label.text = "0 Deaths"
	score_label.text = "0"
	time_label.text = timer.get_time_formatted()
	timer.stop_timer()
	await get_tree().create_timer(1.5).timeout
	for i in range(PlayerStats.orb_count):
		score += 20
		orb_label.text = str(i+1) + " Orbs"
		score_label.text = str(score)
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(1).timeout
	for i in range(PlayerStats.death_count):
		score -= 1
		deaths_label.text = str(i+1) + " Deaths"
		score_label.text = str(score)
		if score == 0:
			break
		await get_tree().create_timer(0.04).timeout
	
	continue_button.grab_focus()
	


func _on_continue_button_pressed() -> void:
	hide()
	timer.continue_timer()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
