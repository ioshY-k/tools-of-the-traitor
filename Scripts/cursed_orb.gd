extends CharacterBody2D

@onready var speed = 350
var catchup_speed = 600
var direction_to_player: Vector2
var high_distance_to_player: bool
var bouncing: bool = false
var inside_wall: bool = false
@onready var bouncetimer: Timer = $Bouncetimer
@onready var player: CharacterBody2D = $"../Player"

@onready var collision_detection_up: Area2D = $Collision_detection_up
@onready var collision_detection_down: Area2D = $Collision_detection_down
@onready var collision_detection_right: Area2D = $Collision_detection_right
@onready var collision_detection_left: Area2D = $Collision_detection_left
@onready var respawn_timer: Timer = $Respawn_timer
@onready var ground_layer: TileMapLayer = $"../Ground_tilemap/Ground_layer"
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var wall_slowdown = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_got_hit()

		

var test = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#checks every frame if the Orb is inside a wall
	if ground_layer.get_cell_source_id( ground_layer.local_to_map(position)) != -1:
		point_light_2d.color.a = move_toward(point_light_2d.color.a, randf_range(0.5,1), delta*10)
		point_light_2d.texture_scale = move_toward(point_light_2d.texture_scale, 1.2, delta*2)
		if wall_slowdown != 0.5:
			wall_slowdown = 0.5
			particles.amount = 26
			particles.initial_velocity_max = 280
			particles.gravity = Vector2(0,700)
			particles.color = Color(0.197, 0.242, randf_range(0.65,0.40))
	else:
		point_light_2d.color.a = move_toward(point_light_2d.color.a, 0, delta*3)
		point_light_2d.texture_scale = move_toward(point_light_2d.texture_scale, 0.8, delta*2)
		if wall_slowdown != 1:
			wall_slowdown = 1
			particles.amount = 9
			particles.initial_velocity_max = 40
			particles.gravity = Vector2(0,0)
			particles.color = Color(0.089, 0.012, 0.036)
			
	
	direction_to_player = (player.position - position).normalized()
	high_distance_to_player = (player.position - position).length() > 2000
	if not bouncing:
		if high_distance_to_player:
			set_velocity(direction_to_player * catchup_speed)
		else:
			set_velocity(direction_to_player * speed * wall_slowdown)
					
	else:
		velocity = velocity.move_toward(direction_to_player * speed * wall_slowdown, 400 * delta)
		if velocity.length() > (direction_to_player * speed * wall_slowdown).length() * 2:
			velocity = velocity.normalized() * (direction_to_player * speed * wall_slowdown).length() * 2
		if velocity.length() == (direction_to_player * speed * wall_slowdown).length():
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
	velocity = direction * 2
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
	position = Vector2(0,20000)
	respawn_timer.stop()
	respawn_timer.start()


func _on_respawn_timer_timeout() -> void:
	position = player.last_spawnpoint
