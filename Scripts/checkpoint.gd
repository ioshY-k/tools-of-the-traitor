extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	$"../Player".last_spawnpoint = position


func _on_body_exited(body: Node2D) -> void:
	if PlayerStats.cursed_mode:
		get_node("../Cursed_Orb").orb_respawn_check()
