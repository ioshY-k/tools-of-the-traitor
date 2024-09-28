extends CharacterBody2D

#Movement variables
const ACCELERATION = 2300 * 2.5 #How fast Player reaches run speed
const DECELERATION = 3000 * 2.5 #How long until Player stops after moving
const AIR_ACCELERATION = 1700 * 2.5
const GRAVITY_RISING = 1700 * 2.5 #How fast Player falls with holding jump
const GRAVITY_FALLING = 3800 * 2.5 #How much stronger  gravity pulls in falling state vs. rising state
const MAX_FALLSPEED = 700 * 2.5 #The point where gravity doesn't accelerate fallspeed enymore
const JUMPFORCE = 620 * 2.5 #How high Player gets send when jumping
const JUMPFORCE_INCREASE = 6 #How much runspeed influences jump height
const MAX_WALK_SPEED = 250 * 2.5 #Player walk speed
const MAX_RUN_SPEED = 400 * 2.5 #Player run speed
const MAX_P_SPEED = 500 * 2.5 #Player P speed
const GRAVITY_WALL_SLIDING = 300 * 2.5
const WALL_JUMP_HEIGHT = 700 * 2.5
const WALL_JUMP_WIDTH = 750 * 2.5
@onready var p_speed_timer: Timer = $P_speed_timer #time Player has to maintain runspeed to enter P speed
var p_speed_is_active: bool
var sliding_on_left_wall: bool
var sliding_on_right_wall: bool

#Detection of surroundings
@onready var caster_outer_right_ceiling: RayCast2D = $Caster_outer_right_ceiling
@onready var caster_inner_right_ceiling: RayCast2D = $Caster_inner_right_ceiling
@onready var caster_outer_left_ceiling: RayCast2D = $Caster_outer_left_ceiling
@onready var caster_inner_left_ceiling: RayCast2D = $Caster_inner_left_ceiling
@onready var caster_right_wall: RayCast2D = $Caster_right_wall
@onready var caster_left_wall: RayCast2D = $Caster_left_wall
@onready var caster_right_wall_2: RayCast2D = $Caster_right_wall2
@onready var caster_left_wall_2: RayCast2D = $Caster_left_wall2
@onready var floor_typecheck: Area2D = $Floor_typecheck

#Player model and animation
@onready var player_cutout: Node2D = $Model_position/Player_cutout
@onready var animations: AnimationPlayer = player_cutout.get_node("AnimationPlayer")
@onready var model_position: Node2D = $Model_position
@onready var left_arm: Sprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_leftarm")
@onready var left_hand: Sprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_leftarm/Player_lefthand")
@onready var eyes: AnimatedSprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_head/Player_eyes")

#Tool placement
const PREVIEW_PATH_OFFSET = Vector2(0,0) #Positional offset from the center of the tool preview path
@onready var sprite_floor_tool: Sprite2D = $Path2D/Follow_floor_tool/Sprite_floor_tool
@onready var sprite_block_tool: Sprite2D = $Sprite_block_tool
@onready var sprite_wall_tool: Sprite2D = $Sprite_wall_tool
@onready var follow_floor_tool: PathFollow2D = %Follow_floor_tool
var is_on_tool: bool
var floor_tool_available: bool = true
var block_tool_available: bool = true
var wall_tool_available: bool = true
var rope_tool_available: bool = true
var spring_tool_available: bool = true
var field_tool_available: bool = true
@onready var supercancel_timer: Timer = $Supercancel_timer

#Other
var controllable: bool = true
@onready var last_spawnpoint = position

#State handler
@onready var state_handler = $State_handler
var current_state
enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R}
@onready var tool_state_handler = $Tool_state_handler
var current_tool_state
enum tool_states {	NO_TOOL, CANCEL,
					FLOOR_TOOL_PREVIEW, FLOOR_TOOL_PLACE,
					BLOCK_TOOL_PREVIEW, BLOCK_TOOL_PLACE,
					WALL_TOOL_PREVIEW, WALL_TOOL_PLACE,
					ROPE_TOOL_PREVIEW, ROPE_TOOL_PLACE,
					SPRING_TOOL_PREVIEW, SPRING_TOOL_PLACE,
					FIELD_TOOL_PREVIEW, FIELD_TOOL_PLACE}


