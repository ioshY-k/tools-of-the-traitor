extends CharacterBody2D

#Movement variables
const ACCELERATION = 3300 #How fast Player reaches run speed
const DECELERATION = 6500 #How long until Player stops after moving
const AIR_ACCELERATION = 4250
const GRAVITY_RISING = 4250 #How fast Player falls with holding jump
const GRAVITY_FALLING = 3800 * 2.5 #How much stronger  gravity pulls in falling state vs. rising state
const MAX_FALLSPEED = 700 * 2.5 #The point where gravity doesn't accelerate fallspeed enymore
const JUMPFORCE = 1600 #How high Player gets send when jumping
const JUMPFORCE_INCREASE = 5 #How much runspeed influences jump height
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
@onready var rocket_animations: AnimationPlayer = player_cutout.get_node("Player_hip/Player_torso/Rocket_AnimationPlayer")
@onready var model_position: Node2D = $Model_position
@onready var left_arm: Sprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_leftarm")
@onready var left_hand: Sprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_leftarm/Player_lefthand")
@onready var eyes: AnimatedSprite2D = player_cutout.get_node("Player_hip/Player_torso/Player_head/Player_eyes")
@onready var blink_timer: Timer = $Blink_timer

#Tool placement
var floor_tool_freezeframes : bool = false
var original_floor_tool_scale = Vector2(0.752,1.148)
@onready var sprite_floor_tool: Sprite2D = $Sprite_floor_tool
@onready var sprite_block_tool: Sprite2D = $Sprite_block_tool
@onready var sprite_wall_tool: Sprite2D = $Sprite_wall_tool
@onready var sprite_spring_tool: Sprite2D = $Sprite_spring_tool
@onready var sprite_rope_tool = $Sprite_spring_tool #vorübergehend
@onready var follow_floor_tool: PathFollow2D = %Follow_floor_tool
@onready var path_floor_tool: Path2D = $Path_floor_tool
@onready var rad_menu: Node2D = $Rad_menu
@onready var rad_menu_anim: AnimationPlayer = $Rad_menu/Rad_menu_Animations
@onready var bubble_up: AnimatedSprite2D = $Rad_menu/Bubble_up
@onready var bubble_right: AnimatedSprite2D = $Rad_menu/Bubble_right
@onready var bubble_bottom: AnimatedSprite2D = $Rad_menu/Bubble_bottom
@onready var bubble_left: AnimatedSprite2D = $Rad_menu/Bubble_left


@onready var tool_previews = [sprite_floor_tool, sprite_block_tool, sprite_wall_tool, sprite_spring_tool, sprite_rope_tool]

var is_on_tool: bool
var is_on_spring_tool: bool # To prevent the launch variable from changing back right after launching. This caused middle high jumps from Spring tool
var floor_tool_available: bool = true
var block_tool_available: bool = true
var wall_tool_available: bool = true
var rope_tool_available: bool = true
var spring_tool_available: bool = true
var floor_overlapping: bool = false
var block_tool_distance = 120
var tool_offset_x = 10
var last_placed_tools = Array()
var disable_callback = false # To prevent calling back a tool with the cancel button when it was just used to cancel preview
@onready var supercancel_timer: Timer = $Supercancel_timer

#Other
var launched: bool = false
var controllable: bool = true
@onready var last_spawnpoint = position

#State handler
@onready var state_handler = $State_handler
var current_state
enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
	WALLSLIDE_L, WALLSLIDE_R,
	WALLJUMP_L, WALLJUMP_R,
	SWING}
@onready var tool_state_handler = $Tool_state_handler
var current_tool_state
enum tool_states {	NO_TOOL, CANCEL, RAD_MENU,
	FLOOR_TOOL_PREVIEW, FLOOR_TOOL_PLACE,
	BLOCK_TOOL_PREVIEW, BLOCK_TOOL_PLACE,
	RIGHT_WALL_TOOL_PREVIEW, LEFT_WALL_TOOL_PREVIEW, WALL_TOOL_PLACE,
	ROPE_TOOL_PREVIEW, ROPE_TOOL_PLACE,
	SPRING_TOOL_PREVIEW, SPRING_TOOL_PLACE}


