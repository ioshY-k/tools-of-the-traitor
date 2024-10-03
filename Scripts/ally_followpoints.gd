extends Node

@onready var player: CharacterBody2D = $"../CharacterBody2D"

@onready var area_1: Area2D = $Area2D
@onready var area_2: Area2D = $Area2D2
@onready var area_3: Area2D = $Area2D3
@onready var area_4: Area2D = $Area2D4
@onready var area_5: Area2D = $Area2D5
@onready var area_6: Area2D = $Area2D6
var follow_points  = Array()
@onready var floor_ally: Sprite2D = %Ally1
@onready var block_ally: Sprite2D = %Ally2
@onready var wall_ally: Sprite2D = %Ally3
var allies = Array()

var floor_ally_gone: bool = false
var block_ally_gone: bool = false
var wall_ally_gone: bool = false

@onready var floor_tool: StaticBody2D = %Floor_tool
@onready var block_tool: StaticBody2D = %Block_tool
@onready var wall_tool: StaticBody2D = %Wall_tool


func _ready() -> void:
	follow_points.append(area_1)
	follow_points.append(area_2)
	follow_points.append(area_3)
	follow_points.append(area_4)
	follow_points.append(area_5)
	follow_points.append(area_6)
	allies.append(floor_ally)
	allies.append(block_ally)
	allies.append(wall_ally)
	for point in follow_points:
		point.position = player.position

func _physics_process(delta: float) -> void:
	var destination = player.get_node("Ally_destination").global_position
	var speed = player.velocity.length()
	for index in range(len(follow_points)):
		if index == 0:
			follow_points[index].position = follow_points[index].position.move_toward(destination, max(speed * delta, 800 * delta))
		else:
			if not follow_points[index].has_overlapping_areas():
				follow_points[index].position = follow_points[index].position.move_toward(follow_points[index-1].position, max(speed * delta, 800 * delta))
	
	for index in range(len(allies)):
		#every ally follows their corresponting follow points
		allies[index].position = allies[index].position.lerp(follow_points[index+1].position, 6 * delta )
	
	if floor_ally_gone:
		floor_ally.position = floor_ally.position.move_toward(floor_tool.position, 2500 * get_physics_process_delta_time())
	if block_ally_gone:
		block_ally.position = block_ally.position.move_toward(block_tool.position, 2500 * get_physics_process_delta_time())
	if wall_ally_gone:
		wall_ally.position = wall_ally.position.move_toward(wall_tool.position, 2500 * get_physics_process_delta_time())


func _on_floor_tool_sprite_visibility_changed() -> void:
	floor_ally_gone = not floor_ally_gone
	if floor_ally_gone:
		allies.erase(floor_ally)
	else:
		allies.append(floor_ally)


func _on_block_tool_visibility_changed() -> void:
	block_ally_gone = not block_ally_gone
	if block_ally_gone:
		allies.erase(block_ally)
	else:
		allies.append(block_ally)


func _on_wall_tool_visibility_changed() -> void:
	wall_ally_gone = not wall_ally_gone
	if wall_ally_gone:
		allies.erase(wall_ally)
	else:
		allies.append(wall_ally)
