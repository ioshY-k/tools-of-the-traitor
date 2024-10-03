extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("new checkpoint")
	$"../CharacterBody2D".last_spawnpoint = position