func _ready() -> void:
	#important since queue cant specify blendtimes
	animations.set_blend_time("Land_anim","Idle_anim",0.3)
	animations.set_blend_time("Land_anim","Walk_anim",0.3)
	animations.set_blend_time("Land_anim","Run_anim",0.3)
	animations.set_blend_time("Land_anim","P_speed_anim",0.3)
	animations.set_blend_time("Jump_anim", "Fall_anim", 0.3)
	blink_timer.timeout.connect(func(): if not eyes.is_playing(): eyes.play("blink_anim"))
	supercancel_timer.timeout.connect(func():
		for toolnum in range(len(last_placed_tools)):
			callback_tool(last_placed_tools.pop_back())
			await get_tree().create_timer(0.05).timeout
		)
	PlayerStats.execute_all_options()
	position = Vector2(PlayerStats.xPosition, PlayerStats.yPosition)
	last_spawnpoint = position


func _physics_process(delta: float) -> void:
	sliding_on_left_wall = is_on_wall() and (caster_left_wall.is_colliding() or caster_left_wall_2.is_colliding())
	sliding_on_right_wall = is_on_wall() and (caster_right_wall.is_colliding() or caster_right_wall_2.is_colliding())
	current_state = state_handler.next_state(is_on_floor(), sliding_on_left_wall, sliding_on_right_wall)
	state_handler.set("current_state", current_state)
	current_tool_state = tool_state_handler.next_state(is_on_floor())
	tool_state_handler.set("current_tool_state", current_tool_state)
	check_supercancel()
	
	if controllable:
		
		if p_speed_is_active:
			rocket_animations.play("Rocket_on")
		else:
			rocket_animations.play("Rocket_off")
		
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
				on_wallslide_state(delta, true)
			states.WALLSLIDE_R:
				on_wallslide_state(delta, false)
			states.WALLJUMP_L:
				on_walljump_state(1)
			states.WALLJUMP_R:
				on_walljump_state(-1)

		match current_tool_state:
			tool_states.NO_TOOL:
				on_no_tool_state()
			tool_states.CANCEL:
				on_cancel_state()
			tool_states.RAD_MENU:
				on_rad_menu_state()
			tool_states.FLOOR_TOOL_PREVIEW:
				on_floortool_preview_state(delta)
			tool_states.FLOOR_TOOL_PLACE:
				on_floortool_place_state()
			tool_states.BLOCK_TOOL_PREVIEW:
				on_blocktool_preview_state()
			tool_states.BLOCK_TOOL_PLACE:
				on_blocktool_place_state()
			tool_states.RIGHT_WALL_TOOL_PREVIEW:
				on_right_wall_tool_preview_state()
			tool_states.LEFT_WALL_TOOL_PREVIEW:
				on_left_wall_tool_preview_state()
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
	
	move_and_slide() #Player movement


func check_supercancel():
	if Input.is_action_just_released("cancel_tool") and is_on_floor() and not disable_callback:
		callback_tool(last_placed_tools.pop_back())
	elif Input.is_action_just_released("cancel_tool"):
		disable_callback = false
	if is_on_floor() and Input.is_action_just_pressed("cancel_tool"):
		supercancel_timer.start()
		eyes.play("supercancel_anim")
	if not supercancel_timer.is_stopped() and not Input.is_action_pressed("cancel_tool"):
		supercancel_timer.stop()
		eyes.stop()


func callback_tool(tool: Node):
	if tool == null:
		return
	tool.set_process_mode(PROCESS_MODE_DISABLED)
	tool.visible = false
	match tool.name:
		"Floor_tool":
			floor_tool_available = true
		"Block_tool":
			block_tool_available = true
		"Wall_tool":
			wall_tool_available = true
		"Spring_tool":
			spring_tool_available = true


func on_idle_state(delta):
	velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	p_speed_timer.stop()
	p_speed_is_active = false
	if current_tool_state == tool_states.NO_TOOL:
		if animations.current_animation == "Land_anim":
			animations.queue("Idle_anim")
		else:
			animations.play("Idle_anim" ,0.3)
	eyes_blinking()


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
		if animations.current_animation == "Land_anim":
			animations.queue("Walk_anim")
		else:
			animations.play("Walk_anim" ,0.3)
	eyes_blinking()


func on_run_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		model_position.scale.x = -abs(model_position.scale.x)
	elif direction > 0:
		model_position.scale.x = abs(model_position.scale.x)
		
	if p_speed_is_active:
		velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			if animations.current_animation == "Land_anim":
				animations.queue("P_speed_anim")
			else:
				animations.play("P_speed_anim" , 0.3)
	elif p_speed_timer.is_stopped():
		p_speed_timer.start()
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			if animations.current_animation == "Land_anim":
				animations.queue("Run_anim")
			else:
				animations.play("Run_anim" ,0.3)
	else:
		velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, ACCELERATION * delta)
		if current_tool_state == tool_states.NO_TOOL:
			if animations.current_animation == "Land_anim":
				animations.queue("Run_anim")
			else:
				animations.play("Run_anim" ,0.3)


