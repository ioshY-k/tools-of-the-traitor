extends Node

var achievement_list = [false, false, false, false, false, false, false, false, false, false]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file := "res://achievements.dat"
	
	var file_r = FileAccess.open(file, FileAccess.READ)
	
	if file_r.get_length() > 0:
		var counter = 0;
		while file_r.get_position() < file_r.get_length():
			achievement_list[counter] = (file_r.get_line() == "true")
			counter += 1
	file_r.close()

func save_new_achievement(index: int):
	achievement_list[index] = true
	
	var file := "res://achievements.dat"
	var file_w = FileAccess.open(file, FileAccess.WRITE)
	for achievement in achievement_list:
		file_w.store_line(str(achievement))
	file_w.close()
