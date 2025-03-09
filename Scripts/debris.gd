extends RigidBody2D
@onready var debris_sfx: AudioStreamPlayer = $Debris_sfx
@onready var initial_timer: Timer = $Initial_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_impulse(Vector2.UP.rotated(randf_range(-1,1)) * 300)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	apply_impulse(Vector2.UP.rotated(randf_range(-1,1)) * 300)
	if initial_timer.is_stopped():
		debris_sfx.volume_db = PlayerStats.sfx_volume
		debris_sfx.play()
