extends Node

var plant_scene = load("res://plants/plant.tscn")

var plant_list: Array[Plant]

var last_second: int = 0
var total_time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	pass

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		print("Mouse Click/Unclick at: ", event.position)
		spawn_plant(event.position, "blue_plant")

	# Print the size of the viewport.
	# print("Viewport Resolution is: ", get_viewport().get_visible_rect().size)

func spawn_plant(position: Vector2, type: String):
	var new_plant = plant_scene.instantiate()
	new_plant.set_plant_type(type)
	new_plant.position = position
	plant_list.push_back(new_plant)
	add_child(new_plant)
	pass
