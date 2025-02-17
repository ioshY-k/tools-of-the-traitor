extends Node2D

@onready var intro_anim: AnimationPlayer = $Logo_Canvas/Intro_animationPlayer
@onready var press_anything: Label = $Logo_Canvas/Press_anything
signal anything_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro_anim.play("Logo_dia_anim")
	await intro_anim.animation_finished
	press_anything.visible = true
	await anything_pressed
	press_anything.visible = false
	get_node("/root/Scene_loader").fade_to_scene("Main_menu_initial")
	

func _input(event: InputEvent) -> void:
	if not event.is_action("joystick_action"):
		anything_pressed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