func _physics_process(delta: float) -> void:
	sliding_on_left_wall = is_on_wall() and (caster_left_wall.is_colliding() and caster_left_wall_2.is_colliding())
	sliding_on_right_wall = is_on_wall() and (caster_right_wall.is_colliding() and caster_right_wall_2.is_colliding())
	current_state = state_handler.next_state(is_on_floor(), sliding_on_left_wall, sliding_on_right_wall)
	state_handler.set("current_state", current_state)
	current_tool_state = tool_state_handler.next_state(is_on_floor())
	tool_state_handler.set("current_tool_state", current_tool_state)
	print("player")
	print(position)
	check_supercancel()
	
	if controllable:
		match current_state:
			states.IDLE:
				on_idle_state(delta)
			states.WALK:
				on_walk_state(delta)
			states.RUN:
				on_run_state(delta)
			states.PUSH:
				on_push_state()
			states.JUMP:
				on_jump_state()
			states.FALL:
				on_fall_state(delta)
			states.LAND:
				on_land_state()
			states.WALLSLIDE_L:
				on_wallslide_l_state(delta)
			states.WALLSLIDE_R:
				on_wallslide_r_state(delta)
			states.WALLJUMP_L:
				on_walljump_l_state()
			states.WALLJUMP_R:
				on_walljump_r_state()
				
		match current_tool_state:
			tool_states.NO_TOOL:
				pass
			tool_states.CANCEL:
				on_cancel_state()
			tool_states.FLOOR_TOOL_PREVIEW:
				on_floortool_preview_state(delta)
			tool_states.FLOOR_TOOL_PLACE:
				on_floortool_place_state()
			tool_states.BLOCK_TOOL_PREVIEW:
				on_blocktool_preview_state()
			tool_states.BLOCK_TOOL_PLACE:
				on_blocktool_place_state()
			tool_states.WALL_TOOL_PREVIEW:
				on_wall_tool_preview_state(delta)
			tool_states.WALL_TOOL_PLACE:
				on_wall_tool_place_state()
			tool_states.ROPE_TOOL_PREVIEW:
				on_rope_tool_preview_state()
			tool_states.ROPE_TOOL_PLACE:
				on_rope_tool_place_state()
			tool_states.SPRING_TOOL_PREVIEW:
				on_spring_tool_preview_state()
			tool_states.SPRING_TOOL_PLACE:
				on_spring_tool_place_state()
			tool_states.FIELD_TOOL_PREVIEW:
				on_field_tool_preview_state()
			tool_states.FIELD_TOOL_PLACE:
				on_field_tool_place_state()
		
	
	move_and_slide() #Player movement

func check_supercancel():
	if is_on_floor() and Input.is_action_just_pressed("cancel_tool"):
		supercancel_timer.start()
		eyes.play("loading_supercancel_anim")
	if not supercancel_timer.is_stopped() and not Input.is_action_pressed("cancel_tool"):
		supercancel_timer.stop()
		eyes.stop()
	supercancel_timer.timeout.connect(func():
		get_parent().get_node("%Floor_tool").set_process_mode(PROCESS_MODE_DISABLED)
		get_parent().get_node("%Block_tool").set_process_mode(PROCESS_MODE_DISABLED)
		get_parent().get_node("%Wall_tool").set_process_mode(PROCESS_MODE_DISABLED)
		get_parent().get_node("%Floor_tool").visible = false
		get_parent().get_node("%Block_tool").visible = false
		get_parent().get_node("%Wall_tool").visible = false
		if is_on_tool:
			await get_tree().create_timer(0.6).timeout
		floor_tool_available = true
		block_tool_available = true
		wall_tool_available = true)

func on_idle_state(delta):
	velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	p_speed_timer.stop()
	p_speed_is_active = false
	if current_tool_state == tool_states.NO_TOOL:
		animations.play("Idle_anim" ,0.2)


func on_walk_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		model_position.scale.x = -abs(model_position.scale.x)
	elif direction > 0:
		model_position.scale.x = abs(model_position.scale.x)
	velocity.x = move_toward(velocity.x, direction * MAX_WALK_SPEED, ACCELERATION * delta)
	p_speed_timer.stop()
	p_speed_is_active = false
	if current_tool_state == tool_states.NO_TOOL:
		animations.play("Walk_anim" ,0.2)


func on_run_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		model_position.scale.x = -abs(model_position.scale.x)
	elif direction > 0:
		model_position.scale.x = abs(model_position.scale.x)
		
	if p_speed_is_active:
		#print("P-SPEED")
		velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			animations.play("P_speed_anim" ,0.9)
	elif p_speed_timer.is_stopped():
		#print("time start")
		p_speed_timer.start()
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			animations.play("Run_anim" ,0.2)
	else:
		#print("RUN")
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			animations.play("Run_anim" ,0.2)