func on_push_state():
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	velocity.x = direction
	animations.play("Push_anim", 0.2)


func on_jump_state():
	if not launched:
		velocity.y = -(JUMPFORCE + JUMPFORCE_INCREASE * int(abs(velocity.x) / 30))
		if p_speed_is_active:
			animations.play("Pjump_anim", 0.3)
		else:
			animations.play("Jump_anim", 0.1)


func on_fall_state(delta):
	var direction = sign(Input.get_axis("walk_left", "walk_right"))
	if direction < 0:
		model_position.scale.x = -abs(model_position.scale.x)
	elif direction > 0:
		model_position.scale.x = abs(model_position.scale.x)
	
	if state_handler.sprints():
		if p_speed_is_active:
			velocity.x = move_toward(velocity.x, direction * MAX_P_SPEED, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * MAX_RUN_SPEED, AIR_ACCELERATION * delta)
			if velocity.y > 0:
				animations.play("Fall_anim", 0.3)
	else:
		p_speed_is_active = false
		velocity.x = move_toward(velocity.x, direction * MAX_WALK_SPEED, AIR_ACCELERATION * delta)
		if velocity.y > 0:
			animations.play("Fall_anim", 0.2)
	
	
	if velocity.y <= 0 and (Input.is_action_pressed("jump") or launched):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumrelease and while descending
		velocity.y = min(velocity.y + GRAVITY_FALLING * delta, MAX_FALLSPEED)
	eyes_blinking()


func on_land_state():
	animations.play("Land_anim", 0)
	if launched and not is_on_spring_tool:
		launched = false


func on_wallslide_state(delta, left: bool):
	if velocity.y <= 0 and Input.is_action_pressed("jump"):
		#Rising while holding jump
		velocity.y = min(velocity.y + GRAVITY_RISING * delta, MAX_FALLSPEED)
		_ledge_corrections()
	else:
		#higher gravity on jumprelease and while descending
		velocity.y = GRAVITY_WALL_SLIDING
		p_speed_timer.stop()
		p_speed_is_active = false
		animations.play("Wallslide_anim",0.2)
		if left and sliding_on_left_wall:
			velocity.x = -1
		elif not left and sliding_on_right_wall:
			velocity.x = 1
	if current_tool_state == tool_states.NO_TOOL and Input.is_action_pressed("walk_right"):
		velocity.x = 1
	elif current_tool_state == tool_states.NO_TOOL and Input.is_action_pressed("walk_left"):
		velocity.x = -1
	eyes_blinking()


func on_walljump_state(left: int):
	p_speed_is_active = true
	velocity = Vector2(left * WALL_JUMP_WIDTH, -WALL_JUMP_HEIGHT)
	animations.play("Pjump_anim")
	if launched:
		launched = false


func on_no_tool_state():
	if rad_menu.visible:
		if rad_menu_anim.is_playing():
			await(rad_menu_anim.animation_finished)
		if not current_tool_state == tool_states.RAD_MENU:
			rad_menu_anim.play_backwards("appear_anim")
			await(rad_menu_anim.animation_finished)
			rad_menu.visible = false
	set_bullet_time(false)


func on_rad_menu_state():
	if not rad_menu.visible:
		
		if PlayerStats.wall_tool_unlocked:
			bubble_left.frame = 1
			bubble_right.frame = 1
		else:
			bubble_left.frame = 0
			bubble_right.frame = 0
		if PlayerStats.spring_tool_unlocked:
			bubble_bottom.frame = 1
		else:
			bubble_bottom.frame = 0
		if PlayerStats.rope_tool_unlocked:
			bubble_up.frame = 1
		else:
			bubble_up.frame = 0
		
		rad_menu.visible = true
		rad_menu_anim.play("appear_anim")


func on_cancel_state():
	print("cancel")
	set_tool_visibilities(null, false)
	while Engine.time_scale != 1:
		set_bullet_time(false)
		await get_tree().create_timer(0.5/Engine.get_frames_per_second()).timeout
	disable_callback = true
	


func on_floortool_preview_state(delta):
	set_bullet_time(false)
	set_tool_visibilities(sprite_floor_tool, false)
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
		determine_floortool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle(), delta)


