extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	print("new checkpoint")
	$"../CharacterBody2D".last_spawnpoint = position
