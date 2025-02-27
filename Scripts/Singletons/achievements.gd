extends Node

var achievement_list = [false, false, false, false, false, false, false, false, false, false]
var animation_queue = []
var animations_playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file := "user://achievements.dat"
	
	var file_r = FileAccess.open(file, FileAccess.READ)
	
	if file_r.get_length() > 0:
		var counter = 0;
		while file_r.get_position() < file_r.get_length():
			achievement_list[counter] = (file_r.get_line() == "true")
			counter += 1
	file_r.close()



func save_new_achievement(index: int):
	
	if not achievement_list[index]:
		animation_queue.append(index)
		if not animations_playing:
			play_animations()
	
	achievement_list[index] = true
	
	var file := "user://achievements.dat"
	var file_w = FileAccess.open(file, FileAccess.WRITE)
	for achievement_got in achievement_list:
		file_w.store_line(str(achievement_got))
	file_w.close()
	

		
	
	
	
	
func play_animations():
	animations_playing = true
	print_debug("animations are playing")
	while (len(animation_queue) > 0):
		var current_achievement = animation_queue.pop_front()
		var achievement_panel = get_parent().get_node("/root/Scene_loader/Testlevel/Misc_canvas/new_achievement_panel")
		var achievement_sprite : AnimatedSprite2D = achievement_panel.get_child(0)
		achievement_sprite.set_frame(current_achievement)
		get_tree().create_tween() \
			.tween_property(achievement_panel, "position:x", 1720, 0.6) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.8).timeout
		get_tree().create_tween() \
			.tween_property(achievement_panel, "position:x", 1945, 0.6) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_IN)
		await get_tree().create_timer(1).timeout
	print_debug("animations are finishing")
	animations_playing = false
	
