extends AnimatedSprite2D

@export var dialog_name : String
@onready var interact_symbol: Sprite2D = $Interact_symbol

var dialog_trigger : PackedScene = preload("res://Scenes/dialog_trigger.tscn")
var interacting_body
var entered: bool = false


func _input(event: InputEvent) -> void:
	if entered and event.is_action_pressed("accept"):
		var dialog_trigger_node : Node = dialog_trigger.instantiate()
		dialog_trigger_node.dialog_name = dialog_name
		add_child(dialog_trigger_node)
		dialog_trigger_node.global_position = interacting_body.position
		entered = false
		


func _on_interact_area_body_entered(body: Node2D) -> void:
	entered = true
	interacting_body = body
	play("sign_anim")
	interact_symbol.visible = true
	


func _on_interact_area_body_exited(_body: Node2D) -> void:
	entered = false
	play("sign_hide")
	interact_symbol.visible = false
