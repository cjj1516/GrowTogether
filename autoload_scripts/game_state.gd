extends Node

@export var current_tool_mode: Enums.ToolMode = Enums.ToolMode.PLACING
var watering_cursor = preload("res://gui/sprites/watering_can_ic.png")
var hand_cursor = preload("res://gui/sprites/hand_ic.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(hand_cursor,0 ,Vector2(64.0,64.0))
	
	
func _process(delta):
	if (Input.is_key_pressed(KEY_R)):
		current_tool_mode = Enums.ToolMode.PLACING
		Input.set_custom_mouse_cursor(hand_cursor,0 ,Vector2(64.0,64.0))
	elif (Input.is_key_pressed(KEY_E)):
		current_tool_mode = Enums.ToolMode.WATERING
		Input.set_custom_mouse_cursor(watering_cursor,0 ,Vector2(64.0,64.0))
