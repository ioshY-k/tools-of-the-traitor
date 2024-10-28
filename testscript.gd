extends Node2D

@onready var timer: Timer = $Timer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		timer.start()
	timer.timeout.connect(func(): print("emitted via lambda"))

func _on_timer_timeout() -> void:
	print("emitted via function")

func timeouteted():
	print("third emitstrat")
