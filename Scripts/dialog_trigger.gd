extends Area2D

@export var dialog_name : String = ""


func _on_body_entered(body: Node2D) -> void:
	DialogManager.run_dialog(dialog_name)
	body.velocity = Vector2.ZERO
	body.controllable = false
	await DialogManager.dialog_finished
	print("finished")
	if not dialog_name == "intro":
		print("intro")
		body.controllable = true
	queue_free()