func on_blocktool_preview_state():
	set_tool_visibilities(sprite_block_tool, false)
	if block_tool_available:
		sprite_block_tool.visible = true
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
		determine_blocktool_position(Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())
		set_bullet_time(true)


func on_right_wall_tool_preview_state():
	set_tool_visibilities(sprite_wall_tool,true)
	if wall_tool_available:
		sprite_wall_tool.visible = true
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
		determine_walltool_position(true,Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())
		set_bullet_time(true)
		
func on_left_wall_tool_preview_state():
	set_tool_visibilities(sprite_wall_tool,false)
	if wall_tool_available:
		sprite_wall_tool.visible = true
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
		determine_walltool_position(false,Vector2(xAxis, yAxis).length(), Vector2(xAxis, yAxis).angle())
		set_bullet_time(true)


func on_rope_tool_preview_state():
	set_tool_visibilities(sprite_rope_tool, false)


func on_spring_tool_preview_state():
	set_tool_visibilities(sprite_spring_tool, false)
	determine_springtool_position()
	if spring_tool_available:
		sprite_spring_tool.visible = true
		set_bullet_time(true)

func set_tool_visibilities(current_tool, is_right):
		
	for tool_preview in tool_previews:
		if current_tool != tool_preview:
			tool_preview.visible = false
			
	match current_tool:
		sprite_wall_tool:
			if is_right:
				rad_menu_anim.play("select_right_anim")
				await(rad_menu_anim.animation_finished)
			else:
				rad_menu_anim.play("select_left_anim")
				await(rad_menu_anim.animation_finished)
		sprite_spring_tool:
			rad_menu_anim.play("select_bottom_anim")
			await(rad_menu_anim.animation_finished)
		sprite_rope_tool:
			rad_menu_anim.play("select_up_anim")
			await(rad_menu_anim.animation_finished)
	
	if not current_tool_state == tool_states.RAD_MENU:
		rad_menu.visible = false

func on_floortool_place_state():
	if sprite_floor_tool.visible:
		sprite_floor_tool.visible = false
		if not floor_overlapping:
			var floor_tool = get_parent().get_node("%Floor_tool")
			floor_tool.set_process_mode(PROCESS_MODE_INHERIT)
			floor_tool.visible = true
			floor_tool.position = sprite_floor_tool.global_position
			floortool_place_animation(floor_tool)
			
			floor_tool_freezeframes = true
			Engine.time_scale = 0.05
			await get_tree().create_timer(0.031).timeout
			floor_tool_freezeframes = false
			Engine.time_scale = 1
			
			floor_tool_available = false
			last_placed_tools.push_back(get_parent().get_node("%Floor_tool"))
			PlayerStats.tool_count += 1

func floortool_place_animation(floor_tool: StaticBody2D):
	
	floor_tool.get_child(3).rotation = -PI/2
	floor_tool.get_child(3).scale = Vector2(1.64,1.5)
	floor_tool.get_child(1).position.x = -60
	floor_tool.get_child(2).position.x = 60
	
	get_tree().create_tween() \
		.tween_property(floor_tool.get_child(3), "rotation", 0, 0.027) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	get_tree().create_tween() \
		.tween_property(floor_tool.get_child(3), "scale", Vector2(1.28,1), 0.027) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	get_tree().create_tween() \
		.tween_property(floor_tool.get_child(1), "position:x", 0, 0.027) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	get_tree().create_tween() \
		.tween_property(floor_tool.get_child(2), "position:x", 0, 0.027) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)


func on_blocktool_place_state():
	if sprite_block_tool.visible:
		sprite_block_tool.visible = false
		var block_tool = get_parent().get_node("%Block_tool")
		block_tool.set_process_mode(PROCESS_MODE_INHERIT)
		block_tool.visible = true
		block_tool.position = sprite_block_tool.global_position
		blocktool_place_animation(block_tool)
		block_tool_available = false
		last_placed_tools.push_back(get_parent().get_node("%Block_tool"))
		PlayerStats.tool_count += 1
		while Engine.time_scale != 1:
			set_bullet_time(false)
			await get_tree().create_timer(0.5/Engine.get_frames_per_second()).timeout
			
