extends AnimatedSprite2D

@onready var area_2d: Area2D = $Area2D
var debris = preload("res://Scenes/debris.tscn")
@onready var crate_break_sfx: AudioStreamPlayer = $Crate_break_sfx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.area_entered.connect(destroy)

func destroy(area):
	#add_child on it's own throws an error
	call_deferred("add_child", debris.instantiate())
	call_deferred("add_child", debris.instantiate())
	call_deferred("add_child", debris.instantiate())
	call_deferred("add_child", debris.instantiate())
	frame = 2
	crate_break_sfx.pitch_scale = randf_range(1.5,2)
	crate_break_sfx.play()
	
	area_2d.set_collision_mask_value(1,false)
	area_2d.set_collision_mask_value(4,false)
	area_2d.set_collision_mask_value(6,false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
