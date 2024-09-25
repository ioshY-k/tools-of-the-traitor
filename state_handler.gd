extends Node
class_name State_handler

var current_state
@onready var coyote_timer: Timer = $Coyote
@onready var jump_buffer_timer: Timer = $Jump_buffer


enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R}

func _init():
	current_state = states.IDLE
	
func next_state(is_on_floor:bool, is_on_left_wall:bool, is_on_right_wall:bool) -> states:
	match current_state:
		states.IDLE:
			if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0:
				return states.JUMP
			if Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right"):
				if Input.is_action_pressed("run"):
					return states.RUN
				else:
					return states.WALK
			if not is_on_floor:
				coyote_timer.start()
				return states.FALL
			return states.IDLE
		states.WALK:
			if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0:
				return states.JUMP
			if Input.is_action_just_pressed("run"):
				return states.RUN
			if not is_on_floor:
				coyote_timer.start()
				return states.FALL
			if (not Input.is_action_pressed("walk_left") and not Input.is_action_pressed("walk_right")):
				return states.IDLE
			if (Input.is_action_pressed("walk_right") and is_on_right_wall) or (Input.is_action_pressed("walk_left") and is_on_left_wall):
				return states.PUSH
			return states.WALK
		states.RUN:
			if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0:
				return states.JUMP
			if not Input.is_action_pressed("run"):
				return states.WALK
			if not is_on_floor:
				coyote_timer.start()
				return states.FALL
			if (not Input.is_action_pressed("walk_left") and not Input.is_action_pressed("walk_right")):
				return states.IDLE
			if (Input.is_action_pressed("walk_right") and is_on_right_wall) or (Input.is_action_pressed("walk_left") and is_on_left_wall):
				return states.PUSH
			return states.RUN
		states.PUSH:
			if not (is_on_left_wall or is_on_right_wall):
				if Input.is_action_pressed("run"):
					return states.RUN
				else:
					return states.WALK
			if Input.is_action_just_pressed("jump"):
				return states.JUMP
			if not is_on_floor:
				coyote_timer.start()
				return states.FALL
			if (not Input.is_action_pressed("walk_left") and not Input.is_action_pressed("walk_right")):
				return states.IDLE
			return states.PUSH
		states.JUMP:
			return states.FALL
		states.FALL:
			if Input.is_action_just_pressed("jump"):
				if coyote_timer.time_left > 0:
					return states.JUMP
				else:
					jump_buffer_timer.start()
			if is_on_floor:
				return states.LAND
			if is_on_left_wall and Input.is_action_pressed("walk_left"):
				return states.WALLSLIDE_L
			if is_on_right_wall and Input.is_action_pressed("walk_right"):
				return states.WALLSLIDE_R
			return states.FALL
		states.LAND:
			if Input.is_action_pressed("walk_left") or Input.is_action_pressed("walk_right"):
				if Input.is_action_pressed("run"):
					return states.RUN
				else:
					return states.WALK
			else:
				return states.IDLE
		states.WALLSLIDE_L:
			if Input.is_action_just_pressed("jump"):
				return states.WALLJUMP_L
			if is_on_floor:
				return states.IDLE
			if not is_on_left_wall:
				return states.FALL
			return states.WALLSLIDE_L
		states.WALLSLIDE_R:
			if Input.is_action_just_pressed("jump"):
				return states.WALLJUMP_R
			if is_on_floor:
				return states.IDLE
			if not is_on_right_wall:
				return states.FALL
			return states.WALLSLIDE_R
		states.WALLJUMP_L:
			return states.FALL
		states.WALLJUMP_R:
			return states.FALL
		_:
			print_debug("not in a valid State")
			return states.IDLE
