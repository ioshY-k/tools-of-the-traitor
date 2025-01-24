extends Node


func _ready() -> void:
	create_files()

func create_files():
	if not FileAccess.file_exists("user://unlocked_tips.dat"):
		var filecreator = FileAccess.open("user://unlocked_tips.dat", FileAccess.WRITE_READ)
		filecreator.close()
	if not FileAccess.file_exists("user://highscores.dat"):
		var filecreator = FileAccess.open("user://highscores.dat", FileAccess.WRITE_READ)
		filecreator.close()
	if not FileAccess.file_exists("user://achievements.dat"):
		var filecreator = FileAccess.open("user://achievements.dat", FileAccess.WRITE_READ)
		filecreator.close()
	if not FileAccess.file_exists("user://savedata.json"):
		var filecreator = FileAccess.open("user://savedata.json", FileAccess.WRITE_READ)
		var init_dict = {"cursed_mode": true, "beat_game_on_last_save": false}
		var jsonString = JSON.stringify(init_dict)
		filecreator.store_line(jsonString)
