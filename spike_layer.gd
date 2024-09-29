extends TileMapLayer

const DEADZONE = preload("res://deadzone.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spikes = get_used_cells()
	print(spikes)
	for spike in spikes:
		var antotherSpike = DEADZONE.instantiate()
		add_child(antotherSpike)
		print(antotherSpike.position)
		var tileposition = map_to_local(spike)
		antotherSpike.position = tileposition


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
