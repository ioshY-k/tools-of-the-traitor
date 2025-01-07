extends Node
class_name Tool_state_handler

@onready var cancel_timer: Timer = $Cancel_timer


var current_tool_state


enum tool_states {	NO_TOOL, CANCEL, RAD_MENU,
					FLOOR_TOOL_PREVIEW, FLOOR_TOOL_PLACE,
					BLOCK_TOOL_PREVIEW, BLOCK_TOOL_PLACE,
					RIGHT_WALL_TOOL_PREVIEW, LEFT_WALL_TOOL_PREVIEW, WALL_TOOL_PLACE,
					ROPE_TOOL_PREVIEW, ROPE_TOOL_PLACE,
					SPRING_TOOL_PREVIEW, SPRING_TOOL_PLACE }

func _init():
	current_tool_state = tool_states.NO_TOOL
	
func next_state(is_on_floor:bool) -> tool_states:
	#print(tool_states.keys()[current_tool_state])
	match current_tool_state:
		tool_states.NO_TOOL:
			if Input.is_action_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked and cancel_timer.is_stopped():
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked and cancel_timer.is_stopped():
					return tool_states.BLOCK_TOOL_PREVIEW
				else:
					return tool_states.NO_TOOL
			if Input.is_action_pressed("place_special_tool"):
				return tool_states.RAD_MENU
			return tool_states.NO_TOOL
			
		tool_states.RAD_MENU:
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.NO_TOOL
			if rope_direction() and PlayerStats.rope_tool_unlocked and cancel_timer.is_stopped():
				return tool_states.ROPE_TOOL_PREVIEW
			if right_wall_direction() and PlayerStats.wall_tool_unlocked and cancel_timer.is_stopped():
				return tool_states.RIGHT_WALL_TOOL_PREVIEW
			if left_wall_direction() and PlayerStats.wall_tool_unlocked and cancel_timer.is_stopped():
				return tool_states.LEFT_WALL_TOOL_PREVIEW
			if spring_direction() and PlayerStats.spring_tool_unlocked and cancel_timer.is_stopped():
				return tool_states.SPRING_TOOL_PREVIEW
			return tool_states.RAD_MENU
			
		tool_states.FLOOR_TOOL_PREVIEW:
			if Input.is_action_just_pressed("place_special_tool"):
				return tool_states.RAD_MENU
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if not is_on_floor:
				if PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
				else:
					return tool_states.CANCEL
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.FLOOR_TOOL_PLACE
			return tool_states.FLOOR_TOOL_PREVIEW
			
		tool_states.BLOCK_TOOL_PREVIEW:
			if is_on_floor:
				if PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					get_node("../Sprite_block_tool").visible = false
					return tool_states.NO_TOOL
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.BLOCK_TOOL_PLACE
			if Input.is_action_just_pressed("place_special_tool"):
				return tool_states.RAD_MENU
			return tool_states.BLOCK_TOOL_PREVIEW
			
		tool_states.RIGHT_WALL_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.WALL_TOOL_PLACE
			return tool_states.RIGHT_WALL_TOOL_PREVIEW
			
		tool_states.LEFT_WALL_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.WALL_TOOL_PLACE
			return tool_states.LEFT_WALL_TOOL_PREVIEW
			
		tool_states.ROPE_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.ROPE_TOOL_PLACE
			return tool_states.ROPE_TOOL_PREVIEW
			
		tool_states.SPRING_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and PlayerStats.floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and PlayerStats.block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.SPRING_TOOL_PLACE
			return tool_states.SPRING_TOOL_PREVIEW
			
		tool_states.FLOOR_TOOL_PLACE,\
		tool_states.BLOCK_TOOL_PLACE,\
		tool_states.WALL_TOOL_PLACE,\
		tool_states.ROPE_TOOL_PLACE,\
		tool_states.SPRING_TOOL_PLACE:
			return tool_states.NO_TOOL
			
		tool_states.CANCEL:
			cancel_timer.start()
			return tool_states.NO_TOOL
			
		_:
			print_debug("not in a valid Tool State")
			return tool_states.NO_TOOL

func rope_direction() -> bool:
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	var controllerangle = Vector2(xAxis,yAxis).angle()
	return -11*PI/16 <= controllerangle and controllerangle <= -5*PI/16 and Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length()
	
func spring_direction() -> bool:
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	var controllerangle = Vector2(xAxis,yAxis).angle()
	return 5*PI/16 <= controllerangle and controllerangle <= 11*PI/16 and Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length()
	
func right_wall_direction() -> bool:
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	var controllerangle = Vector2(xAxis,yAxis).angle()
	return (controllerangle > -5*PI/16 and controllerangle < 5*PI/16) and Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length()

func left_wall_direction() -> bool:
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)
	var controllerangle = Vector2(xAxis,yAxis).angle()
	return (controllerangle > 11*PI/16 or controllerangle < -11*PI/16) and Vector2(xAxis, yAxis).length() > Vector2(0.3,0.3).abs().length()
