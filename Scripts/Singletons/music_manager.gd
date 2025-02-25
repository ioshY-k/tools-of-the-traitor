extends Node

var Music_handler = preload("res://Scenes/music_handler.tscn").instantiate()
var menu_music
var level_music
var cursed_music

func _ready() -> void:
	add_child(Music_handler)
	menu_music = $Music_handler/Menu_music
	level_music = $Music_handler/Level_music
	cursed_music = $Music_handler/Cursed_music
	

func play_menu_music():
	menu_music.play()
	level_music.stop()
	cursed_music.stop()
	
func play_level_music():
	level_music.play()
	menu_music.stop()
	cursed_music.stop()
	
func play_cursed_music():
	cursed_music.play()
	level_music.stop()
	menu_music.stop()
