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
@onready var p_speed_timer: Timer = $P_speed_timer #time Player has to maintain runspeed to enter P speed
var p_speed_is_active:bool
@onready var player_cutout: Node2D = $Player_cutout
@onready var animations: AnimationPlayer = player_cutout.get_node("AnimationPlayer")
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
@onready var sprite_floor_tool: Sprite2D = $Path2D/Follow_floor_tool/Sprite_floor_tool
@onready var sprite_block_tool: Sprite2D = $Sprite_block_tool
@onready var follow_floor_tool: PathFollow2D = %Follow_floor_tool
@onready var floor_typecheck: Area2D = $Floor_typecheck
var is_on_tool:bool
const BASE_X_SCALE = 1.395
var sliding_on_left_wall:bool
var sliding_on_right_wall:bool


enum states {	IDLE, WALK, RUN, JUMP, FALL,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R,
				FLOOR_TOOL_PREVIEW, BLOCK_TOOL_PREVIEW,
				FLOOR_TOOL_PLACE, BLOCK_TOOL_PLACE,
				FLOOR_TOOL_CANCEL, BLOCK_TOOL_CANCEL}
var current_state = -1
@onready var state_handler = $State_handler


enum anim_states {GROUNDED, TAKEOFF, AIRBORNE, LANDING, WALLSLIDE}
var current_anim_state = anim_states.GROUNDED


func _process(_delta: float) -> void:
	sliding_on_left_wall = is_on_wall() and (caster_left_wall.is_colliding() and caster_left_wall_2.is_colliding())
	sliding_on_right_wall = is_on_wall() and (caster_right_wall.is_colliding() and caster_right_wall_2.is_colliding())
	current_state = state_handler.next_state(is_on_floor(), sliding_on_left_wall, sliding_on_right_wall)
	state_handler.set("current_state", current_state)


func _physics_process(delta: float) -> void:

	match current_state:
		states.IDLE:
			on_idle_state(delta)
		states.WALK:
			on_walk_state(delta)
		states.RUN:
			on_run_state(delta)
		states.JUMP:
			on_jump_state()
		states.FALL:
			on_fall_state(delta)
		states.WALLSLIDE_L:
			on_wallslide_l_state(delta)
		states.WALLSLIDE_R:
			on_wallslide_r_state(delta)
		states.WALLJUMP_L:
			on_walljump_l_state()
		states.WALLJUMP_R:
			on_walljump_r_state()
		states.FLOOR_TOOL_PREVIEW:
			on_floortool_preview_state(delta)
		states.BLOCK_TOOL_PREVIEW:
			on_blocktool_preview_state(delta)
		states.FLOOR_TOOL_CANCEL:
			on_floortool_cancel_state()
		states.BLOCK_TOOL_CANCEL:
			on_blocktool_cancel_state()
		states.FLOOR_TOOL_PLACE:
			on_floortool_place_state(delta)
		states.BLOCK_TOOL_PLACE:
			on_blocktool_place_state(delta)

	current_anim_state = _animation_state_handler(sliding_on_left_wall or sliding_on_right_wall)
	match current_anim_state:
		anim_states.GROUNDED:
			if velocity == Vector2(0,0):
				animations.play("Idle_anim", 0.3)
			elif abs(velocity.x) < MAX_RUN_SPEED:
				animations.play("Walking_anim", 0.5)
			elif abs(velocity.x) < MAX_P_SPEED:
				animations.play("Fastwalk_anim", 0.5)
			else:
				animations.play("Run_anim", 1)
		anim_states.TAKEOFF:
			animations.play("Jumpstart_anim", 0.1)
		anim_states.AIRBORNE:
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
		anim_states.LANDING:
			animations.play("Landing_anim", 0)
		anim_states.WALLSLIDE:
			if velocity.y >= 0:
				animations.play("Wallslide_anim", 0.1)
	

	
	
	
	move_and_slide() #Player movement
	


func _animation_state_handler(sliding_on_wall) -> anim_states:
	if is_on_floor():
		if current_anim_state == anim_states.AIRBORNE:
			return anim_states.LANDING
		else:
			return anim_states.GROUNDED
	elif sliding_on_wall:
		return anim_states.WALLSLIDE
	else:
		if current_anim_state == anim_states.GROUNDED:
			return anim_states.TAKEOFF
		else:
			if animations.current_animation != "Jumpstart_anim":
				return anim_states.AIRBORNE
			else:
				return anim_states.TAKEOFF

func on_idle_state(delta):
	velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	p_speed_timer.stop()
	p_speed_is_active = false

