extends CanvasLayer

@onready var options_animations: Node2D = $"../Options_animations"
@onready var options_animation_player: AnimationPlayer = options_animations.get_node("Options_animation_player")
@onready var highscore_animations: Node2D = $"../Highscore_animations"
@onready var highscore_animation_player: AnimationPlayer = highscore_animations.get_node("Highscore_anim_player")
@onready var playgame_animation_player: AnimationPlayer = $"../Player_rig/Playgame_animation_player"
@onready var player_rig: Node2D = $"../Player_rig"
@onready var cursed_orb: Sprite2D = $"../Cursed_Orb"
@onready var highscore_table: VBoxContainer = $Highscore_Container/Highscore_panel/MarginContainer/Highscore_table
@onready var sort_options: OptionButton = $Highscore_Container/Highscore_panel/MarginContainer2/VBoxContainer/Sort_options
@onready var cursed_mode: CheckButton = $Highscore_Container/Highscore_panel/MarginContainer2/VBoxContainer/Cursed_mode

@onready var tip_panels = [$Panel1,$Panel2,$Panel3,$Panel4,$Panel5,$Panel6,$Panel7,$Panel8,$Panel9,$Panel10,$Panel11,$Panel12]
@onready var tip_buttons = [
	$Tip_menu/Tip_grid/MarginContainer1/Tip_button1,
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

@onready var button_goal: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_goal
@onready var button_goal_2: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_goal2
@onready var button_score: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_score
@onready var button_orbs: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_orbs
@onready var button_cursed: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_cursed
@onready var button_cursed_2: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_cursed2
@onready var button_time: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_time
@onready var button_time_2: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_time2
@onready var button_tools: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_tools
@onready var button_tools_2: Button = $Main_panel/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button_tools2

@onready var panel_achievements: Panel = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements

@onready var label_goal: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_goal
@onready var label_goal_2: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_goal2
@onready var label_score: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_score
@onready var label_orbs: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_orbs
@onready var label_cursed: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_cursed
@onready var label_cursed_2: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_cursed2
@onready var label_time: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_time
@onready var label_time_2: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_time2
@onready var label_tools: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_tools
@onready var label_tools_2: Label = $Main_panel/Panel/MarginContainer/VBoxContainer/Panel_Achievements/PanelContainer/Label_tools2



enum player_keypositions {PLAY, PLAY_CURSED, OFF}
var current_player_pos = player_keypositions.OFF

func _ready() -> void:
	
	var hs_file = "user://highscores.dat"
	
	var hs_file_r = FileAccess.open(hs_file, FileAccess.READ)
	if hs_file_r.get_position() == hs_file_r.get_length():
		get_node("/root/Main_menu/Main_menu_canvas/Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Cursed_mode").disabled = true
	else:
		get_node("/root/Main_menu/Main_menu_canvas/Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Cursed_mode").disabled = false
	hs_file_r.close()
	check_achievements()
	
	var file := "user://unlocked_tips.dat"
	var file_r = FileAccess.open(file, FileAccess.READ)
	
	if file_r.get_length() > 0:
		var counter = 0;
		while file_r.get_position() < file_r.get_length():
			PlayerStats.orb_list[counter] = (file_r.get_line() == "true")
			counter += 1
	file_r.close()
	
	
	for tip_button in tip_buttons:
		tip_button.disabled = true
		
	for index in range(len(PlayerStats.orb_list)):
		if PlayerStats.orb_list[index]:
			
			tip_buttons[index].disabled = false
			tip_buttons[index].get_child(0).visible = true
	
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Play.focus_entered.connect(
		func(): current_player_pos = player_keypositions.PLAY)
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Cursed_mode.focus_entered.connect(
		func(): current_player_pos = player_keypositions.PLAY_CURSED)
	$Main_panel/MarginContainer/VBoxContainer/Highscores.focus_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	$Main_panel/MarginContainer/VBoxContainer/Options.focus_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	$Main_panel/MarginContainer/VBoxContainer/Quit.focus_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Play.mouse_entered.connect(
		func(): current_player_pos = player_keypositions.PLAY)
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Cursed_mode.mouse_entered.connect(
		func(): current_player_pos = player_keypositions.PLAY_CURSED)
	$Main_panel/MarginContainer/VBoxContainer/Highscores.mouse_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	$Main_panel/MarginContainer/VBoxContainer/Options.mouse_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	$Main_panel/MarginContainer/VBoxContainer/Quit.mouse_entered.connect(
		func(): current_player_pos = player_keypositions.OFF)
	$Main_panel/MarginContainer/VBoxContainer/HBoxContainer/Play.grab_focus()
	$Options_Container/Options_panel/VBoxContainer/Sprint_toggle.button_pressed = PlayerStats.toggle_to_sprint
	$Options_Container/Options_panel/VBoxContainer/Show_timer.button_pressed = PlayerStats.show_timer
	$Options_Container/Options_panel/VBoxContainer/Skip_dialog.button_pressed = PlayerStats.no_dialog
	$Options_Container/Options_panel/VBoxContainer/HBoxContainer/Bullet_time_slider.value = 120 - (PlayerStats.bullet_time_value * 100)

func check_achievements():
	print("checking achievements")
	var achievement_buttons = [	button_goal, button_goal_2, 
								button_score, button_orbs,
								button_cursed, button_cursed_2,
								button_time, button_time_2,
								button_tools, button_tools_2]
	for achievement in range(10):
		if Achievements.achievement_list[achievement]:
			achievement_buttons[achievement].modulate = Color(1,1,1)
		else:
			achievement_buttons[achievement].modulate = Color(0.56, 0.56, 0.56, 0.569)

func _process(delta: float) -> void:
	match current_player_pos:
		player_keypositions.OFF:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(2016,2), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(0.8,0.8), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(2358,600), 8 * delta)
		player_keypositions.PLAY:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(2016,2), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(0.8,0.8), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(1415,600), 8 * delta)
		player_keypositions.PLAY_CURSED:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(1662,300), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(2.5,2.5), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(1346,600), 8 * delta)