func blocktool_place_animation(block_tool):
	block_tool.get_child(3).scale = Vector2(0.38,0.38)
	block_tool.get_child(2).scale = Vector2(0.2,0.2)
	
	get_tree().create_tween() \
		.tween_property(block_tool.get_child(3), "scale", Vector2(0.69,0.69), 0.4) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_IN)
	get_tree().create_tween() \
		.tween_property(block_tool.get_child(2), "scale", Vector2(0.69,0.69), 0.4) \
		.set_trans(Tween.TRANS_SPRING) \
		.set_ease(Tween.EASE_OUT)


func on_wall_tool_place_state():
	if sprite_wall_tool.visible:
		sprite_wall_tool.visible = false
		var wall_tool = get_parent().get_node("%Wall_tool")
		wall_tool.set_process_mode(PROCESS_MODE_INHERIT)
		wall_tool.visible = true
		wall_tool.position = sprite_wall_tool.global_position
		walltool_place_animation(wall_tool)
		wall_tool_available = false
		last_placed_tools.push_back(get_parent().get_node("%Wall_tool"))
		PlayerStats.tool_count += 1
		while Engine.time_scale != 1:
			set_bullet_time(false)
			await get_tree().create_timer(0.5/Engine.get_frames_per_second()).timeout
			
func walltool_place_animation(wall_tool):
	wall_tool.get_child(2).scale = Vector2(0.711,0.27)
	wall_tool.get_child(0).rotation = -PI/2
	wall_tool.get_child(1).rotation = PI/2
		
	get_tree().create_tween() \
		.tween_property(wall_tool.get_child(2), "scale", Vector2(0.331,0.51), 0.4) \
		.set_trans(Tween.TRANS_SPRING) \
		.set_ease(Tween.EASE_OUT)
	get_tree().create_tween() \
		.tween_property(wall_tool.get_child(0), "rotation", 0, 0.4) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	get_tree().create_tween() \
		.tween_property(wall_tool.get_child(1), "rotation", 0, 0.4) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)


func on_rope_tool_place_state():
	pass


func on_spring_tool_place_state():
	if sprite_spring_tool.visible:
		sprite_spring_tool.visible = false
		var spring_tool = get_parent().get_node("%Spring_tool")
		spring_tool.set_process_mode(PROCESS_MODE_INHERIT)
		spring_tool.visible = true
		spring_tool.position = sprite_spring_tool.global_position
		spring_tool.bounce_animation()
		spring_tool_available = false
		last_placed_tools.push_back(get_parent().get_node("%Spring_tool"))
		PlayerStats.tool_count += 1
		while Engine.time_scale != 1:
			set_bullet_time(false)
			await get_tree().create_timer(0.5/Engine.get_frames_per_second()).timeout


func _ledge_corrections():
	if caster_inner_left_ceiling.is_colliding() or caster_inner_right_ceiling.is_colliding():
		caster_outer_left_ceiling.enabled = false
		caster_outer_right_ceiling.enabled = false
	else:
		caster_outer_left_ceiling.enabled = true
		caster_outer_right_ceiling.enabled = true
	while caster_outer_left_ceiling.is_colliding():
		print_debug("teleporting")
		global_position += Vector2(20,0)
		caster_outer_left_ceiling.force_raycast_update()
	while caster_outer_right_ceiling.is_colliding():
		print_debug("teleporting")
		global_position += Vector2(-20,0)
		caster_outer_right_ceiling.force_raycast_update()

func determine_floortool_position(inputstrength, controllerangle, delta):
	#Control stick Deadzone

	if inputstrength >= 0.91:
		path_floor_tool.scale.x = 1
		path_floor_tool.scale.y = 1
		follow_floor_tool.progress_ratio = (controllerangle + PI)/(2*PI)
		sprite_floor_tool.position = to_local(follow_floor_tool.global_position)
	else:
		path_floor_tool.scale.x = inputstrength
		path_floor_tool.scale.y = inputstrength
		follow_floor_tool.progress_ratio = (controllerangle + PI)/(2*PI)
		sprite_floor_tool.position = sprite_floor_tool.position.lerp(to_local(follow_floor_tool.global_position),7 * delta)


