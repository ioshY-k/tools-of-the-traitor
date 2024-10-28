@icon("RandomTimers.svg")
extends Timer
## Countdowns from random intervals between 2 given numbers. NOTE: The parent Timer's wait_time is overriden. Manual changes in the editor have no effect.

@export_range(0.001, 4096, 0.001, "or_greater","exp", "suffix:s") var min_wait_time: float = 1.0 ##Start of wait time range. (Will work as long as it is a different number from max_wait_time)
@export_range(0.001, 4096, 0.001, "or_greater","exp", "suffix:s") var max_wait_time: float = 2.0 ##End of wait time range. 
@export var is_initially_random := true ##If set to FALSE the first signal of the timer will use Timer's parent wait_time (can be set in editor), otherwise it will use a value taken from the given range from the very first start, including autostart.

func _ready() -> void:	
	timeout.connect(_on_timeout)
	_handle_initial_randomness()

## So that it works with autostart on Timer.gd and so that calling start() for the first time, on non-autostart timers, yields the desidered is_initially_random, or non- is_initially_random result.
func _handle_initial_randomness():
	if autostart && is_initially_random:
		## Initial wait_time on autostart node is random within range.
		start(_get_value_within_range()) 
	elif is_initially_random:
		 ## Makes the initial wait_time when calling start() (without parameters) for the first time, random within range.
		wait_time = _get_value_within_range()

func _on_timeout() -> void:
	if !one_shot:
		## Required to dodge a bug that will emerge where the first 2 values will always be the same. 
		start(_get_value_within_range())
	else:
		## So that calling start() (without parameters) useas a new random time, instead of repeating last wait_time. 
		## Calling start(with_some_value) with a value works sames as regular Timer
		wait_time = _get_value_within_range()

func _get_value_within_range():
	return randf_range(min_wait_time, max_wait_time)

## Always uses a new random wait_time, contrary to were just using start() will use the last set wait_time. 
## Only needed to be 100% sure to get a random ranged value, in cases where wait_time might had been set externally.
func start_random():
	start(_get_value_within_range())