func _on_play_pressed() -> void:
	PlayerStats.cursed_mode = false
	var savefile = FileAccess.open("user://savedata.json", FileAccess.READ)
	var savedata = savefile.get_as_text()
	savefile.close()
	var savefile_dict: Dictionary = JSON.parse_string(savedata)
	if not savefile_dict["cursed_mode"] and not savefile_dict["beat_game_on_last_save"]:
		$New_or_continue.show()
		$New_or_continue/New.grab_focus()
	else:
		prepare_new_game()


func _on_cursed_mode_pressed() -> void:
	PlayerStats.cursed_mode = true
	var savefile = FileAccess.open("user://savedata.json", FileAccess.READ)
	var savedata = savefile.get_as_text()
	savefile.close()
	var savefile_dict: Dictionary = JSON.parse_string(savedata)
	if savefile_dict["cursed_mode"] and not savefile_dict["beat_game_on_last_save"]:
		$New_or_continue.show()
		$New_or_continue/New.grab_focus()
	else:
		prepare_new_game()


func _on_new_pressed() -> void:
	prepare_new_game()

func prepare_new_game():
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
	PlayerStats.time = 0.0
	
	get_tree().change_scene_to_file("res://Scenes/Levels/testlevel.tscn")


func _on_continue_pressed() -> void:
	var savefile = FileAccess.open("user://savedata.json", FileAccess.READ)
	var savedata = savefile.get_as_text()
	savefile.close()
	var savefile_dict: Dictionary = JSON.parse_string(savedata)
	PlayerStats.xPosition = savefile_dict["xPosition"]
	PlayerStats.yPosition = savefile_dict["yPosition"]
	PlayerStats.orb_count = savefile_dict["orb_count"]
	PlayerStats.tool_count = savefile_dict["tool_count"]
	PlayerStats.death_count = savefile_dict["death_count"]
	PlayerStats.temporary_orb_list = savefile_dict["temporary_orb_list"]
	PlayerStats.floor_tool_unlocked = savefile_dict["floor_tool_unlocked"]
	PlayerStats.block_tool_unlocked = savefile_dict["block_tool_unlocked"]
	PlayerStats.wall_tool_unlocked = savefile_dict["wall_tool_unlocked"]
	PlayerStats.rope_tool_unlocked = savefile_dict["rope_tool_unlocked"]
	PlayerStats.spring_tool_unlocked = savefile_dict["spring_tool_unlocked"]
	PlayerStats.field_tool_unlocked = savefile_dict["field_tool_unlocked"]
	PlayerStats.time = savefile_dict["time"]
	get_tree().change_scene_to_file("res://Scenes/Levels/testlevel.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	$Options_Container.visible = true
	$Options_Container/Options_panel/VBoxContainer/Show_tips.grab_focus()


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
	$Main_panel/MarginContainer/VBoxContainer/Options.grab_focus()


func _on_options_focus_entered() -> void:
	options_animation_player.play("Allies_fly_in")
	options_animation_player.queue("Allies_hover")


func _on_options_focus_exited() -> void:
	options_animation_player.play("Allies_fly_out")


func _on_play_focus_entered() -> void:
	player_rig.get_node("AnimationPlayer").play("Idle_anim", 0.2)


func _on_cursed_mode_focus_entered() -> void:
	player_rig.get_node("AnimationPlayer").play("P_speed_anim", 0.2)


func _on_options_mouse_entered() -> void:
	options_animation_player.play("Allies_fly_in")
	options_animation_player.queue("Allies_hover")


func _on_options_mouse_exited() -> void:
	options_animation_player.play("Allies_fly_out")


func _on_play_mouse_entered() -> void:
	player_rig.get_node("AnimationPlayer").play("Idle_anim", 0.2)


func _on_cursed_mode_mouse_entered() -> void:
	player_rig.get_node("AnimationPlayer").play("P_speed_anim", 0.2)


func _on_show_tips_pressed() -> void:
	$Panel_behind_tips.visible = true
	$Tip_menu.show()
	$Tip_menu/Tip_grid/MarginContainer1/Tip_button1.grab_focus()

func _on_tip_button_1_pressed() -> void:
	$Panel1.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer1/Tip_button1/new_icon.visible = false

func _on_tip_button_2_pressed() -> void:
	$Panel2.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer2/Tip_button2/new_icon.visible = false


func _on_tip_button_3_pressed() -> void:
	$Panel3.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer3/Tip_button3/new_icon.visible = false


func _on_tip_button_4_pressed() -> void:
	$Panel4.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer4/Tip_button4/new_icon.visible = false


func _on_tip_button_5_pressed() -> void:
	$Panel5.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer5/Tip_button5/new_icon.visible = false


func _on_tip_button_6_pressed() -> void:
	$Panel6.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer6/Tip_button6/new_icon.visible = false


func _on_tip_button_7_pressed() -> void:
	$Panel7.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer7/Tip_button7/new_icon.visible = false


func _on_tip_button_8_pressed() -> void:
	$Panel8.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer8/Tip_button8/new_icon.visible = false


func _on_tip_button_9_pressed() -> void:
	$Panel9.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer9/Tip_button9/new_icon.visible = false
	

func _on_tip_button_10_pressed() -> void:
	$Panel10.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer10/Tip_button10/new_icon.visible = false


func _on_tip_button_11_pressed() -> void:
	$Panel11.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer11/Tip_button11/new_icon.visible = false


func _on_tip_button_12_pressed() -> void:
	$Panel12.show()
	$Close_tip_button.show()
	$Close_tip_button.grab_focus()
	$Tip_menu/Tip_grid/MarginContainer12/Tip_button12/new_icon.visible = false
	
func _on_close_tip_button_pressed() -> void:
	for panel in tip_panels:
		if panel.visible:
			panel.hide()
			tip_buttons[tip_panels.find(panel)].grab_focus()
			$Close_tip_button.hide()
	


func _on_return_button_pressed() -> void:
	$Panel_behind_tips.visible = false
	$Tip_menu.hide()
	$Options_Container/Options_panel/VBoxContainer/Show_tips.grab_focus()


func _on_highscores_focus_entered() -> void:
	highscore_animation_player.play("highscore_fly_in")
	highscore_animation_player.queue("highscore_hover")


func _on_highscores_focus_exited() -> void:
	highscore_animation_player.play("highscore_fly_out")


func _on_highscores_mouse_entered() -> void:
	highscore_animation_player.play("highscore_fly_in")
	highscore_animation_player.queue("highscore_hover")


func _on_highscores_mouse_exited() -> void:
	highscore_animation_player.play("highscore_fly_out")


func _on_highscores_pressed() -> void:
	$Highscore_Container.show()
	cursed_mode.button_pressed = false
	sort_options.select(0)
	sort_options.grab_focus()

	sort_and_show()


func _on_return_from_hs_pressed() -> void:
	$Highscore_Container.visible = false
	$Main_panel/MarginContainer/VBoxContainer/Highscores.grab_focus()


func _on_cursed_mode_toggled(toggled_on: bool) -> void:
	cursed_mode.button_pressed = toggled_on
	
	sort_and_show()


func _on_sort_options_item_selected(_index: int) -> void:
	sort_and_show()

func sort_and_show():
	for entry in highscore_table.get_children():
		if entry.name != "Header":
			entry.queue_free()
	
	match sort_options.selected:
		0:
			Highscores.sort_by_score()
		1:
			Highscores.sort_by_time()
		2:
			Highscores.sort_by_tools()
	
	
	var num_entries = 0
	for hs in Highscores.highscore_list:
		if hs.cursed == cursed_mode.button_pressed and num_entries < 10:
			var entry = Highscores.convert_to_tableentry(hs)
			highscore_table.add_child(entry)
			num_entries += 1


func _on_achievementbutton_focus_entered() -> void:
	panel_achievements.show()
	for label in get_tree().get_nodes_in_group("Achievement_label"):
		label.visible = false
	
	if button_goal.has_focus(): label_goal.visible = true
	if button_goal_2.has_focus(): label_goal_2.visible = true
	if button_score.has_focus(): label_score.visible = true
	if button_orbs.has_focus(): label_orbs.visible = true
	if button_cursed.has_focus(): label_cursed.visible = true
	if button_cursed_2.has_focus(): label_cursed_2.visible = true
	if button_time.has_focus(): label_time.visible = true
	if button_time_2.has_focus(): label_time_2.visible = true
	if button_tools.has_focus(): label_tools.visible = true
	if button_tools_2.has_focus(): label_tools_2.visible = true
	
	get_tree().create_tween().tween_property($Main_panel/Panel, "position:y", 532, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	


	


func _on_achievementbutton_focus_exited() -> void:
	panel_achievements.hide()
	for label in get_tree().get_nodes_in_group("Achievement_label"):
		label.visible = false
	await get_tree().create_timer(0.02).timeout
	var still_in_achievement_menu = false
	for button: Button in get_tree().get_nodes_in_group("Achievement_button"):
		if button.has_focus():
			still_in_achievement_menu = true
	if not still_in_achievement_menu:
		get_tree().create_tween().tween_property($Main_panel/Panel, "position:y", 870, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _on_achievementbutton_mouse_entered() -> void:
	panel_achievements.show()
	for label in get_tree().get_nodes_in_group("Achievement_label"):
		label.visible = false
	
	if button_goal.is_hovered(): label_goal.visible = true
	if button_goal_2.is_hovered(): label_goal_2.visible = true
	if button_score.is_hovered(): label_score.visible = true
	if button_orbs.is_hovered(): label_orbs.visible = true
	if button_cursed.is_hovered(): label_cursed.visible = true
	if button_cursed_2.is_hovered(): label_cursed_2.visible = true
	if button_time.is_hovered(): label_time.visible = true
	if button_time_2.is_hovered(): label_time_2.visible = true
	if button_tools.is_hovered(): label_tools.visible = true
	if button_tools_2.is_hovered(): label_tools_2.visible = true


func _on_reset_progress_pressed() -> void:
	$Really_delete.show()
	$Really_delete/No.grab_focus()


func _on_no_pressed() -> void:
	$Really_delete.hide()
	$Options_Container/Options_panel/VBoxContainer/Reset_progress.grab_focus()


func _on_yes_pressed() -> void:
	DirAccess.remove_absolute("user://highscores.dat")
	DirAccess.remove_absolute("user://achievements.dat")
	DirAccess.remove_absolute("user://unlocked_tips.dat")
	DirAccess.remove_absolute("user://savedata.json")
	FileCreator.create_files()
	for achievement in range(10):
		Achievements.achievement_list[achievement] = false
	get_tree().reload_current_scene()
	
