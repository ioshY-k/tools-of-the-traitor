extends CanvasLayer

@onready var blendscreen: Sprite2D = $Blendscreen
var blend_tween: Tween
signal faded

func blend_fade_out():
	blendscreen.position.y = 1800
	blend_tween = get_tree().create_tween()
	blend_tween.tween_property(blendscreen, "position:y", 324, 1.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await blend_tween.finished
	faded.emit()

func blend_fade_in():
	blendscreen.position.y = 324
	blend_tween = get_tree().create_tween()
	blend_tween.tween_property(blendscreen, "position:y", 1800, 1.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await blend_tween.finished
	faded.emit()
