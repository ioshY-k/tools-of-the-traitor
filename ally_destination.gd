extends Area2D

@onready var player: CharacterBody2D = $".."
const DISTANCE = 60
var mirror = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("walk_right"):
		mirror = -1
	elif Input.is_action_just_pressed("walk_left"):
		mirror = 1
	if player.velocity == Vector2.ZERO:
		position.x = DISTANCE * mirror
	else:
		position = -1 * player.velocity.normalized() * DISTANCE
