extends CanvasLayer

@onready var tip_panels = [$Panel1,$Panel2,$Panel3,$Panel4,$Panel5,$Panel6,$Panel7,$Panel8,$Panel9,$Panel10,$Panel11,$Panel12]
@onready var tip_buttons = [
	$Tip_menu/Tip_grid/MarginContainer/Tip_button1,
	$Tip_menu/Tip_grid/MarginContainer2/Tip_button2,
	$Tip_menu/Tip_grid/MarginContainer3/Tip_button3,
	$Tip_menu/Tip_grid/MarginContainer4/Tip_button4,
	$Tip_menu/Tip_grid/MarginContainer5/Tip_button5,
	$Tip_menu/Tip_grid/MarginContainer6/Tip_button6,
	$Tip_menu/Tip_grid/MarginContainer7/Tip_button7,
	$Tip_menu/Tip_grid/MarginContainer8/Tip_button8,
	$Tip_menu/Tip_grid/MarginContainer9/Tip_button9,
	$Tip_menu/Tip_grid/MarginContainer10/Tip_button10,
	$Tip_menu/Tip_grid/MarginContainer11/Tip_button11,
	$Tip_menu/Tip_grid/MarginContainer12/Tip_button12,
]

var is_in_death_anim: bool = false
var paused: bool = false
@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	for tip_button in tip_buttons:
		tip_button.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not $"../Result_canvas".visible:
				toggle_pause_menu()
	
func toggle_pause_menu():
	if paused:
		if not is_in_death_anim:
			player.controllable = true
		Engine.time_scale = 1
		$Pause_menu.show()
		$Tip_menu.hide()
		$Close_tip_button.hide()
		for panel in tip_panels:
			if panel.visible:
				panel.hide()
		hide()
	else:
		if not player.controllable:
			is_in_death_anim = true
		else:
			is_in_death_anim = false
			player.controllable = false
		Engine.time_scale = 0
		show()
		$Pause_menu/Resume_button.grab_focus()
	paused = not paused


func _on_resume_button_pressed() -> void:
	toggle_pause_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	toggle_pause_menu()
	get_tree().reload_current_scene()

func _on_tip_menu_button_pressed() -> void:
	$Pause_menu.hide()
	$Tip_menu.show()
	$Tip_menu/Tip_grid/MarginContainer/Tip_button1.grab_focus()

func _on_respawn_button_pressed() -> void:
	toggle_pause_menu()
	player._on_hurtbox_body_entered(player)


func _on_return_button_pressed() -> void:
	$Tip_menu.hide()
	$Pause_menu.show()
	$Pause_menu/Resume_button.grab_focus()



func _on_tip_button_1_pressed() -> void:
	$Panel1.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_2_pressed() -> void:
	$Panel2.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_3_pressed() -> void:
	$Panel3.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_4_pressed() -> void:
	$Panel4.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_5_pressed() -> void:
	$Panel5.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_6_pressed() -> void:
	$Panel6.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_7_pressed() -> void:
	$Panel7.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_8_pressed() -> void:
	$Panel8.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_9_pressed() -> void:
	$Panel9.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	

func _on_tip_button_10_pressed() -> void:
	$Panel10.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_11_pressed() -> void:
	$Panel11.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()


func _on_tip_button_12_pressed() -> void:
	$Panel12.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	
func _on_close_tip_button_pressed() -> void:
	for panel in tip_panels:
		if panel.visible:
			panel.hide()
			tip_buttons[tip_panels.find(panel)].grab_focus()
			$Close_tip_button.hide()


func _on_sprint_toggle_pressed() -> void:
	PlayerStats.toggle_to_sprint = not PlayerStats.toggle_to_sprint
	$"../Misc_canvas/Sprint_status_icon".visible = not $"../Misc_canvas/Sprint_status_icon".visible


func _on_h_slider_value_changed(value: float) -> void:
	PlayerStats.bullet_time_value = (120 - value) / 100


func _on_dialog_trigger_body_entered(body: Node2D) -> void:
	await DialogManager.dialog_finished
	Engine.time_scale = 0
	show()
	$Pause_menu.visible = false
	$Sprint_question.visible = true
	$Sprint_question/MarginContainer/VBoxContainer/HBoxContainer/Hold_sprint.grab_focus()
	


func _on_toggle_sprint_pressed() -> void:
	$Pause_menu/Sprint_toggle.emit_signal("pressed")
	$Pause_menu.visible = true
	$Sprint_question.visible = false
	hide()
	Engine.time_scale = 1
	DialogManager.run_dialog("chose_toggle")
	await DialogManager.dialog_finished
	player.controllable = true


func _on_hold_sprint_pressed() -> void:
	$Pause_menu.visible = true
	$Sprint_question.visible = false
	hide()
	Engine.time_scale = 1
	DialogManager.run_dialog("chose_hold")
	player.controllable = true
