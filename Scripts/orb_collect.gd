extends Node2D

var hair: AnimatedSprite2D
@onready var rotation_anim_timer: Timer = $Rotation_anim_timer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var area_2d: Area2D = $Area2D
@onready var orb_sprite: AnimatedSprite2D = get_node("..")



func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("collect")
	rotation_anim_timer.stop()
	orb_sprite.play("collected_anim")
	cpu_particles_2d.emitting = false
	var collection_tester = Collection_tester.new(body, self)
	add_child(collection_tester)
	hair = body.get_node("Model_position/Player_cutout/Player_hip/Player_torso/Player_head/Player_hair")
	hair.play("holding_orb_anim")
	area_2d.set_collision_mask_value(1, false)
	await collection_tester.decided_if_collected.connect(_on_collected_decision.bind())

func _on_collected_decision(collected: bool):
	if collected:
		PlayerStats.orb_count += 1
		#print("collected! orbcount: " + str(PlayerStats.orb_count))
		hair.stop()
		var orb_title_number = ""
		for i in range(2):
			if not str(name)[i] == "O":
				orb_title_number += str(name)[i]
		$"../../CanvasLayer".tip_buttons[int(orb_title_number) - 1].disabled = false
		$"../../CanvasLayer2/new_tip_text".show()
		await get_tree().create_timer(5).timeout
		$"../../CanvasLayer2/new_tip_text".hide()
		queue_free()
	else:
		hair.stop()
		await get_tree().create_timer(1.5).timeout
		area_2d.set_collision_mask_value(1, true)
		cpu_particles_2d.emitting = true
		orb_sprite.frame = 0
		rotation_anim_timer.start()
		#print("died... orbcount: " + str(PlayerStats.orb_count))

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
		#print(str(player.is_on_floor()) + str(player.is_on_tool))
		if PlayerStats.death_count > current_death_count:
			decided_if_collected.emit(false)
			queue_free()
		if player.is_on_floor() and not player.is_on_tool:
			await get_tree().create_timer(0.2).timeout
			decided_if_collected.emit(true)
			queue_free()


func _on_rotation_anim_timer_timeout() -> void:
	orb_sprite.rotate(randf_range(-PI,PI))
	rotation_anim_timer.wait_time = randf_range(0.1,0.3)
