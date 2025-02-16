extends RigidBody2D

enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
				WALLSLIDE_L, WALLSLIDE_R,
				WALLJUMP_L, WALLJUMP_R}
@onready var caster_outer_left: RayCast2D = $Node2D/Caster_outer_left
@onready var caster_inner: RayCast2D = $Node2D/Caster_inner
@onready var caster_outer_right: RayCast2D = $Node2D/Caster_outer_right
@onready var spring_sfx: AudioStreamPlayer = $spring_sfx


func _ready() -> void:
	set_process(false)

func _physics_process(_delta: float) -> void:
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
	
	var player: CharacterBody2D = body
	player.controllable = false
	#player.position = position + Vector2(0,-60)
	player.velocity = Vector2.ZERO
	
	bounce_animation()
	
	await get_tree().create_timer(0.15).timeout
	spring_sfx.play()
	player.current_state = states.FALL
	player.controllable = true
	player.launched = true
	if Input.is_action_pressed("jump"):
		player.velocity = Vector2.UP * 2400
	else:
		player.velocity = Vector2.UP * 1400
		
func bounce_animation():
	var toppart_tween = create_tween().set_parallel(true)
	toppart_tween.tween_property($Node2D/Top, "position:y", 55, 0.15)
	toppart_tween.tween_property($Node2D/Middle, "position:y", 24, 0.15)
	toppart_tween.tween_property($Node2D/Middle, "scale:y", 0, 0.15)
	toppart_tween.chain().tween_property($Node2D/Top, "position:y", 0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	toppart_tween.tween_property($Node2D/Middle, "position:y", 0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	toppart_tween.tween_property($Node2D/Middle, "scale:y", 1, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	


func _on_visibility_changed() -> void:
	set_process(not is_processing())
