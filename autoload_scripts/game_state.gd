extends Node

@export var current_tool_mode: Enums.ToolMode = Enums.ToolMode.PLACING

func _process(delta):
	if (Input.is_key_pressed(KEY_R)):
		current_tool_mode = Enums.ToolMode.PLACING
	elif (Input.is_key_pressed(KEY_E)):
		current_tool_mode = Enums.ToolMode.WATERING
