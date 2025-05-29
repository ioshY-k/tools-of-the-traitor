extends AnimatedSprite2D

@onready var bird_flap_sfx: AudioStreamPlayer = $Bird_flap_sfx

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Floortool_placement_zone":
		bird_flap_sfx.play(0.62)
		var rotation = randi_range(-25,-60)
		play("default")
		if area.global_position.x < global_position.x:
			flip_h = true
			rotation = -rotation
		get_tree().create_tween().tween_property($".", "position", Vector2.UP.rotated(deg_to_rad(rotation)) * 30000, 5).set_trans(Tween.TRANS_CUBIC)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entered")
	if body.name == "Player":
		play("default")
		get_tree().create_tween().tween_property($".", "position", Vector2(1000,1000), 5).set_trans(Tween.TRANS_CUBIC)
