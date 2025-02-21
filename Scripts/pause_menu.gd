extends CanvasLayer
@onready var show_timer: CheckButton = $Pause_menu/Show_timer

#to determine the tip focused on calling the tip menu. Tip 1 per default
var last_grabbed_orb : int = 0

@onready var tip_panels = [
	$Tip_menu/HBoxContainer/Panel1,
	$Tip_menu/HBoxContainer/Panel2,
	$Tip_menu/HBoxContainer/Panel3,
	$Tip_menu/HBoxContainer/Panel4,
	$Tip_menu/HBoxContainer/Panel5,
	$Tip_menu/HBoxContainer/Panel6,
	$Tip_menu/HBoxContainer/Panel7,
	$Tip_menu/HBoxContainer/Panel8,
	$Tip_menu/HBoxContainer/Panel9,
	$Tip_menu/HBoxContainer/Panel10,
	$Tip_menu/HBoxContainer/Panel11,
	$Tip_menu/HBoxContainer/Panel12,
	$Tip_menu/HBoxContainer/PanelEmpty
]
@onready var tip_buttons = [
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer1/Tip_button1,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer2/Tip_button2,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer3/Tip_button3,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer4/Tip_button4,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer5/Tip_button5,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer6/Tip_button6,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer7/Tip_button7,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer8/Tip_button8,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer9/Tip_button9,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer10/Tip_button10,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer11/Tip_button11,
	$Tip_menu/HBoxContainer/Tip_grid/MarginContainer12/Tip_button12
]

var is_in_death_anim: bool = false
var paused: bool = false
@onready var player: CharacterBody2D = $"../Player"

@onready var select_sfx: AudioStreamPlayer = $select_sfx
@onready var return_sfx: AudioStreamPlayer = $return_sfx
@onready var confirm_sfx: AudioStreamPlayer = $confirm_sfx


func _ready() -> void:
	
	for tip_button in tip_buttons:
		tip_button.disabled = true
	for index in range(len(tip_buttons)):
		if PlayerStats.temporary_orb_list[index]:
			tip_buttons[index].disabled = false
	
	
	show_timer.toggled.connect(func(on):
		get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").visible = on)


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
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		#hides all tools when the preview was held down while entering menu
		player.on_cancel_state()
	else:
		if not player.controllable:
			is_in_death_anim = true
		else:
			is_in_death_anim = false
			player.controllable = false
		Engine.time_scale = 0
		
		if $"../Misc_canvas/new_tip_text".visible:
			$Pause_menu.hide()
			$Tip_menu.show()
			tip_buttons[last_grabbed_orb].grab_focus()
		else:
			$Pause_menu/Resume_button.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		show()

	paused = not paused


func _on_resume_button_pressed() -> void:
	toggle_pause_menu()


func _on_restart_button_pressed() -> void:
	toggle_pause_menu()
	PlayerStats.xPosition = -8299
	PlayerStats.yPosition = 2118
	PlayerStats.orb_count = 0
	PlayerStats.tool_count = 0
	PlayerStats.death_count = 0
	PlayerStats.floor_tool_unlocked = false
	PlayerStats.block_tool_unlocked = false
	PlayerStats.wall_tool_unlocked = false
	PlayerStats.rope_tool_unlocked = false
	PlayerStats.spring_tool_unlocked = false
	PlayerStats.field_tool_unlocked = false
	PlayerStats.temporary_orb_list = [false, false, false, false, false, false, false, false, false, false, false, false]
	get_node("/root/Scene_loader").fade_to_scene("Testlevel")

func _on_tip_menu_button_pressed() -> void:
	$Pause_menu.hide()
	$Tip_menu.show()
	tip_buttons[0].grab_focus()

func _on_respawn_button_pressed() -> void:
	toggle_pause_menu()
	player._on_hurtbox_body_entered(player)


func _on_return_button_pressed() -> void:
	$Tip_menu.hide()
	$Pause_menu.show()
	$Pause_menu/Tip_menu_button.grab_focus()
	
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


func _on_dialog_trigger_body_entered(_body: Node2D) -> void:
	await DialogManager.dialog_finished
	Engine.time_scale = 0
	show()
	$Pause_menu.visible = false
	$Sprint_question.visible = true
	$Sprint_question/MarginContainer/VBoxContainer/HBoxContainer/Hold_sprint.grab_focus()


func _on_dialog_trigger_bullettime_body_entered(_body: Node2D) -> void:
	await DialogManager.dialog_finished
	$Pause_menu/HBoxContainer/Bullet_time_slider.value = 80


func _on_toggle_sprint_pressed() -> void:
	if not $Pause_menu/Sprint_toggle.button_pressed:
		$Pause_menu/Sprint_toggle.button_pressed = true
		$Pause_menu/Sprint_toggle.emit_signal("pressed")
	$Pause_menu.visible = true
	$Sprint_question.visible = false
	hide()
	Engine.time_scale = 1
	DialogManager.run_dialog("chose_toggle")
	await DialogManager.dialog_finished
	player.controllable = true


func _on_hold_sprint_pressed() -> void:
	if $Pause_menu/Sprint_toggle.button_pressed:
		$Pause_menu/Sprint_toggle.button_pressed = false
		$Pause_menu/Sprint_toggle.emit_signal("pressed")
	$Pause_menu.visible = true
	$Sprint_question.visible = false
	hide()
	Engine.time_scale = 1
	DialogManager.run_dialog("chose_hold")
	await DialogManager.dialog_finished
	player.controllable = true

	
func _on_back_to_menu_button_pressed() -> void:
	PlayerStats.beat_game_on_last_save = false
	PlayerStats.save_progress()
	Engine.time_scale = 1
	get_node("/root/Scene_loader").fade_to_scene("Main_menu")



func _on_tip_button_focus_entered(extra_arg_0: int) -> void:
	var current_button: Button = tip_buttons[extra_arg_0]
	
	if extra_arg_0 < 12:
		tip_buttons[extra_arg_0].get_node("new_icon").visible = false
	#sets the Empty Panel as Panel that shows
	if current_button.disabled == true:
		extra_arg_0 = 12
	
	for panel_index in range(len(tip_panels)):
		if panel_index == extra_arg_0:
			tip_panels[panel_index].visible = true
		else:
			tip_panels[panel_index].visible = false


func _on_select_sfx() -> void:
	select_sfx.play()


func _on_confirm_sfx() -> void:
	confirm_sfx.play()


func _on_return_sfx() -> void:
	return_sfx.play()
