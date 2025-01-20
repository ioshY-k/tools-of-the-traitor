extends StaticBody2D

signal placed
var swinging = false
var pendling_right = true
@onready var player: CharacterBody2D = get_parent().get_node("Player")
@onready var path_follow_ropetool: PathFollow2D = $Path_ropetool/PathFollow_ropetool
@onready var area_2d: Area2D = $Path_ropetool/PathFollow_ropetool/Rope_sprite/Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	print(get_parent().get_children(false))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if path_follow_ropetool.progress_ratio <= 0.101:
		get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0.9, 0.8).\
		set_trans(Tween.TRANS_CUBIC).\
		set_ease(Tween.EASE_IN_OUT)
		pendling_right = true

	if path_follow_ropetool.progress_ratio >= 0.899:
		get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0.1, 0.8).\
		set_trans(Tween.TRANS_CUBIC).\
		set_ease(Tween.EASE_IN_OUT)
		pendling_right = false
	
	
	if swinging:
		swinging_behaviour()
	
	
func swinging_behaviour():
	player.global_position = player.global_position.lerp(path_follow_ropetool.global_position + Vector2.DOWN * 100, 0.4)
	if pendling_right:
		player.get_node("Model_position").scale.x = abs(player.get_node("Model_position").scale.x)
	else:
		player.get_node("Model_position").scale.x = -abs(player.get_node("Model_position").scale.x)
	if Input.is_action_just_pressed("jump"):
		if path_follow_ropetool.progress_ratio > 0.25 and pendling_right:
			player.velocity = Vector2(1875,-1750)
			area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		if path_follow_ropetool.progress_ratio < 0.75 and not pendling_right:
			player.velocity = Vector2(-1875,-1750)
			area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		player.controllable = true
		swinging = false
		await get_tree().create_timer(0.2).timeout
		area_2d.process_mode = Node.PROCESS_MODE_INHERIT
		
	if Input.is_action_just_pressed("let_go") or player.get_node("Caster_left_wall").is_colliding() or player.get_node("Caster_right_wall").is_colliding():
		area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		player.controllable = true
		swinging = false
		await get_tree().create_timer(0.2).timeout
		area_2d.process_mode = Node.PROCESS_MODE_INHERIT
		
	
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	player.controllable = false
	swinging = true


func _on_placed() -> void:
	path_follow_ropetool.progress_ratio = 0.5
	get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0.9, 0.4).\
	set_trans(Tween.TRANS_CUBIC).\
	set_ease(Tween.EASE_OUT)


func _on_visibility_changed() -> void:
	set_process(not is_processing())
	if visible:
		path_follow_ropetool.progress_ratio = 0.5
		if player.velocity.x < 0:
			get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0.1, 0.4).\
			set_trans(Tween.TRANS_CUBIC).\
			set_ease(Tween.EASE_OUT)
		else:
			get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0.9, 0.4).\
			set_trans(Tween.TRANS_CUBIC).\
			set_ease(Tween.EASE_OUT)
		
	print("vischanged")
