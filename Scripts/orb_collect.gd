extends Node2D

var hair: AnimatedSprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("collect")
	var collection_tester = Collection_tester.new(body, self)
	add_child(collection_tester)
	hair = body.get_node("Model_position/Player_cutout/Player_hip/Player_torso/Player_head/Player_hair")
	hair.play("holding_orb_anim")
	get_node("Orb_Sprite/Area2D").set_collision_mask_value(1, false)
	visible = false
	await collection_tester.decided_if_collected.connect(_on_collected_decision.bind())

func _on_collected_decision(collected: bool):
	if collected:
		PlayerStats.orb_count += 1
		print("collected! orbcount: " + str(PlayerStats.orb_count))
		hair.stop()
		$"../CanvasLayer".tip_buttons[int(str(name)[-1])].disabled = false
		
		queue_free()
	else:
		await get_tree().create_timer(1).timeout
		get_node("Orb_Sprite/Area2D").set_collision_mask_value(1, true)
		visible = true
		hair.stop()
		print("died... orbcount: " + str(PlayerStats.orb_count))

class Collection_tester extends Node:
	
	signal decided_if_collected
	var player: CharacterBody2D
	var current_death_count: int
	var orb
	
	func _init(pl: CharacterBody2D, o: Node2D) -> void:
		player = pl
		orb = o
		current_death_count = PlayerStats.death_count
	
	func _process(_delta: float) -> void:
		print(str(player.is_on_floor()) + str(player.is_on_tool))
		if PlayerStats.death_count > current_death_count:
			decided_if_collected.emit(false)
			queue_free()
		if player.is_on_floor() and not player.is_on_tool:
			decided_if_collected.emit(true)
			queue_free()
	
	
	
