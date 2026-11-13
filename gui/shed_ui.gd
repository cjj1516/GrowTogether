extends Node

var buttons: Array[Button]
var callback: Callable

func _ready():
	# Recursively finds all crate buttons in the scene
	buttons.assign(find_children("Slot*", "Button"))

func update_ui(inventory: Dictionary[String, int]):
	var c = 0
	for plant_name in inventory:
		set_slot_contents(buttons[c], plant_name, inventory[plant_name])
		c += 1

func set_slot_contents(button: Button, plant_name: String, count: int):
	reset_button(button)
	var label = button.find_child("Label")
	
	label.text = str(count)
	button.icon = load(
		"res://plants/resources/images/{plant_name}.png"
		.format({"plant_name": plant_name}
	))
	button.pressed.connect(callback.bind(plant_name))

func reset_button(button: Button):
	var label = button.find_child("Label")
	label.text = ""
	button.icon = null
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection.callable)
