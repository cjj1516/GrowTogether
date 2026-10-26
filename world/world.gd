extends Node

var plant_scene = load("res://plants/plant.tscn")

var plant_inventory: Dictionary[String, int]
var plant_list: Array[Plant]

var last_second: int = 0
var total_time: float = 0

@onready var GUI: CanvasLayer = $GUI
var name_to_button: Dictionary[String, Button]
var buttons: Array[Button]

var currently_planting: String = "green_plant"

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
			spawn_plant(event.position, currently_planting)


func spawn_plant(position: Vector2, name: String):
	var new_plant = plant_scene.instantiate()
	new_plant.set_plant_type(name)
	new_plant.position = position
	plant_list.push_back(new_plant)
	add_child(new_plant)
	remove_plant_from_inventory(name, 1)
	var button = name_to_button[name]
	button.text = str(plant_inventory[name])
	pass
