extends Control

var is_in_death_anim: bool = false
var paused: bool = false
@onready var player: CharacterBody2D = $"../../CharacterBody2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()
	
func toggle_pause_menu():
	if paused:
		if not is_in_death_anim:
			player.controllable = true
		Engine.time_scale = 1
		hide()
	else:
		if not player.controllable:
			is_in_death_anim = true
		else:
			is_in_death_anim = false
			player.controllable = false
		Engine.time_scale = 0
		show()
	paused = not paused


func _on_resume_button_pressed() -> void:
	toggle_pause_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
