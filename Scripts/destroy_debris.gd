extends AnimatedSprite2D

@onready var area_2d: Area2D = $Area2D
var debris = preload("res://Scenes/debris.tscn")
@onready var crate_break_sfx: AudioStreamPlayer = $break_sfx
signal light_intensity_change

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.area_entered.connect(destroy)
	
	light_intensity_change.connect(light_flicker)
	if name.contains("Mirror"):
		frame = 2
	if name.contains("Lantern"):
		light_intensity_change.emit()

func destroy(area):
	if area.is_in_group("debris_destroyer"):
		#add_child on it's own throws an error
		call_deferred("add_child", debris.instantiate())
		call_deferred("add_child", debris.instantiate())
		call_deferred("add_child", debris.instantiate())
		call_deferred("add_child", debris.instantiate())
		frame = 1
		crate_break_sfx.pitch_scale = randf_range(1.5,2)
		crate_break_sfx.play()
		
		if name.contains("Lantern"):
			$PointLight2D.visible = false
		else:
			$LightOccluder2D.visible = false
		
		area_2d.set_collision_mask_value(1,false)
		area_2d.set_collision_mask_value(4,false)
		area_2d.set_collision_mask_value(6,false)

func light_flicker():
	var lightscale = randf_range(0.9,1.2)
	await get_tree().create_tween().tween_property($PointLight2D, "scale", Vector2(lightscale,lightscale), 0.4).set_trans(Tween.TRANS_SINE).finished
	light_intensity_change.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