func on_walk_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		player_cutout.scale.x = -abs(player_cutout.scale.x)
		player_cutout.position.x = SPRITE_FLIP_X_OFFSET
	elif direction > 0:
		player_cutout.scale.x = abs(player_cutout.scale.x)
		player_cutout.position.x = 0
	velocity.x = move_toward(velocity.x, direction * MAX_WALK_SPEED, ACCELERATION * delta)
	p_speed_timer.stop()
	p_speed_is_active = false

func on_run_state(delta):
	
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		player_cutout.scale.x = -abs(player_cutout.scale.x)
		player_cutout.position.x = SPRITE_FLIP_X_OFFSET
	elif direction > 0:
		player_cutout.scale.x = abs(player_cutout.scale.x)
		player_cutout.position.x = 0
		
	if p_speed_is_active:
		#print("P-SPEED")
		velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, ACCELERATION * delta)
	elif p_speed_timer.is_stopped():
		#print("time start")
		p_speed_timer.start()
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)
	else:
		#print("RUN")
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)

func on_jump_state():
	velocity.y = -(JUMPFORCE + JUMPFORCE_INCREASE * int(abs(velocity.x) / 30))

func on_fall_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		player_cutout.scale.x = -abs(player_cutout.scale.x)
		player_cutout.position.x = SPRITE_FLIP_X_OFFSET
	elif direction > 0:
		player_cutout.scale.x = abs(player_cutout.scale.x)
		player_cutout.position.x = 0
	
	if not Input.is_action_pressed("run"):
		p_speed_is_active = false
	
	if p_speed_is_active:
		velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, AIR_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, AIR_ACCELERATION * delta)
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = min(velocity.y + GRAVITY_FALLING * delta, MAX_FALLSPEED)

#TODO: identische Funktionen wallslide r und l?
func on_wallslide_l_state(delta):
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = GRAVITY_WALL_SLIDING
	velocity.x = sign(Input.get_axis("walk_left", "walk_right"))

func on_wallslide_r_state(delta):
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = GRAVITY_WALL_SLIDING
	velocity.x = sign(Input.get_axis("walk_left", "walk_right"))

func on_walljump_l_state():
	p_speed_is_active = true
	velocity = Vector2(WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)

func on_walljump_r_state():
	p_speed_is_active = true
	velocity = Vector2(-WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)

func on_floortool_preview_state(delta):
	on_idle_state(delta)
	
	sprite_block_tool.visible = false
	if not is_on_tool:
		#Floor Tool Preview
		sprite_floor_tool.visible = true
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
		follow_floor_tool.progress_ratio = \
		determine_floortool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())

func on_blocktool_preview_state(delta):
	on_fall_state(delta)
	
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = true
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	determine_blocktool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())

func on_floortool_cancel_state():
	pass

func on_blocktool_cancel_state():
	pass

func on_floortool_place_state(delta):
	on_idle_state(delta)
	
	if sprite_floor_tool.visible:
		sprite_floor_tool.visible = false
		get_parent().get_node("%Floor_tool").position = sprite_floor_tool.global_position + Vector2(140,0)

func on_blocktool_place_state(delta):
	on_fall_state(delta)
	
	if sprite_block_tool.visible:
		sprite_block_tool.visible = false
		get_parent().get_node("%Block_tool").position = sprite_block_tool.global_position





func _ledge_corrections():
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
 



		
			
	




func determine_floortool_position(inputstrength, controllerangle) -> float:
	#Control stick Deadzone
	if inputstrength > Vector2(0.3,0.3).abs().length():
		return (controllerangle + PI)/(2*PI)
	else:
		return follow_floor_tool.progress_ratio


func determine_blocktool_position(inputstrength, controllerangle):
	#Control stick Deadzone
	if inputstrength > Vector2(0.3,0.3).abs().length():
		#Snap behaviour when placing below PLayer
		if controllerangle > (3*PI/8) and controllerangle < (5*PI/8):
			sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.DOWN
		elif player_cutout.scale.x > 0:
			#Snap behaviour when facing right
			if controllerangle > (-PI/8) and controllerangle < (PI/8):
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT
			elif controllerangle > (PI/8) and controllerangle < (3*PI/8):
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(3*PI/8)
			else:
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(controllerangle)
		else:
			#Snap behaviour when facing left
			if controllerangle > (7*PI/8) or controllerangle < (-7*PI/8):
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.LEFT
			elif controllerangle > (5*PI/8) and controllerangle < (7*PI/8):
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(5*PI/8)
			else:
				sprite_block_tool.position = PREVIEW_PATH_OFFSET + 45 * Vector2.RIGHT.rotated(controllerangle)
				

func _on_floor_typecheck_body_entered(body: Node2D) -> void:
	is_on_tool = true


func _on_floor_typecheck_body_exited(body: Node2D) -> void:
	is_on_tool = false


func _on_p_speed_timer_timeout() -> void:
	p_speed_is_active = true
