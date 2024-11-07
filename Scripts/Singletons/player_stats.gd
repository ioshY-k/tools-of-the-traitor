extends Node

#Singleton Script
var floor_tool_unlocked: bool = false
var block_tool_unlocked: bool = false
var wall_tool_unlocked: bool = false
var rope_tool_unlocked: bool = false
var spring_tool_unlocked: bool = false
var field_tool_unlocked: bool = false

var toggle_to_sprint: bool = false
var show_timer: bool = false
var bullet_time_value: float = 1.0
var cursed_mode: bool = true
var no_dialog: bool = false
const ORB_NUMBER = 12
var orb_list = []

var death_count = 0
var orb_count = 0
	

func _process(delta: float) -> void:
	print(bullet_time_value)	

func execute_all_options():
	print("playerstats wird ausgeführt")
	orb_list.resize(ORB_NUMBER)
	orb_list.fill(false)
	if not cursed_mode:
		if is_instance_valid(get_node("/root/Testlevel/Cursed_Orb")):
			get_node("/root/Testlevel/Cursed_Orb").queue_free()
	else:
		no_dialog = true
	if no_dialog:
		for triggerbox in get_tree().get_nodes_in_group("Dialog_trigger_group"):
			triggerbox.queue_free()
	if show_timer:
		if is_instance_valid(get_node("/root/Testlevel/Misc_canvas/Timer")):
			get_node("/root/Testlevel/Pause_menu/Pause_menu/Show_timer").button_pressed = true
			get_node("/root/Testlevel/Misc_canvas/Timer").visible = true
	if bullet_time_value != 1.0:
		if is_instance_valid(get_node("/root/Testlevel/Pause_menu/Pause_menu/HBoxContainer/Bullet_time_slider")):
			get_node("/root/Testlevel/Pause_menu/Pause_menu/HBoxContainer/Bullet_time_slider").value = 120 - (bullet_time_value * 100)
	if toggle_to_sprint:
		if is_instance_valid(get_node("/root/Testlevel/Pause_menu/Pause_menu/Sprint_toggle")):
			get_node("/root/Testlevel/Pause_menu/Pause_menu/Sprint_toggle").button_pressed = true
			get_node("/root/Testlevel/Misc_canvas/Sprint_status_icon").visible = true
	
