extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_lightning_strike() -> void: 
	play("lightning_strike_anim")
	animation_player.play("lightning_fade_anim")
	print("strike!")


func _on_lightning_timer_timeout() -> void:
	pass # Replace with function body.
