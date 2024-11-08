extends CanvasLayer

@onready var options_animations: Node2D = $"../Options_animations"
@onready var options_animation_player: AnimationPlayer = options_animations.get_node("Options_animation_player")
@onready var highscore_animations: Node2D = $"../Highscore_animations"
@onready var highscore_animation_player: AnimationPlayer = highscore_animations.get_node("Highscore_anim_player")


@onready var playgame_animation_player: AnimationPlayer = $"../Player_rig/Playgame_animation_player"
@onready var player_rig: Node2D = $"../Player_rig"
@onready var cursed_orb: Sprite2D = $"../Cursed_Orb"


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

enum player_keypositions {PLAY, PLAY_CURSED, OFF}
var current_player_pos = player_keypositions.OFF

func _ready() -> void:
	for tip_button in tip_buttons:
		tip_button.disabled = true
		
	for index in range(len(PlayerStats.orb_list)):
		print("turning on")
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


func _process(delta: float) -> void:
	match current_player_pos:
		player_keypositions.OFF:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(2016,42), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(0.8,0.8), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(2358,760), 8 * delta)
		player_keypositions.PLAY:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(2016,42), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(0.8,0.8), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(1415,760), 8 * delta)
		player_keypositions.PLAY_CURSED:
			cursed_orb.position = cursed_orb.position.lerp(Vector2(1662,340), 8 * delta)
			cursed_orb.scale = cursed_orb.scale.lerp(Vector2(2.5,2.5), 8 * delta)
			player_rig.position = player_rig.position.lerp(Vector2(1346,760), 8 * delta)


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
