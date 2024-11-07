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
			velocity = velocity.normalized() * (direction_to_player * speed).length() * 2
		if velocity.length() == (direction_to_player * speed).length():
			bouncing = false
	

	move_and_slide()




func _on_collision_detection_left_body_entered(body: Node2D) -> void:
	tool_got_hit(body, Vector2(-velocity.x, velocity.y))


func _on_collision_detection_up_body_entered(body: Node2D) -> void:
	tool_got_hit(body, Vector2(velocity.x, -velocity.y))


func _on_collision_detection_down_body_entered(body: Node2D) -> void:
	tool_got_hit(body, Vector2(velocity.x, -velocity.y))


func _on_collision_detection_right_body_entered(body: Node2D) -> void:
	tool_got_hit(body, Vector2(-velocity.x, velocity.y))

func tool_got_hit(body, direction: Vector2):
	if body.name == "Player":
		return
	bouncing = true
	bouncetimer.stop()
	bouncetimer.start()
	velocity = direction * 1.5
	player.callback_tool(body)
	player.last_placed_tools.pop_at(player.last_placed_tools.find(body))


func _on_collision_detection_up_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		player_got_hit()


func _on_collision_detection_down_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		player_got_hit()


func _on_collision_detection_right_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		player_got_hit()


func _on_collision_detection_left_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		player_got_hit()

func player_got_hit():
	var spawn_position = player.last_spawnpoint
	position += Vector2(0,20000)
	$Sprite_cursedorb.visible = false
	await get_tree().create_timer(3).timeout
	position = spawn_position
	$Sprite_cursedorb.visible = true
