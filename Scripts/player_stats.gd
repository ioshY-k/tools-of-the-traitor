extends Node

#Singleton Script
var floor_tool_unlocked: bool = false
var block_tool_unlocked: bool = false
var wall_tool_unlocked: bool = false
var rope_tool_unlocked: bool = false
var spring_tool_unlocked: bool = false
var field_tool_unlocked: bool = false

var toggle_to_sprint: bool = false
var bullet_time_value: float = 1.0

const ORB_NUMBER = 12
var orb_list = []

func _ready() -> void:
	orb_list.resize(ORB_NUMBER)
	orb_list.fill(false)

var death_count = 0
var orb_count = 0
