extends RigidBody2D

enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R}
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer



func _on_area_2d_body_entered(body: Node2D) -> void:
	animation_player.play("Bounce_anim")
	var player: CharacterBody2D = body
	player.controllable = false
	player.position = position + Vector2(0,-60)
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(0.15).timeout
	player.current_state = states.FALL
	player.controllable = true
	player.velocity = Vector2.UP * 2400
