extends CharacterBody2D

const ACCELERATION = 2300 #How fast Player reaches run speed
const DECELERATION = 1300 #How long until Player stops after moving
const AIR_ACCELERATION = 1700
const AIR_DECELERATION = 700
const GRAVITY_RISING = 1500 #How fast Player falls with holding jump
const GRAVITY_FALLING = 6500 #How much stronger  gravity pulls in falling state vs. rising state
const MAX_FALLSPEED = 900 #The point where gravity doesn't accelerate fallspeed enymore
const JUMPFORCE = 700 #How high Player gets send when jumping
const JUMPFORCE_INCREASE = 5 #How much runspeed influences jump height
const MAX_WALK_SPEED = 310 #Player walk speed
const MAX_RUN_SPEED = 450 #Player run speed
const MAX_P_SPEED = 600 #Player P speed
const GRAVITY_WALL_SLIDING = 300
const WALL_JUMP_HEIGHT = 800
const WALL_JUMP_WIDTH = 1000
@onready var coyote_timer: Timer = $Coyote_timer #time after leaving ledge where jumpping is still allowed
@onready var p_speed_timer: Timer = $P_speed_timer #time Player has to maintain runspeed to enter P speed
@onready var jump_buffer_timer: Timer = $Jump_buffer_timer #time the jumpp button press gets buffered before landing on the ground
@onready var p_speed_is_active = false
@onready var direction
@onready var player_cutout: Node2D = $Player_cutout
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var caster_outer_right_ceiling: RayCast2D = $Caster_outer_right_ceiling
@onready var caster_inner_right_ceiling: RayCast2D = $Caster_inner_right_ceiling
@onready var caster_outer_left_ceiling: RayCast2D = $Caster_outer_left_ceiling
@onready var caster_inner_left_ceiling: RayCast2D = $Caster_inner_left_ceiling
@onready var caster_right_wall: RayCast2D = $Caster_right_wall
@onready var caster_left_wall: RayCast2D = $Caster_left_wall
@onready var caster_right_wall_2: RayCast2D = $Caster_right_wall2
@onready var caster_left_wall_2: RayCast2D = $Caster_left_wall2
const BASE_X_SCALE = 1.395



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	
	var sliding_on_left_wall = is_on_wall() and (caster_left_wall.is_colliding() and caster_left_wall_2.is_colliding())
	var sliding_on_right_wall = is_on_wall() and (caster_right_wall.is_colliding() and caster_right_wall_2.is_colliding())
	
	_jump_action(sliding_on_left_wall, sliding_on_right_wall) #Player jumping or walljumping
	_gravity_manager(delta, sliding_on_left_wall, sliding_on_right_wall) #Player gravity
	_speed_manager(delta) #Player running
	_ledge_corrections() #Pushing player to outer Edge of ceiling /wall/floor
	#_wall_jump() #Player sliding and jumping on wall
	
	var was_on_floor = is_on_floor() #Save position before movement for coyote timer
	
	move_and_slide() #Player movement
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	

func _jump_action(sliding_on_left_wall, sliding_on_right_wall):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer.time_left > 0:
			#Jump input on floor
			player_cutout.get_node("AnimationPlayer").play("Jumpstart_anim", 1)
			velocity.y = _current_jumpforce()
			print("here")
		elif sliding_on_left_wall:
			print("jumpwall")
			p_speed_is_active = true
			velocity = Vector2(WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
		elif sliding_on_right_wall:
			print("walljump")
			p_speed_is_active = true
			velocity = Vector2(-WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
		else:
			#Jump input in midair
			jump_buffer_timer.start()
	else:
		if (is_on_floor() or coyote_timer.time_left > 0) and jump_buffer_timer.time_left > 0:
			#Jump caused by Jump buffer
			velocity.y = _current_jumpforce()


func _current_jumpforce():
	return -(JUMPFORCE + JUMPFORCE_INCREASE * int(abs(velocity.x) / 30))


func _gravity_manager(delta, sliding_on_left_wall, sliding_on_right_wall):
	if not is_on_floor():
		if velocity.y <= 0:
			if Input.is_action_pressed("jump"):
				#Rising while holding jump
				velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
			else:
				#Rising while pressing jump
				velocity.y = min(velocity.y + GRAVITY_FALLING * delta, MAX_FALLSPEED)
		else:
			if sliding_on_left_wall or sliding_on_right_wall:
				#Descending while on Wall
				velocity.y = GRAVITY_WALL_SLIDING
			else:
				#Descending while midair
				velocity.y = min(velocity.y + GRAVITY_FALLING * delta, MAX_FALLSPEED)
		


func _speed_manager(delta):
	if velocity.x < 0:
		player_cutout.scale.x = BASE_X_SCALE * -1
	elif velocity.x > 0:
		player_cutout.scale.x = BASE_X_SCALE * 1
	direction = Input.get_axis("walk_left", "walk_right")
	if direction:
		if is_on_floor():
			#Bewegung auf dem Boden
			velocity.x = move_toward(velocity.x, direction * _current_max_speed(), ACCELERATION * delta)				
		else:
			#Bewegung in der Luft
			#TODO: current_max_speed mit parameter is_on_floor, damit kein P speed geht
			velocity.x = move_toward(velocity.x, direction * _current_max_speed(), AIR_ACCELERATION * delta)
	else:
		if is_on_floor():
			#Keine Bewegung auf dem Boden
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			if velocity.x == 0:
				player_cutout.get_node("AnimationPlayer").play("Idle_anim", 1)
		else:
			#Keine Bewegung in der Luft
			velocity.x = move_toward(velocity.x, 0, AIR_DECELERATION * delta)

	if p_speed_is_active and abs(velocity.x) <= MAX_RUN_SPEED:
		p_speed_timer.stop()
		p_speed_is_active = false


func _current_max_speed():
	if Input.is_action_pressed("run"):
		if p_speed_is_active:
			#print("P-SPEED")
			player_cutout.get_node("AnimationPlayer").play("Run_anim", 1)
			return MAX_P_SPEED
		if p_speed_timer.is_stopped():
			#print("time start")
			p_speed_timer.start()
			player_cutout.get_node("AnimationPlayer").play("Fastwalk_anim", 1)
			return MAX_RUN_SPEED
		else:
			if p_speed_timer.time_left <= 0.1:
				#print("timeout")
				p_speed_is_active = true
				player_cutout.get_node("AnimationPlayer").play("Run_anim", 1)
				return MAX_P_SPEED
			else:
				#print("RUN")
				player_cutout.get_node("AnimationPlayer").play("Fastwalk_anim", 1)
				return MAX_RUN_SPEED
	else:
		#print("WALK")
		p_speed_timer.stop()
		p_speed_is_active = false
		player_cutout.get_node("AnimationPlayer").play("Walking_anim", 1)
		return MAX_WALK_SPEED
		
		
func _ledge_corrections():
	if not is_on_floor():
		if caster_inner_left_ceiling.is_colliding() or caster_inner_right_ceiling.is_colliding():
			caster_outer_left_ceiling.enabled = false
			caster_outer_right_ceiling.enabled = false
		else:
			caster_outer_left_ceiling.enabled = true
			caster_outer_right_ceiling.enabled = true
		if caster_outer_left_ceiling.is_colliding():
			global_position += Vector2(7,0)
		if caster_outer_right_ceiling.is_colliding():
			global_position += Vector2(-7,0)


		
