extends CharacterBody2D

const ACCELERATION = 2300 #How fast Player reaches run speed
const DECELERATION = 3000 #How long until Player stops after moving
const AIR_ACCELERATION = 1700
const AIR_DECELERATION = 0
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
var p_speed_is_active = false
@onready var jump_buffer_timer: Timer = $Jump_buffer_timer #time the jumpp button press gets buffered before landing on the ground
@onready var player_cutout: Node2D = $Player_cutout
@onready var animations: AnimationPlayer = player_cutout.get_node("AnimationPlayer")
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var caster_outer_right_ceiling: RayCast2D = $Caster_outer_right_ceiling
@onready var caster_inner_right_ceiling: RayCast2D = $Caster_inner_right_ceiling
@onready var caster_outer_left_ceiling: RayCast2D = $Caster_outer_left_ceiling
@onready var caster_inner_left_ceiling: RayCast2D = $Caster_inner_left_ceiling
@onready var caster_right_wall: RayCast2D = $Caster_right_wall
@onready var caster_left_wall: RayCast2D = $Caster_left_wall
@onready var caster_right_wall_2: RayCast2D = $Caster_right_wall2
@onready var caster_left_wall_2: RayCast2D = $Caster_left_wall2
const PREVIEW_PATH_OFFSET = Vector2(0,-10) #Positional offset from the center of the tool preview path
const SPRITE_FLIP_X_OFFSET = 5 #Player facing left and right is realized by scaling.x * -1 which doesnt mirror on the center of Player. Changing position by this offset corrects this error
@onready var testsprite_big: Sprite2D = $Testsprite_big
@onready var testsprite_small: Sprite2D = $Testsprite_small
enum tools {L_BLOCK, S_BLOCK, WALL, ROPE, SPRING, FIELD}


const BASE_X_SCALE = 1.395

var jump_plays: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	jump_plays = animations.current_animation
	var sliding_on_left_wall = is_on_wall() and (caster_left_wall.is_colliding() and caster_left_wall_2.is_colliding())
	var sliding_on_right_wall = is_on_wall() and (caster_right_wall.is_colliding() and caster_right_wall_2.is_colliding())
	
	_jump_action(sliding_on_left_wall, sliding_on_right_wall) #Player jumping or walljumping
	_gravity_manager(delta, sliding_on_left_wall, sliding_on_right_wall) #Player gravity
	_speed_manager(delta) #Player running
	_ledge_corrections() #Pushing player to outer Edge of ceiling /wall/floor
	_animation_handler(sliding_on_left_wall or sliding_on_right_wall) #Player animations
	_tool_preview()
	
	#print(animations.current_animation)
	
	var was_on_floor = is_on_floor() #Save position before movement for coyote timer
	
	move_and_slide() #Player movement
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	

func _jump_action(sliding_on_left_wall, sliding_on_right_wall):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer.time_left > 0:
			#Jump input on floor
			velocity.y = _current_jumpforce()
		elif sliding_on_left_wall:
			#Jump input on left Wall
			p_speed_is_active = true
			velocity = Vector2(WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
		elif sliding_on_right_wall:
			#Jump input on right Wall
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
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		player_cutout.scale.x = -abs(player_cutout.scale.x)
		player_cutout.position.x = SPRITE_FLIP_X_OFFSET
	elif direction > 0:
		player_cutout.scale.x = abs(player_cutout.scale.x)
		player_cutout.position.x = 0
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
			return MAX_P_SPEED
		if p_speed_timer.is_stopped():
			#print("time start")
			p_speed_timer.start()
			return MAX_RUN_SPEED
		else:
			if p_speed_timer.time_left <= 0.1:
				#print("timeout")
				p_speed_is_active = true
				return MAX_P_SPEED
			else:
				#print("RUN")
				return MAX_RUN_SPEED
	else:
		#print("WALK")
		p_speed_timer.stop()
		p_speed_is_active = false
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
 
enum states {GROUNDED, TAKEOFF, AIRBORNE, LANDING, WALLSLIDE}
var current_state = states.GROUNDED
func _animation_handler(sliding_on_wall):
	
	if is_on_floor():
		if current_state == states.AIRBORNE:
			current_state = states.LANDING
		else:
			current_state = states.GROUNDED
	elif sliding_on_wall:
		current_state = states.WALLSLIDE
	else:
		if current_state == states.GROUNDED:
			current_state = states.TAKEOFF
		else:
			if animations.current_animation != "Jumpstart_anim":
				current_state = states.AIRBORNE
			else:
				current_state = states.TAKEOFF
		
			
	
	match current_state:
		states.GROUNDED:
			if velocity == Vector2(0,0):
				animations.play("Idle_anim", 0.3)
			elif abs(velocity.x) < MAX_RUN_SPEED:
				animations.play("Walking_anim", 0.5)
			elif abs(velocity.x) < MAX_P_SPEED:
				animations.play("Fastwalk_anim", 0.5)
			else:
				animations.play("Run_anim", 1)
		states.TAKEOFF:
			animations.play("Jumpstart_anim", 0.1)
		states.AIRBORNE:
			if velocity.y < 0:
				if abs(velocity.x) >= MAX_P_SPEED:
					animations.play("Pjump_anim", 0.2)
				else:
					animations.play("Jump_anim", 0.2)
			if velocity.y > 0:
				if abs(velocity.x) >= MAX_P_SPEED:
					animations.play("Pjump_anim", 0.1)
				else:
					animations.play("Fall_anim", 0.2)
		states.LANDING:
			animations.play("Landing_anim", 0)
		states.WALLSLIDE:
			if velocity.y >= 0:
				animations.play("Wallslide_anim", 0.1)

func _tool_preview():
	if Input.is_action_pressed("place_simple_tool"):
		if is_on_floor() and false:
			pass
		else:
			testsprite_small.visible = true
			var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
			var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
			determine_sblock_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())
		
	else:
		if testsprite_small.visible:
			testsprite_small.visible = false
			get_parent().get_node("%Small_block").position = testsprite_small.global_position

func determine_sblock_position(inputstrength, controllerangle):
	
	if inputstrength > Vector2(0.3,0.3).abs().length():
		#Snap behaviour when placing below PLayer
		if controllerangle > (3*PI/8) and controllerangle < (5*PI/8):
			testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.DOWN
		elif player_cutout.scale.x > 0:
			#Snap behaviour when facing right
			if controllerangle > (-PI/8) and controllerangle < (PI/8):
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT
			elif controllerangle > (PI/8) and controllerangle < (3*PI/8):
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(PI/4)
			else:
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(controllerangle)
		else:
			#Snap behaviour when facing left
			print(str(controllerangle))
			if controllerangle > (7*PI/8) or controllerangle < (-7*PI/8):
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.LEFT
			elif controllerangle > (5*PI/8) and controllerangle < (7*PI/8):
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(3*PI/4)
			else:
				testsprite_small.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(controllerangle)

			#print("here not")

func _calc_preview_path_shape(angle) -> int :
	var weight = sin(2 * angle)
	return 47 + (60 - 47) * pow(weight, 2)
