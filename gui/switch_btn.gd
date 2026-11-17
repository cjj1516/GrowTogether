extends Control
var watering_cursor = preload("res://gui/sprites/watering_can_ic.png")
var hand_cursor = preload("res://gui/sprites/hand_ic.png")
@onready var tool_sprite: Sprite2D = $tool_sprite
var is_hand: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_crate_button_pressed() -> void:
	if is_hand:
		tool_sprite.texture = hand_cursor
		GameState.current_tool_mode = Enums.ToolMode.PLACING
		Input.set_custom_mouse_cursor(hand_cursor,0 ,Vector2(64.0,64.0))
	else:
		tool_sprite.texture = watering_cursor
		GameState.current_tool_mode = Enums.ToolMode.WATERING
		Input.set_custom_mouse_cursor(watering_cursor,0 ,Vector2(64.0,64.0))
	is_hand = !is_hand
	pass # Replace with function body.