func determine_blocktool_position(inputstrength, controllerangle):
	#Control stick Deadzone
	if inputstrength > Vector2(0.65,0.65).abs().length():
		#Snap behaviour when placing below PLayer
		if controllerangle > (3*PI/8) and controllerangle < (5*PI/8):
			sprite_block_tool.position = block_tool_distance * Vector2.DOWN
		elif Input.get_axis("walk_left", "walk_right") > 0:
			#Snap behaviour when facing right
			if controllerangle > (-PI/8) and controllerangle < (PI/8):
				sprite_block_tool.position = block_tool_distance * Vector2.RIGHT
			elif controllerangle > (PI/8) and controllerangle < (3*PI/8):
				sprite_block_tool.position = block_tool_distance * Vector2.RIGHT.rotated(3*PI/8)
			else:
				sprite_block_tool.position = (block_tool_distance+30) * Vector2.RIGHT.rotated(controllerangle)
		else:
			#Snap behaviour when facing left
			if controllerangle > (7*PI/8) or controllerangle < (-7*PI/8):
				sprite_block_tool.position = block_tool_distance * Vector2.LEFT
			elif controllerangle > (5*PI/8) and controllerangle < (7*PI/8):
				sprite_block_tool.position = block_tool_distance * Vector2.RIGHT.rotated(5*PI/8)
			else:
				sprite_block_tool.position = (block_tool_distance+30) * Vector2.RIGHT.rotated(controllerangle)
	else:
		sprite_block_tool.position = block_tool_distance * Vector2.DOWN  + Vector2.RIGHT * 10


func determine_walltool_position(right_side: bool, inputstrength, controllerangle):
	sprite_wall_tool.position = Vector2(sign(model_position.scale.x) * 150 + tool_offset_x, +75)
	

func determine_springtool_position():
	if is_on_floor():
		sprite_spring_tool.position = Vector2(sign(model_position.scale.x) * 180 + tool_offset_x, 3)
	else:
		sprite_spring_tool.position = Vector2.DOWN * 150 + Vector2.RIGHT * tool_offset_x


func eyes_blinking():
	if blink_timer.is_stopped():
		blink_timer.start()

func set_bullet_time(state):
	if state and not is_on_floor():
		Engine.time_scale = move_toward(Engine.time_scale, PlayerStats.bullet_time_value, 0.05)
	elif not floor_tool_freezeframes:
		Engine.time_scale = move_toward(Engine.time_scale, 1, 0.05)


func _on_floor_typecheck_body_entered(body: Node2D) -> void:
	if body.name == "Spring_tool":
		is_on_spring_tool = true
	is_on_tool = true


func _on_floor_typecheck_body_exited(body: Node2D) -> void:
	if body.name == "Spring_tool":
		is_on_spring_tool = false
	is_on_tool = false


func _on_p_speed_timer_timeout() -> void:
	p_speed_is_active = true


func _on_hurtbox_body_entered(_body: Node2D) -> void:
	kill_player()

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	kill_player()
	
func kill_player():
	if PlayerStats.cursed_mode:
		$"../Cursed_Orb".player_got_hit()
	controllable = false
	if sprite_floor_tool.visible:
		sprite_floor_tool.visible = false
	if sprite_block_tool.visible:
		sprite_block_tool.visible = false
	if sprite_wall_tool.visible:
		sprite_wall_tool.visible = false
	if sprite_spring_tool.visible:
		sprite_spring_tool.visible = false
	PlayerStats.death_count += 1
	animations.play("Death_anim")
	velocity = Vector2.ZERO
	while Engine.time_scale != 1:
		set_bullet_time(false)
		await get_tree().create_timer(0.5/Engine.get_frames_per_second()).timeout
	await animations.animation_finished
	position = last_spawnpoint
	supercancel_timer.timeout.emit()
	animations.play_backwards("Death_anim")
	await animations.animation_finished
	controllable = true

func _on_ally1_body_entered(_body: Node2D) -> void:
	PlayerStats.floor_tool_unlocked = true
	get_parent().get_node("%Ally1_collect").queue_free()
	


func _on_ally2_body_entered(_body: Node2D) -> void:
	PlayerStats.block_tool_unlocked = true
	get_parent().get_node("%Ally2_collect").queue_free()


func _on_ally3_body_entered(_body: Node2D) -> void:
	PlayerStats.wall_tool_unlocked = true
	get_parent().get_node("%Ally3_collect").queue_free()


func _on_ally4_body_entered(_body: Node2D) -> void:
	PlayerStats.spring_tool_unlocked = true
	get_parent().get_node("%Ally4_collect").queue_free()


func _on_overlap_check_body_entered(_body: Node2D) -> void:
	sprite_floor_tool.modulate = Color(0.553, 0.286, 0.549, 0.349)
	floor_overlapping = true


func _on_overlap_check_body_exited(_body: Node2D) -> void:
	sprite_floor_tool.modulate = Color(0.988, 1, 1, 0.349)
	floor_overlapping = false