func on_push_state():
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	velocity.x = direction
	animations.play("Push_anim", 0.2)


func on_jump_state():
	velocity.y = -(JUMPFORCE + JUMPFORCE_INCREASE * int(abs(velocity.x) / 30))
	if p_speed_is_active:
		animations.play("Pjump_anim", 0.2)
	else:
		animations.play("Jump_anim", 0.1)


func on_fall_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		model_position.scale.x = -abs(model_position.scale.x)
	elif direction > 0:
		model_position.scale.x = abs(model_position.scale.x)
	
	if Input.is_action_pressed("run"):
		if p_speed_is_active:
			velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, AIR_ACCELERATION * delta)
			if velocity.y > 0:
				animations.play("Fall_anim", 0.2)
	else:
		p_speed_is_active = false
		velocity.x = move_toward(velocity.x, direction * MAX_WALK_SPEED, AIR_ACCELERATION * delta)
		if velocity.y > 0:
			animations.play("Fall_anim", 0.2)

	
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = min(velocity.y + GRAVITY_FALLING * delta, MAX_FALLSPEED)


func on_land_state():
	animations.play("Land_anim", 0)


#TODO: identische Funktionen wallslide r und l?
func on_wallslide_l_state(delta):
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = GRAVITY_WALL_SLIDING
		p_speed_timer.stop()
		p_speed_is_active = false
		animations.play("Wallslide_anim",0.2)
	velocity.x = sign(Input.get_axis("walk_left", "walk_right"))


func on_wallslide_r_state(delta):
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = GRAVITY_WALL_SLIDING
		p_speed_timer.stop()
		p_speed_is_active = false
		animations.play("Wallslide_anim",0.2)
	velocity.x = sign(Input.get_axis("walk_left", "walk_right"))


func on_walljump_l_state():
	p_speed_is_active = true
	velocity = Vector2(WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
	animations.play("Pjump_anim")


func on_walljump_r_state():
	p_speed_is_active = true
	velocity = Vector2(-WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
	animations.play("Pjump_anim")



func on_cancel_state():
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = false
	sprite_wall_tool.visible = false


func on_floortool_preview_state(delta):
	sprite_block_tool.visible = false
	sprite_wall_tool.visible = false
	velocity.x = move_toward(velocity.x, 0, 8500 * delta)
	animations.play("Preview_anim")
	left_hand.rotation = deg_to_rad(30)
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	if Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length():
		if model_position.scale.x < 0:
			if Vector2(-xAxis, -yAxis).angle() < -PI/2:
				left_arm.rotation = -(Vector2(-xAxis, -yAxis).angle() + PI) + 1
			else:
				left_arm.rotation =  PI - Vector2(-xAxis, -yAxis).angle() + 1
		else:
			left_arm.rotation = Vector2(-xAxis, -yAxis).angle() + 1
	if floor_tool_available:
		#Floor Tool Preview
		sprite_floor_tool.visible = true
		follow_floor_tool.progress_ratio = \
		determine_floortool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())


func on_blocktool_preview_state():
	sprite_floor_tool.visible = false
	sprite_wall_tool.visible = false
	if block_tool_available:
		sprite_block_tool.visible = true
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
		determine_blocktool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())


func on_wall_tool_preview_state(delta):
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = false
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	#sprite_rope/spring/field_tool.visible = false
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 8500 * delta)
		animations.play("Preview_anim")
		left_hand.rotation = deg_to_rad(30)
		if Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length():
			if model_position.scale.x < 0:
				#Mirror vectors that point up right along the y-axis (because scale.x is flipped for the model)
				if Vector2(-xAxis, -yAxis).angle() < -PI/2:
					left_arm.rotation = -(Vector2(-xAxis, -yAxis).angle() + PI) + 1
				#Mirror vectors that point down right along the y-axis (because scale.x is flipped for the model)
				else:
					left_arm.rotation =  PI - Vector2(-xAxis, -yAxis).angle() + 1
			else:
				left_arm.rotation = Vector2(-xAxis, -yAxis).angle() + 1
	if wall_tool_available:
		sprite_wall_tool.visible = true
		determine_walltool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())


func on_rope_tool_preview_state():
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = false
	sprite_wall_tool.visible = false


func on_spring_tool_preview_state():
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = false
	sprite_wall_tool.visible = false


func on_field_tool_preview_state():
	sprite_floor_tool.visible = false
	sprite_block_tool.visible = false
	sprite_wall_tool.visible = false

