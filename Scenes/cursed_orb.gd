extends CharacterBody2D

@export var speed = 350
var direction_to_player: Vector2
var bouncing: bool = false
@onready var bouncetimer: Timer = $Bouncetimer
@onready var player: CharacterBody2D = $"../Player"

@onready var collision_detection_up: Area2D = $Collision_detection_up
@onready var collision_detection_down: Area2D = $Collision_detection_down
@onready var collision_detection_right: Area2D = $Collision_detection_right
@onready var collision_detection_left: Area2D = $Collision_detection_left


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction_to_player = (player.position - position).normalized()
	if not bouncing:
		set_velocity(direction_to_player * speed)
	else:
		velocity = velocity.move_toward(direction_to_player * speed, 400 * delta)
		if velocity.length() >= (direction_to_player * speed).length() * 2:
			print("debugged!")
			velocity = velocity.normalized() * (direction_to_player * speed).length() * 2
		if velocity.length() == (direction_to_player * speed).length():
			print("point reached")
			bouncing = false
	

	move_and_slide()




func _on_collision_detection_left_body_entered(body: Node2D) -> void:
	bouncing = true
	bouncetimer.stop()
	bouncetimer.start()
	velocity = Vector2(-velocity.x, velocity.y) * 1.5
	player.callback_tool(body)
	player.last_placed_tools.pop_at(player.last_placed_tools.find(body))


func _on_collision_detection_up_body_entered(body: Node2D) -> void:
	bouncing = true
	bouncetimer.stop()
	bouncetimer.start()
	velocity = Vector2(velocity.x, -velocity.y) * 1.5
	player.callback_tool(body)
	player.last_placed_tools.pop_at(player.last_placed_tools.find(body))


func _on_collision_detection_down_body_entered(body: Node2D) -> void:
	bouncing = true
	bouncetimer.stop()
	bouncetimer.start()
	velocity = Vector2(velocity.x, -1 * velocity.y) * 1.5
	player.callback_tool(body)
	player.last_placed_tools.pop_at(player.last_placed_tools.find(body))


func _on_collision_detection_right_body_entered(body: Node2D) -> void:
	bouncing = true
	bouncetimer.stop()
	bouncetimer.start()
	velocity = Vector2(-velocity.x, velocity.y) * 1.5
	player.callback_tool(body)
	player.last_placed_tools.pop_at(player.last_placed_tools.find(body))


func _on_bouncetimer_timeout() -> void:
	#bouncing = false
	pass
