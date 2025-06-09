extends Area2D

@export var dialog_name : String = ""

var player_body = null

const GRAVITY_RISING = 4250 #How fast Player falls with holding jump
const GRAVITY_FALLING = 3800 * 2.5 #How much stronger  gravity pulls in falling state vs. rising state
const MAX_FALLSPEED = 700 * 2.5 #The point where gravity doesn't accelerate fallspeed enymore

enum states {	IDLE, WALK, RUN, PUSH, JUMP, FALL, LAND,
	WALLSLIDE_L, WALLSLIDE_R,
	WALLJUMP_L, WALLJUMP_R,
	SWINGING}
	
func _process(_delta: float) -> void:
	if not player_body == null:
		if player_body.velocity.y <= 0 and (Input.is_action_pressed("jump")):
			#Rising while holding jump
			player_body.velocity.y = min(player_body.velocity.y + GRAVITY_RISING * get_process_delta_time(), MAX_FALLSPEED)
		else:
			#higher gravity on jumprelease and while descending
			player_body.velocity.y = min(player_body.velocity.y + GRAVITY_FALLING * get_process_delta_time(), MAX_FALLSPEED)
	#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_DISABLED
	

func _on_body_entered(body: Node2D) -> void:
	player_body = body
	body.velocity.x = 0
	body.rocket_animations.play("Rocket_off")
	body.rocket_cycle_sfx.stop()
	body.animations.play("Idle_anim")
	body.controllable = false
	await body.is_on_floor()
	DialogManager.run_dialog(dialog_name)

	await DialogManager.dialog_finished
	if not dialog_name == "intro":
		body.controllable = true
	queue_free()
