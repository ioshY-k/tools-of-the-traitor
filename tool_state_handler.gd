extends Node
class_name Tool_state_handler

var current_tool_state


enum tool_states {	NO_TOOL,
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
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if Input.is_action_just_pressed("place_special_tool"):
				if Input.is_action_pressed("stick_up"):
					return tool_states.ROPE_TOOL_PREVIEW
				if Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left"):
					return tool_states.WALL_TOOL_PREVIEW
				if Input.is_action_pressed("stick_down"):
					return tool_states.SPRING_TOOL_PREVIEW
				return tool_states.FIELD_TOOL_PREVIEW
			return tool_states.NO_TOOL
		tool_states.FLOOR_TOOL_PREVIEW:
			if Input.is_action_just_pressed("place_special_tool"):
				if Input.is_action_pressed("stick_up"):
					return tool_states.ROPE_TOOL_PREVIEW
				if Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left"):
					return tool_states.WALL_TOOL_PREVIEW
				if Input.is_action_pressed("stick_down"):
					return tool_states.SPRING_TOOL_PREVIEW
				return tool_states.FIELD_TOOL_PREVIEW
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if not is_on_floor:
				return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.FLOOR_TOOL_PLACE
			return tool_states.FLOOR_TOOL_PREVIEW
		tool_states.BLOCK_TOOL_PREVIEW:
			if is_on_floor:
				return tool_states.FLOOR_TOOL_PREVIEW
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if not Input.is_action_pressed("place_simple_tool"):
				return tool_states.BLOCK_TOOL_PLACE
			if Input.is_action_just_pressed("place_special_tool"):
				if Input.is_action_pressed("stick_up"):
					return tool_states.ROPE_TOOL_PREVIEW
				if Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left"):
					return tool_states.WALL_TOOL_PREVIEW
				if Input.is_action_pressed("stick_down"):
					return tool_states.SPRING_TOOL_PREVIEW
				return tool_states.FIELD_TOOL_PREVIEW
			return tool_states.BLOCK_TOOL_PREVIEW
		tool_states.WALL_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.WALL_TOOL_PLACE
			if Input.is_action_pressed("stick_up"):
				return tool_states.ROPE_TOOL_PREVIEW
			if Input.is_action_pressed("stick_down"):
				return tool_states.SPRING_TOOL_PREVIEW
			if not (Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left")):
				return tool_states.FIELD_TOOL_PREVIEW
			return tool_states.WALL_TOOL_PREVIEW
		tool_states.ROPE_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.ROPE_TOOL_PLACE
			if not Input.is_action_pressed("stick_up"):
				return tool_states.FIELD_TOOL_PREVIEW
			if Input.is_action_pressed("stick_down"):
				return tool_states.SPRING_TOOL_PREVIEW
			if (Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left")):
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.ROPE_TOOL_PREVIEW
		tool_states.SPRING_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.SPRING_TOOL_PLACE
			if Input.is_action_pressed("stick_up"):
				return tool_states.ROPE_TOOL_PREVIEW
			if not Input.is_action_pressed("stick_down"):
				return tool_states.FIELD_TOOL_PREVIEW
			if (Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left")):
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.SPRING_TOOL_PREVIEW
		tool_states.FIELD_TOOL_PREVIEW:
			if Input.is_action_just_pressed("cancel_tool"):
				return tool_states.NO_TOOL
			if Input.is_action_just_pressed("place_simple_tool"):
				if is_on_floor:
					return tool_states.FLOOR_TOOL_PREVIEW
				else:
					return tool_states.BLOCK_TOOL_PREVIEW
			if not Input.is_action_pressed("place_special_tool"):
				return tool_states.FIELD_TOOL_PLACE
			if Input.is_action_pressed("stick_up"):
				return tool_states.ROPE_TOOL_PREVIEW
			if Input.is_action_pressed("stick_down"):
				return tool_states.SPRING_TOOL_PREVIEW
			if (Input.is_action_pressed("stick_right") or Input.is_action_pressed("stick_left")):
				return tool_states.WALL_TOOL_PREVIEW
			return tool_states.FIELD_TOOL_PREVIEW
		tool_states.FLOOR_TOOL_PLACE,\
		tool_states.BLOCK_TOOL_PLACE,\
		tool_states.WALL_TOOL_PLACE,\
		tool_states.ROPE_TOOL_PLACE,\
		tool_states.SPRING_TOOL_PLACE,\
		tool_states.FIELD_TOOL_PLACE:
			return tool_states.NO_TOOL
		_:
			print_debug("not in a valid Tool State")
			return tool_states.NO_TOOL
