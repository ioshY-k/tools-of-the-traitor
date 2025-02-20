extends Node2D

var main_menu_scene = preload("res://Scenes/main_menu.tscn")
var testlevel_scene = preload("res://Scenes/Levels/testlevel.tscn")
var intro_scene = preload("res://Scenes/intro_scene.tscn")

@onready var blendscreen: Sprite2D = $CanvasLayer/Blendscreen
var blend_tween: Tween
signal faded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(intro_scene.instantiate())
	


func fade_to_scene(scene):
	if scene == "Testlevel":
		get_child(1).process_mode = Node.PROCESS_MODE_DISABLED
		blend_fade_out()
		await faded
		get_child(1).queue_free()
		await get_tree().create_timer(0.5).timeout
		add_child(testlevel_scene.instantiate())
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		blend_fade_in()
	if scene == "Main_menu":
		get_child(1).process_mode = Node.PROCESS_MODE_DISABLED
		blend_fade_out()
		await faded
		get_child(1).queue_free()
		await get_tree().create_timer(0.5).timeout
		add_child(main_menu_scene.instantiate())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		blend_fade_in()
	if scene == "Main_menu_initial":
		get_child(1).queue_free()
		await get_tree().create_timer(0.5).timeout
		add_child(main_menu_scene.instantiate())
		blend_fade_in()
	
		
		

func blend_fade_out():
	blendscreen.position.y = 1800
	blend_tween = get_tree().create_tween()
	blend_tween.tween_property(blendscreen, "position:y", 324, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await blend_tween.finished
	faded.emit()

func blend_fade_in():
	blendscreen.position.y = 324
	blend_tween = get_tree().create_tween()
	blend_tween.tween_property(blendscreen, "position:y", 1900, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await blend_tween.finished
	faded.emit()