func on_floortool_place_state():
	if sprite_floor_tool.visible:
		sprite_floor_tool.visible = false
		get_parent().get_node("%Floor_tool").set_process_mode(PROCESS_MODE_INHERIT)
		get_parent().get_node("%Floor_tool").visible = true
		get_parent().get_node("%Floor_tool").position = sprite_floor_tool.global_position
		floor_tool_available = false


func on_blocktool_place_state():
	if sprite_block_tool.visible:
		sprite_block_tool.visible = false
		get_parent().get_node("%Block_tool").set_process_mode(PROCESS_MODE_INHERIT)
		get_parent().get_node("%Block_tool").visible = true
		get_parent().get_node("%Block_tool").position = sprite_block_tool.global_position
		block_tool_available = false


func on_wall_tool_place_state():
	if sprite_wall_tool.visible:
		sprite_wall_tool.visible = false
		get_parent().get_node("%Wall_tool").set_process_mode(PROCESS_MODE_INHERIT)
		get_parent().get_node("%Wall_tool").visible = true
		get_parent().get_node("%Wall_tool").position = sprite_wall_tool.global_position
		wall_tool_available = false


func on_rope_tool_place_state():
	pass

func on_spring_tool_place_state():
	pass

func on_field_tool_place_state():
	pass


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
	if inputstrength > Vector2(0.5,0.5).abs().length():
		return (controllerangle + PI)/(2*PI)
	else:
		return follow_floor_tool.progress_ratio


func determine_blocktool_position(inputstrength, controllerangle):
	#Control stick Deadzone
	if inputstrength > Vector2(0.5,0.5).abs().length():
		#Snap behaviour when placing below PLayer
		if controllerangle > (3*PI/8) and controllerangle < (5*PI/8):
			sprite_block_tool.position = 100 * Vector2.DOWN
		elif Input.get_axis("walk_left", "walk_right") > 0:
			#Snap behaviour when facing right
			if controllerangle > (-PI/8) and controllerangle < (PI/8):
				sprite_block_tool.position = 100 * Vector2.RIGHT
			elif controllerangle > (PI/8) and controllerangle < (3*PI/8):
				sprite_block_tool.position = 100 * Vector2.RIGHT.rotated(3*PI/8)
			else:
				sprite_block_tool.position = 100 * Vector2.RIGHT.rotated(controllerangle)
		else:
			#Snap behaviour when facing left
			if controllerangle > (7*PI/8) or controllerangle < (-7*PI/8):
				sprite_block_tool.position = 100 * Vector2.LEFT
			elif controllerangle > (5*PI/8) and controllerangle < (7*PI/8):
				sprite_block_tool.position = 100 * Vector2.RIGHT.rotated(5*PI/8)
			else:
				sprite_block_tool.position = 100 * Vector2.RIGHT.rotated(controllerangle)


func determine_walltool_position(inputstrength, controllerangle):
	#Control stick Deadzone
	if inputstrength > Vector2(0.5,0.5).abs().length():
		var x_value = 130
		var y_value
		
		#Mirrors left Stickangle to the respective right Value.
		#This way the position mapping only needs to happen within the range of -3PI/8 and +3PI/8 (right wall placement zone)
		if controllerangle < -PI/2:
			controllerangle = -(controllerangle + PI)
			x_value = -130
		elif controllerangle > PI/2:
			controllerangle =  PI - controllerangle
			x_value = -130
		
		#Snapping to lowest position
		if controllerangle > PI/4:
			y_value = 240
		#Snapping to highest position
		elif controllerangle < -PI/4:
			y_value = -240
		else:
			#Formula for mapping given highest wallpoint Newmax and lowest wallpoint Newmin:
			#Newmin + ((controllerangle - Oldmin) / (Oldmax - Oldmin)) * (Newmax - Newmin)
			y_value = -240 + ((controllerangle + 3*PI/8) / (3*PI/4)) * 480
		
		sprite_wall_tool.position = Vector2(x_value,y_value)


func _on_floor_typecheck_body_entered(_body: Node2D) -> void:
	is_on_tool = true


func _on_floor_typecheck_body_exited(_body: Node2D) -> void:
	is_on_tool = false


func _on_p_speed_timer_timeout() -> void:
	p_speed_is_active = true


func _on_deadzone_body_entered(body: Node2D) -> void:
	print("deadzone entered")
	controllable = false
	animations.play("Death_anim")
	velocity = Vector2.ZERO
	await animations.animation_finished
	position = last_spawnpoint
	animations.play_backwards("Death_anim")
	await animations.animation_finished
	controllable = true
