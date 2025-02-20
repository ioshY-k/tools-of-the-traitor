extends CanvasLayer

@onready var orb_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Orb_label
@onready var deaths_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Deaths_label
@onready var score_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/Score_label
@onready var time_label: Label = $VBoxContainer/HBoxContainer2/Time_label
@onready var placed_tools_label: Label = $VBoxContainer/HBoxContainer2/Placed_tools_label
@onready var continue_button: Button = $VBoxContainer/HBoxContainer/Continue_button
@onready var retry_button: Button = $VBoxContainer/HBoxContainer/Retry_button
@onready var quit_button: Button = $VBoxContainer/HBoxContainer/Quit_button
@onready var player: CharacterBody2D = $"../Player"
@onready var cursed_orb: CharacterBody2D = $"../Cursed_Orb"

var score: int = 0

@onready var select_sfx: AudioStreamPlayer = $select_sfx
@onready var confirm_sfx: AudioStreamPlayer = $confirm_sfx



func _on_visibility_changed() -> void:
	player.controllable = !player.controllable
	player.velocity = Vector2.ZERO
	if visible:
		get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").stop_timer()
		if PlayerStats.cursed_mode:
			cursed_orb.speed = 0
		score = 0
		orb_label.text = "0 Orbs"
		deaths_label.text = "0 Deaths"
		score_label.text = "0"
		await get_tree().create_timer(1.5).timeout
		for i in range(PlayerStats.orb_count):
			score += 20
			orb_label.text = str(i+1) + " Orbs"
			score_label.text = str(score)
			await get_tree().create_timer(0.2).timeout
		await get_tree().create_timer(1).timeout
		for i in range(PlayerStats.death_count):
			deaths_label.text = str(i+1) + " Deaths"
			if score != 0:
				score -= 1
				score_label.text = str(score)
			await get_tree().create_timer(0.04).timeout
		await get_tree().create_timer(1).timeout
		time_label.text = "Time: " + get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").get_time_formatted()
		placed_tools_label.text = "Placed Tools: " + str(PlayerStats.tool_count)
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		continue_button.grab_focus()
	


func _on_continue_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) 
	hide()
	if is_instance_valid(cursed_orb): 
		cursed_orb.speed = 350
	get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").continue_timer()


func _on_retry_button_pressed() -> void:
	submit_and_finish_run()
	PlayerStats.floor_tool_unlocked = false
	PlayerStats.block_tool_unlocked = false
	PlayerStats.wall_tool_unlocked = false
	PlayerStats.rope_tool_unlocked = false
	PlayerStats.spring_tool_unlocked = false
	PlayerStats.field_tool_unlocked = false
	get_node("/root/Scene_loader").fade_to_scene("Testlevel")

func _on_quit_button_pressed() -> void:
	submit_and_finish_run()
	PlayerStats.save_progress()
	get_node("/root/Scene_loader").fade_to_scene("Main_menu")

func submit_and_finish_run():
	Highscores.add_highscore(score, get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").get_time_formatted(), PlayerStats.tool_count, PlayerStats.cursed_mode)
	if score >= 200:
		Achievements.save_new_achievement(2)
	if PlayerStats.cursed_mode and score >= 100:
		Achievements.save_new_achievement(5)
	
	var hs_file := "user://highscores.dat"
	var file_w = FileAccess.open(hs_file, FileAccess.WRITE)
	for hs in Highscores.highscore_list:
		file_w.store_line(str(hs.score))
		file_w.store_line(hs.time)
		file_w.store_line(str(hs.tools))
		file_w.store_line(str(hs.cursed))
	file_w.close()
	
	PlayerStats.xPosition = -8299
	PlayerStats.yPosition = 2118
	PlayerStats.orb_count = 0
	PlayerStats.tool_count = 0
	PlayerStats.death_count = 0
	PlayerStats.temporary_orb_list = [false, false, false, false, false, false, false, false, false, false, false, false]
	PlayerStats.beat_game_on_last_save = true


func _on_goal_body_entered(_body: Node2D) -> void:
	Achievements.save_new_achievement(0)
	show()
	determine_other_achievements()


func _on_goal_2_body_entered(_body: Node2D) -> void:
	Achievements.save_new_achievement(1)
	if PlayerStats.tool_count <= 30:
		Achievements.save_new_achievement(9)
	if get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").minutes < 3:
		Achievements.save_new_achievement(7)
	show()
	determine_other_achievements()

func determine_other_achievements():
	if PlayerStats.cursed_mode:
		Achievements.save_new_achievement(4)
	if get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").minutes < 2:
		Achievements.save_new_achievement(6)
	if PlayerStats.tool_count <= 25:
		Achievements.save_new_achievement(8)


func _on_select_sfx() -> void:
	select_sfx.play()


func _on_confirm_sfx() -> void:
	confirm_sfx.play()
