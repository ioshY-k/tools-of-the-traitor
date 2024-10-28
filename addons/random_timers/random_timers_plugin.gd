@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.
	add_custom_type("RandomRangeTimer", "Timer", preload("RandomRangeTimer.gd"), preload("RandomRangeTimer.svg"))
	add_custom_type("RandomListTimer", "Timer", preload("RandomListTimer.gd"), preload("RandomListTimer.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("RandomRangeTimer")
	remove_custom_type("RandomListTimer")
