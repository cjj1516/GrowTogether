extends Node3D
class_name CameraRig


@export_category("Panning")
@export var pan_sens: float = 0.004

@onready var camera_3d: Camera3D = $Camera3D


var is_panning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed

	elif event is InputEventMouseMotion and is_panning:
		var motion: Vector2 = event.relative
		
		#local axis of camera rig  to flatten forward for panning parralel to ground
		var right: Vector3 = global_transform.basis.x
		var forward: Vector3 = global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		
		global_position -= (right * motion.x + forward * motion.y) * pan_sens
