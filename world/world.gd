extends Node3D

var plant_scene = load("res://plants/plant.tscn")

var plant_inventory: Dictionary[String, int]
var plant_list: Array[Plant]

var last_second: int = 0
var total_time: float = 0

enum ToolMode {PLACING, WATERING}
var current_tool_mode: ToolMode = ToolMode.PLACING;

@onready var GUI: CanvasLayer = $GUI
@onready var floor_node = $Floor
@onready var camera_node = $CameraRig/Camera3D
var name_to_button: Dictionary[String, Button]
var buttons: Array[Button]

var currently_planting: String = "green_plant"

# side of a grid square in world-units
var grid_size: float = 1;
var grid_availability: Dictionary[Vector2i, bool]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var colors = ["red", "yellow", "green", "blue"]
	for i in range(len(colors)):
		var color = colors[i]
		var button = Button.new()
		var plant_name = color + "_plant"
		
		add_plant_to_inventory(plant_name, 1)
		
		button.text = str(plant_inventory[plant_name])
		button.icon = load(
			"res://plants/resources/images/{plant_name}.png"
			.format({"plant_name": plant_name}
		))
		button.position = Vector2(i*150 + 20, 20)
		button.pressed.connect(attempt_to_select_what_to_plant.bind(plant_name))
		add_child(button)
		
		name_to_button[plant_name] = button
	
	for x in range(-7, 8):
		for y in range(-7, 8):
			grid_availability[Vector2i(x, y)] = true;
	pass


func attempt_to_select_what_to_plant(name: String):
	#if plant_inventory[name] >= 0:
	currently_planting = name

func add_plant_to_inventory(name: String, amount: int = 1):
	if not(plant_inventory.has(name)):
		plant_inventory[name] = 0
	plant_inventory[name] += amount
	pass

func remove_plant_from_inventory(name: String, amount: int = 1):
	if not(plant_inventory.has(name)):
		print("Attempt to remove {name} from inventory, but the key is null!")
		return
	plant_inventory[name] -= amount;
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	pass


func _unhandled_input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		if plant_inventory[currently_planting] > 0:
			var floor_position = camera_node.screen_raycast(event.position)
			var grid_position = world_pos_to_grid_pos(floor_position)
			
			if not(grid_availability.has(grid_position)) or not(grid_availability[grid_position]):
				return
			
			grid_availability[grid_position] = false
			
			floor_position = snap_world_pos_to_grid(floor_position)
			if floor_position != null:
				spawn_plant(floor_position, currently_planting)


func spawn_plant(position: Vector3, name: String):
	var new_plant = plant_scene.instantiate()
	new_plant.set_plant_type(name)
	new_plant.position = position
	plant_list.push_back(new_plant)
	add_child(new_plant)
	remove_plant_from_inventory(name, 1)
	var button = name_to_button[name]
	button.text = str(plant_inventory[name])
	pass


func world_pos_to_grid_pos(position: Vector3) -> Vector2i:
	position /= grid_size;
	return Vector2i(roundi(position.x), roundi(position.z));

# note: y value is set to 0
# there would be a way to get the height of the map at an x and z coordinate,
# but since we dont need this function yet, its not worth refactoring our map
# collision code to be whatever we want it to be in the future. when we do that,
# though, this function can be updated
func grid_pos_to_world_pos(position: Vector2i) -> Vector3:
	var world_position = Vector3(
		position.x * grid_size,
		0,
		position.y * grid_size
	);
	return world_position;


# this function does use the above grid_pos_to_world_pos function, which sets
# the y position to 0. but since we have the y position from earlier and we don't
# want to change it, this works fine. we just set it to what it was at the input
func snap_world_pos_to_grid(position: Vector3) -> Vector3:
	var y = position.y;
	var grid_position = world_pos_to_grid_pos(position);
	var world_position = grid_pos_to_world_pos(grid_position);
	world_position.y = y;
	return world_position;
