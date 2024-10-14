extends Camera2D

const SCOUT_RADIUS: int = 320
var initial_position: Vector2 = position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var yAxis = Input.get_joy_axis(0 ,JOY_AXIS_RIGHT_Y)
	var camera_vector: Vector2 = Vector2(xAxis, yAxis)
	if camera_vector.length() > 0.2:
		print(camera_vector)
		position = (initial_position + camera_vector * SCOUT_RADIUS)
	else:
		position = initial_position
	
