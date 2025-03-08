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
@export var orb_list = [false, false, false, false, false, false, false, false, false, false, false, false]

@export var temporary_orb_list = [false, false, false, false, false, false, false, false, false, false, false, false]
var death_count = 0
var orb_count = 0
var tool_count = 0
var xPosition = -8299
var yPosition = 2118
var time: float = 0.0


var beat_game_on_last_save: bool = false #so that hitting play after a successful run doesn't trigger the continue option


func save_progress():
	xPosition = get_node("/root/Scene_loader/Testlevel/Player").last_spawnpoint.x
	yPosition = get_node("/root/Scene_loader/Testlevel/Player").last_spawnpoint.y
	
	var savedata = {
		"floor_tool_unlocked" : floor_tool_unlocked,
		"block_tool_unlocked" : block_tool_unlocked,
		"wall_tool_unlocked" : wall_tool_unlocked,
		"spring_tool_unlocked" : spring_tool_unlocked,
		"rope_tool_unlocked" : rope_tool_unlocked,
		"field_tool_unlocked" : field_tool_unlocked,
		"cursed_mode" : cursed_mode,
		"xPosition" : xPosition,
		"yPosition" : yPosition,
		"death_count" : death_count,
		"orb_count" : orb_count,
		"temporary_orb_list" : temporary_orb_list,
		"tool_count" : tool_count,
		"time" : get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").time,
		"beat_game_on_last_save" : beat_game_on_last_save
	}
	
	var jsonString = JSON.stringify(savedata)
	
	var jsonFile = FileAccess.open("user://savedata.json", FileAccess.WRITE)
	jsonFile.store_line(jsonString)

func execute_all_options():
	if not cursed_mode:
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Cursed_Orb")):
			get_node("/root/Scene_loader/Testlevel/Cursed_Orb").queue_free()
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Night_mode_light")):
			get_node("/root/Scene_loader/Testlevel/Night_mode_light").energy = 0.2
			get_node("/root/Scene_loader/Testlevel/Clouds").modulate = Color(1, 1, 1)
			get_node("/root/Scene_loader/Testlevel/Night_mode_light").blend_mode = Light2D.BLEND_MODE_ADD
		for cursed_deco in get_tree().get_nodes_in_group("Cursed_mode_deco"):
			cursed_deco.queue_free()
	else:
		no_dialog = true
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Night_mode_light")):
			get_node("/root/Scene_loader/Testlevel/Night_mode_light").energy = 0.27
			get_node("/root/Scene_loader/Testlevel/Clouds").modulate = Color(0.324, 0.324, 0.324)
			get_node("/root/Scene_loader/Testlevel/Night_mode_light").blend_mode = Light2D.BLEND_MODE_SUB
		for cursed_deco in get_tree().get_nodes_in_group("Cursed_mode_deco"):
			cursed_deco.energy = 0.64
	if no_dialog:
		for triggerbox in get_tree().get_nodes_in_group("Dialog_trigger_group"):
			triggerbox.queue_free()
	if show_timer:
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer")):
			get_node("/root/Scene_loader/Testlevel/Pause_menu/Pause_menu/Show_timer").button_pressed = true
			get_node("/root/Scene_loader/Testlevel/Misc_canvas/Timer").visible = true
	if bullet_time_value != 1.0:
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Pause_menu/Pause_menu/HBoxContainer/Bullet_time_slider")):
			get_node("/root/Scene_loader/Testlevel/Pause_menu/Pause_menu/HBoxContainer/Bullet_time_slider").value = 120 - (bullet_time_value * 100)
	if toggle_to_sprint:
		if is_instance_valid(get_node("/root/Scene_loader/Testlevel/Pause_menu/Pause_menu/Sprint_toggle")):
			get_node("/root/Scene_loader/Testlevel/Pause_menu/Pause_menu/Sprint_toggle").button_pressed = true
			get_node("/root/Scene_loader/Testlevel/Misc_canvas/Sprint_status_icon").visible = true
	
