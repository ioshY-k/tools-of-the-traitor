extends Node
class_name Tool_state_handler


@export var floor_tool_unlocked: bool = PlayerStats.floor_tool_unlocked
@export var block_tool_unlocked: bool = PlayerStats.block_tool_unlocked
@export var wall_tool_unlocked: bool = PlayerStats.wall_tool_unlocked
@export var rope_tool_unlocked: bool = PlayerStats.rope_tool_unlocked
@export var spring_tool_unlocked: bool = PlayerStats.spring_tool_unlocked
@export var field_tool_unlocked: bool = PlayerStats.field_tool_unlocked

var current_tool_state


enum tool_states {	NO_TOOL, CANCEL,
					FLOOR_TOOL_PREVIEW, FLOOR_TOOL_PLACE,
					BLOCK_TOOL_PREVIEW, BLOCK_TOOL_PLACE,
					WALL_TOOL_PREVIEW, WALL_TOOL_PLACE,
					ROPE_TOOL_PREVIEW, ROPE_TOOL_PLACE,
					SPRING_TOOL_PREVIEW, SPRING_TOOL_PLACE,
					FIELD_TOOL_PREVIEW, FIELD_TOOL_PLACE}

func _init():
	current_tool_state = tool_states.NO_TOOL
	
func next_state(is_on_floor:bool) -> tool_states:
	#print(tool_states.keys()[current_tool_state])
	
	match current_tool_state:
		tool_states.NO_TOOL:
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
				else:
					return tool_states.NO_TOOL
			if Input.is_action_just_pressed("place_special_tool"):
				if rope_direction() and rope_tool_unlocked:
					return tool_states.ROPE_TOOL_PREVIEW
				if wall_direction() and wall_tool_unlocked:
					return tool_states.WALL_TOOL_PREVIEW
				if spring_direction() and spring_tool_unlocked:
					return tool_states.SPRING_TOOL_PREVIEW
			return tool_states.NO_TOOL
		tool_states.FLOOR_TOOL_PREVIEW:
			if Input.is_action_just_pressed("place_special_tool"):
				if rope_direction() and rope_tool_unlocked:
					return tool_states.ROPE_TOOL_PREVIEW
				if wall_direction() and wall_tool_unlocked:
					return tool_states.WALL_TOOL_PREVIEW
				if spring_direction() and spring_tool_unlocked:
					return tool_states.SPRING_TOOL_PREVIEW
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if not is_on_floor and block_tool_unlocked:
				return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.FLOOR_TOOL_PLACE
			return tool_states.FLOOR_TOOL_PREVIEW
		tool_states.BLOCK_TOOL_PREVIEW:
			if is_on_floor:
				if floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					get_node("../Sprite_block_tool").visible = false
					return tool_states.NO_TOOL
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.BLOCK_TOOL_PLACE
			if Input.is_action_just_pressed("place_special_tool"):
				if rope_direction() and rope_tool_unlocked:
					return tool_states.ROPE_TOOL_PREVIEW
				if wall_direction() and wall_tool_unlocked:
					return tool_states.WALL_TOOL_PREVIEW
				if spring_direction() and spring_tool_unlocked:
					return tool_states.SPRING_TOOL_PREVIEW
			return tool_states.BLOCK_TOOL_PREVIEW
		tool_states.WALL_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.WALL_TOOL_PLACE
			if rope_direction() and rope_tool_unlocked:
				return tool_states.ROPE_TOOL_PREVIEW
			if spring_direction() and spring_tool_unlocked:
				return tool_states.SPRING_TOOL_PREVIEW
			return tool_states.WALL_TOOL_PREVIEW
		tool_states.ROPE_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.ROPE_TOOL_PLACE
			if spring_direction() and spring_tool_unlocked:
				return tool_states.SPRING_TOOL_PREVIEW
			if wall_direction() and wall_tool_unlocked:
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.ROPE_TOOL_PREVIEW
		tool_states.SPRING_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor and floor_tool_unlocked:
					return tool_states.FLOOR_TOOL_PREVIEW
				if not is_on_floor and block_tool_unlocked:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.SPRING_TOOL_PLACE
			if rope_direction() and rope_tool_unlocked:
				return tool_states.ROPE_TOOL_PREVIEW
			if wall_direction() and wall_tool_unlocked:
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.SPRING_TOOL_PREVIEW
		tool_states.FIELD_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.CANCEL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.FIELD_TOOL_PLACE
			if rope_direction():
				return tool_states.ROPE_TOOL_PREVIEW
			if spring_direction():
				return tool_states.SPRING_TOOL_PREVIEW
			if wall_direction():
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.FIELD_TOOL_PREVIEW
		tool_states.FLOOR_TOOL_PLACE,\
		tool_states.BLOCK_TOOL_PLACE,\
		tool_states.WALL_TOOL_PLACE,\
		tool_states.ROPE_TOOL_PLACE,\
		tool_states.SPRING_TOOL_PLACE,\
		tool_states.FIELD_TOOL_PLACE,\
		tool_states.CANCEL:
			return tool_states.NO_TOOL
		_:
			print_debug("not in a valid Tool State")
			return tool_states.NO_TOOL

func rope_direction() -> bool:
	var controllerangle = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X),Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)).angle()
	return -11*PI/16 <= controllerangle and controllerangle <= -5*PI/16
	
func spring_direction() -> bool:
	var controllerangle = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X),Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)).angle()
	return 5*PI/16 <= controllerangle and controllerangle <= 11*PI/16
	
func wall_direction() -> bool:
	var controllerangle = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X),Input.get_joy_axis(0 ,JOY_AXIS_LEFT_Y)).angle()
	return abs(controllerangle) > 11*PI/16 or abs(controllerangle) < 5*PI/16
