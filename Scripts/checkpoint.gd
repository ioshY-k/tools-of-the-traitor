extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	$"../Player".last_spawnpoint = position
