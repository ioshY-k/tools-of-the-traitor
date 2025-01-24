extends Node

@onready var player: CharacterBody2D = $"../Player"

@onready var area_1: Area2D = $Area2D
@onready var area_2: Area2D = $Area2D2
@onready var area_3: Area2D = $Area2D3
@onready var area_4: Area2D = $Area2D4
@onready var area_5: Area2D = $Area2D5
@onready var area_6: Area2D = $Area2D6
var follow_points = Array()
@onready var floor_ally: Sprite2D = %Ally1
@onready var block_ally: Sprite2D = %Ally2
@onready var wall_ally: Sprite2D = %Ally3
@onready var spring_ally: Sprite2D = %Ally4
@onready var rope_ally: Sprite2D = %Ally5
var allies = Array()

var floor_ally_gone: bool = false
var block_ally_gone: bool = false
var wall_ally_gone: bool = false
var spring_ally_gone: bool = false
var rope_ally_gone: bool = false

@onready var floor_tool: StaticBody2D = %Floor_tool
@onready var block_tool: StaticBody2D = %Block_tool
@onready var wall_tool: StaticBody2D = %Wall_tool
@onready var spring_tool: RigidBody2D = %Spring_tool
@onready var rope_tool: StaticBody2D = %Rope_tool

func _ready() -> void:
	if PlayerStats.floor_tool_unlocked:
		allies.append(floor_ally)
	if PlayerStats.block_tool_unlocked:
		allies.append(block_ally)
	if PlayerStats.wall_tool_unlocked:
		allies.append(wall_ally)
	if PlayerStats.spring_tool_unlocked:
		allies.append(spring_ally)
	if PlayerStats.rope_tool_unlocked:
		allies.append(rope_ally)
	
	follow_points.append(area_1)
	follow_points.append(area_2)
	follow_points.append(area_3)
	follow_points.append(area_4)
	follow_points.append(area_5)
	follow_points.append(area_6)
	for point in follow_points:
		point.position = player.position

func _physics_process(delta: float) -> void:
	
	var destination = player.get_node("Ally_destination").global_position
	var speed = player.velocity.length()
	for index in range(len(follow_points)):
		if index == 0:
			follow_points[index].position = follow_points[index].position.move_toward(destination, max(speed * delta, 2000 * delta))
		else:
			if not follow_points[index].has_overlapping_areas():
				follow_points[index].position = follow_points[index].position.move_toward(follow_points[index-1].position, max(speed * delta, 2000 * delta))
	
	for index in range(len(allies)):
		#every ally follows their corresponding follow points
		allies[index].position = allies[index].position.lerp(follow_points[index+1].position, 6 * delta )
		allies[index].scale = allies[index].scale.lerp(Vector2(0.16,0.16), 6 * delta )
	
	if floor_ally_gone:
		floor_ally.position = floor_ally.position.move_toward(floor_tool.position, 2500 * get_physics_process_delta_time())
		floor_ally.scale = floor_ally.scale.move_toward(Vector2(0.12,0.12), 2500 * get_physics_process_delta_time())
	if block_ally_gone:
		block_ally.position = block_ally.position.move_toward(block_tool.position, 2500 * get_physics_process_delta_time())
		block_ally.scale = block_ally.scale.move_toward(Vector2(0.08,0.08), 2500 * get_physics_process_delta_time())
	if wall_ally_gone:
		wall_ally.position = wall_ally.position.move_toward(wall_tool.position, 2500 * get_physics_process_delta_time())
		wall_ally.scale = wall_ally.scale.move_toward(Vector2(0.07,0.07), 2500 * get_physics_process_delta_time())
	if spring_ally_gone:
		spring_ally.position = spring_ally.position.move_toward(spring_tool.position, 2500 * get_physics_process_delta_time())
		spring_ally.scale = spring_ally.scale.move_toward(Vector2(0.09,0.09), 2500 * get_physics_process_delta_time())
	if rope_ally_gone:
		rope_ally.position = rope_ally.position.move_toward(rope_tool.position, 2500 * get_physics_process_delta_time())
		rope_ally.scale = rope_ally.scale.move_toward(Vector2(0.09,0.09), 2500 * get_physics_process_delta_time())
	


func _on_floor_tool_visibility_changed() -> void:
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


func _on_spring_tool_visibility_changed() -> void:
	spring_ally_gone = not spring_ally_gone
	if spring_ally_gone:
		allies.erase(spring_ally)
	else:
		allies.append(spring_ally)
		
func _on_rope_tool_visibility_changed() -> void:
	rope_ally_gone = not rope_ally_gone
	if rope_ally_gone:
		allies.erase(rope_ally)
	else:
		allies.append(rope_ally)


func _on_ally1_body_entered(_body: Node2D) -> void:
	allies.append(floor_ally)

func _on_ally2_body_entered(_body: Node2D) -> void:
	allies.append(block_ally)

func _on_ally3_body_entered(_body: Node2D) -> void:
	allies.append(wall_ally)

func _on_ally4_body_entered(_body: Node2D) -> void:
	allies.append(spring_ally)
	
func _on_ally5_body_entered(_body: Node2D) -> void:
	allies.append(rope_ally)
