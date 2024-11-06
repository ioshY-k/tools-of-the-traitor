extends Area2D

@onready var dialog_trigger_bullettime: Area2D = $"../../DialogTrigger_bullettime"

func _ready() -> void:
	body_entered.connect(func(_body): 
		dialog_trigger_bullettime.set_process_mode(PROCESS_MODE_INHERIT)
		print("set mode"))
