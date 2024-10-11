extends RigidBody2D

enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R}
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var caster_outer_left: RayCast2D = $Node2D/Caster_outer_left
@onready var caster_inner: RayCast2D = $Node2D/Caster_inner
@onready var caster_outer_right: RayCast2D = $Node2D/Caster_outer_right


func _ready() -> void:
	set_process(false)

func _physics_process(delta: float) -> void:
	_spring_ledge_corrections()
	
func _spring_ledge_corrections():
	if caster_inner.is_colliding():
		caster_outer_left.enabled = false
		caster_outer_right.enabled = false
	else:
		linear_velocity = Vector2.DOWN * 1500
		caster_outer_left.enabled = true
		caster_outer_right.enabled = true
		while caster_outer_left.is_colliding():
			global_position += Vector2(2,0)
			caster_outer_left.force_raycast_update()
		while caster_outer_right.is_colliding():
			global_position += Vector2(-2,0)
			caster_outer_right.force_raycast_update()
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	animation_player.play("Bounce_anim")
	var player: CharacterBody2D = body
	player.controllable = false
	#player.position = position + Vector2(0,-60)
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(0.15).timeout
	player.current_state = states.FALL
	player.controllable = true
	player.velocity = Vector2.UP * 2400


func _on_visibility_changed() -> void:
	set_process(not is_processing())
