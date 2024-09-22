class_name State_handler


enum states {IDLE, WALK, RUN, JUMP, FALL, LAND, WALLSLIDE_L, WALLSLIDE_R, WALLJUMP_L, WALLJUMP_R, PLACE_FLOOR_TOOL, PLACE_BLOCK_TOOL}
var current_state

func _init():
	current_state = states.IDLE
	
func next_state(is_on_floor, p_speed_is_active, is_on_left_wall, is_on_right_wall) -> states:
	match current_state:
		states.IDLE:
			if Input.is_action_just_pressed("jump"):
				return states.JUMP
			if Input.is_action_pressed("run") and ( \
			(Input.is_action_just_pressed("walk_left") and not is_on_left_wall) or\
			(Input.is_action_just_pressed("walk_right") and not is_on_right_wall)):
				return states.RUN
			if (Input.is_action_just_pressed("walk_left") and not is_on_left_wall) or\
			(Input.is_action_just_pressed("walk_right") and not is_on_right_wall):
				return states.WALK
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_FLOOR_TOOL
			if not is_on_floor:
				return states.FALL
			return states.IDLE
		states.WALK:
			if Input.is_action_just_pressed("jump"):
				return states.JUMP
			if Input.is_action_just_pressed("run"):
				return states.RUN
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_FLOOR_TOOL
			if not is_on_floor:
				return states.FALL
			if (not (Input.is_action_pressed("walk_left") and not Input.is_action_just_pressed("walk_right"))) or\
			((Input.is_action_pressed("walk_right") and is_on_right_wall) or (Input.is_action_pressed("walk_left") and is_on_left_wall)):
				return states.IDLE
			return states.WALK
		states.RUN:
			if (not (Input.is_action_pressed("walk_left") and not Input.is_action_just_pressed("walk_right"))) or\
			((Input.is_action_pressed("walk_right") and is_on_right_wall) or (Input.is_action_pressed("walk_left") and is_on_left_wall)):
				return states.IDLE
			if Input.is_action_just_pressed("jump"):
				return states.JUMP
			if not Input.is_action_pressed("run"):
				return states.WALK
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_FLOOR_TOOL
			if not is_on_floor:
				return states.FALL
			return states.RUN
		states.JUMP:
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			else:
				return states.FALL
			return states.JUMP
		states.FALL:
			if is_on_floor:
				if Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right"):
					if Input.is_action_pressed("run"):
						return states.RUN
					else:
						return states.WALK
				else:
					return states.IDLE
			if is_on_left_wall:
				return states.WALLSLIDE_L
			if is_on_right_wall:
				return states.WALLSLIDE_R
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			return states.FALL
		states.WALLSLIDE_L:
			if Input.is_action_just_pressed("jump"):
				return states.WALLJUMP_L
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			if not is_on_left_wall:
				return states.FALL
			return states.WALLSLIDE_L
		states.WALLSLIDE_R:
			if Input.is_action_just_pressed("jump"):
				return states.WALLJUMP_R
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			if not is_on_right_wall:
				return states.FALL
			return states.WALLSLIDE_R
		states.WALLJUMP_L:
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			else:
				return states.FALL
		states.WALLJUMP_R:
			if Input.is_action_just_pressed("place_simple_tool"):
				return states.PLACE_BLOCK_TOOL
			else:
				return states.FALL
		states.PLACE_FLOOR_TOOL:
			if not is_on_floor:
				return states.PLACE_BLOCK_TOOL
			if not Input.is_action_pressed("place_simple_tool"):
				if Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right"):
					if Input.is_action_pressed("run"):
						return states.RUN
					else:
						return states.WALK
				else:
					return states.IDLE
			return states.PLACE_FLOOR_TOOL
		states.PLACE_BLOCK_TOOL:
			if is_on_floor:
				return states.PLACE_FLOOR_TOOL
			else:
				if not Input.is_action_pressed("place_simple_tool"):
					return states.FALL
			return states.PLACE_BLOCK_TOOL
		_:
			print_debug("not in a valid State")
			return states.IDLE
