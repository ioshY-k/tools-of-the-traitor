extends AnimatedSprite2D
@onready var random_range_timer: Timer = $"../RandomRangeTimer"
@onready var shader : ShaderMaterial = material
var rand_speed = 0.5
var rand_size = 0.1

var shimmering = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_range_timer.timeout.connect(func():
				shimmering = not shimmering
				rand_speed = randf_range(0.1,0.6)
				rand_size = randf_range(0.05,0.25))

func _process(_delta: float) -> void:
	if shimmering:
		shader.set_shader_parameter("speed", rand_speed)
		shader.set_shader_parameter("size_effect", rand_size)
		shader.set_shader_parameter("highlight_strength", move_toward(shader.get_shader_parameter("highlight_strength"),1, 0.15))
	else:
		shader.set_shader_parameter("highlight_strength", move_toward(shader.get_shader_parameter("highlight_strength"),0.0, 0.15))
	
func _on_shimmer_change(): 
	shimmering = not shimmering
	rand_speed = randf_range(0.3,0.8)
	rand_size = randf_range(0.05,0.25)
