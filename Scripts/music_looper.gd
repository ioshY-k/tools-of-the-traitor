extends Node


func _on_menu_music_finished() -> void:
	MusicManager.play_menu_music()


func _on_level_music_finished() -> void:
	MusicManager.play_level_music()


func _on_cursed_music_finished() -> void:
	MusicManager.play_cursed_music()
