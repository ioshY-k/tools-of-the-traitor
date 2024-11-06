extends Panel

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

func _ready() -> void:
	#set_process(false)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	msec = fmod(time,1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time,3600) / 60
	$Minutes.text = "%02d : " % minutes
	$Seconds.text = "%02d : " % seconds
	$Milliseconds.text = "0%02d" % msec

func stop_timer():
	set_process(false)
	
func continue_timer():
	set_process(true)

func restart_timer():
	time = 0.0
	minutes = 0
	seconds = 0
	msec = 0
	set_process(true)

func get_time_formatted() -> String:
	return "%02d:%02d:%02d" % [minutes, seconds, msec]
