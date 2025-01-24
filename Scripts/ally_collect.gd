extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if name == "Ally1_collect" and PlayerStats.floor_tool_unlocked:
		queue_free()
	if name == "Ally2_collect" and PlayerStats.block_tool_unlocked:
		queue_free()
	if name == "Ally3_collect" and PlayerStats.wall_tool_unlocked:
		queue_free()
	if name == "Ally4_collect" and PlayerStats.spring_tool_unlocked:
		queue_free()
	if name == "Ally5_collect":
		if PlayerStats.rope_tool_unlocked:
			queue_free()
		var all_achievements = true
		for achievement in Achievements.achievement_list:
			if not achievement:
				all_achievements = false
		if not all_achievements:
			get_parent().get_node("%Ally5").queue_free()
			queue_free()
