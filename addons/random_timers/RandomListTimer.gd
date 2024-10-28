@icon("RandomListTimers.svg")
##Chooses a random timeout out of multiple values on a list.
extends Timer

@export var should_cycle_through_values := false ## If TRUE, the array will cycle through all indexes before any index can be repeated.
@export var wait_times_arr: Array = [1.0, 2.0, 3.0] ## An array of possible wait times to be chosen randomly.

var used_values: Array = [] ##Used for cycling through entire array before repeating values.

func _ready() -> void:
	timeout.connect(_on_timeout)
	if autostart:
		_set_random_wait_time()

func _on_timeout() -> void:
	_set_random_wait_time()

func _set_random_wait_time():
	if wait_times_arr.is_empty():
		if should_cycle_through_values and !used_values.is_empty():
			# Refill the wait_times_arr from used_values and clear used_values
			wait_times_arr = used_values.duplicate()
			used_values.clear()
			_pick_random_value()
		else:
			push_error("wait_times_arr is empty. Please populate it with at least one float value.")
	else:
		_pick_random_value()

func _pick_random_value():
	var index = randi_range(0, wait_times_arr.size()-1)
	wait_time = wait_times_arr[index]
	if should_cycle_through_values:
		used_values.append(wait_times_arr[index])
		wait_times_arr.remove_at(index)

	#Without this, the timer always repeats the first value once when in autostart.
	if !one_shot:
		start()
