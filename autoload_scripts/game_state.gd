extends Node

@export var current_tool_mode: Enums.ToolMode = Enums.ToolMode.PLACING
var watering_cursor = preload("res://gui/sprites/can.png")
func _process(delta):
	if (Input.is_key_pressed(KEY_R)):
		current_tool_mode = Enums.ToolMode.PLACING
		Input.set_custom_mouse_cursor(null)
	elif (Input.is_key_pressed(KEY_E)):
		current_tool_mode = Enums.ToolMode.WATERING
		Input.set_custom_mouse_cursor(watering_cursor)
