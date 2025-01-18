extends StaticBody2D

@onready var path_follow_ropetool: PathFollow2D = $Path_ropetool/PathFollow_ropetool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path_follow_ropetool.progress_ratio = 0.5
	get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 1, 0.5).\
	set_trans(Tween.TRANS_CUBIC).\
	set_ease(Tween.EASE_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path_follow_ropetool.progress_ratio == 0:
		get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 1, 1).\
		set_trans(Tween.TRANS_CUBIC).\
		set_ease(Tween.EASE_IN_OUT)
	
	if path_follow_ropetool.progress_ratio == 1:
		get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 0, 1).\
		set_trans(Tween.TRANS_CUBIC).\
		set_ease(Tween.EASE_IN_OUT)
		

func _on_visibility_changed() -> void:
	if visible:
		path_follow_ropetool.progress_ratio = 0.5
		get_tree().create_tween().tween_property(path_follow_ropetool, "progress_ratio", 1, 0.5).\
		set_trans(Tween.TRANS_CUBIC).\
		set_ease(Tween.EASE_OUT)
