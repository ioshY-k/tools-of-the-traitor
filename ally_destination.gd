extends Node2D

var ally1
func _ready() -> void:
	ally1 = get_node("%Ally1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	ally1.position = ally1.position.lerp(global_position, delta * 2.0)
