extends Node3D
class_name CameraRig

@export_category("Panning & Following")
@export var pan_sens: float = 15.0
@export var follow_smooth_speed: float = 6.0
@export var offset: float = -1.5

@export_category("Zoom Settings")
@export var normal_zoom: float = 15.0  
@export var focused_zoom: float = 8.0   
@export var zoom_smooth_speed: float = 8.0

@onready var camera_3d: Camera3D = $Camera3D

var focused_npc_index: int = -1
var npcs: Array = []
var target_camera_z: float = 15.0
var base_height_y: float = 0.0

func _ready() -> void:
	if camera_3d:
		target_camera_z = normal_zoom
		camera_3d.position.z = normal_zoom
	base_height_y = global_position.y
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_right"):
		cycle_npc(1)
	elif event.is_action_pressed("ui_left"):
		cycle_npc(-1)
	
	
func cycle_npc(direction: int) -> void:
	release_current_npc()
	npcs = get_tree().get_nodes_in_group("npcs")
	npcs = npcs.filter(func(n): return is_instance_valid(n))
	
	if npcs.is_empty():
		focused_npc_index = -1
		target_camera_z = normal_zoom
		return
		
	focused_npc_index = (focused_npc_index + direction) % npcs.size()
	if focused_npc_index < 0:
		focused_npc_index = npcs.size() - 1
		
	var target_npc = npcs[focused_npc_index]
	if is_instance_valid(target_npc):
		target_npc.current_state = target_npc.State.TRADING
		target_npc.velocity = Vector3.ZERO
		
		
		
		target_camera_z = focused_zoom
		

	
func _process(delta: float) -> void:
	
	var is_pressing_wasd = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D)
	if is_pressing_wasd:
		release_current_npc()
		focused_npc_index = -1
		target_camera_z = normal_zoom
	
	
	if camera_3d:
		camera_3d.position.z = lerp(camera_3d.position.z, target_camera_z, zoom_smooth_speed * delta)
	
	
	if focused_npc_index >= 0 and focused_npc_index < npcs.size():
		var npc = npcs[focused_npc_index]
		if is_instance_valid(npc):
			var target_pos = Vector3(npc.global_position.x, base_height_y + offset, npc.global_position.z)
			global_position = global_position.lerp(target_pos, follow_smooth_speed * delta)
			return
			
	
	handle_wasd_movement(delta)

	
func handle_wasd_movement(delta: float) -> void:
	global_position.y = base_height_y
	var input_dir := Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1.0
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1.0
		
	input_dir = input_dir.normalized()
	
	if input_dir != Vector3.ZERO:
		var right: Vector3 = global_transform.basis.x
		var forward: Vector3 = global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		
		var motion: Vector3 = (right * input_dir.x + forward * input_dir.z) * pan_sens * delta
		global_position += motion
		
		

func release_current_npc() -> void:
	if focused_npc_index >= 0 and focused_npc_index < npcs.size():
		var current_npc = npcs[focused_npc_index]
		if is_instance_valid(current_npc) and current_npc.has_method("done_interacting"):
			current_npc.done_interacting()
