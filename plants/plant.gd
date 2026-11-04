extends Area3D
class_name Plant

# Godot's custom resources seem very helpful in terms of defining multiple
# Kinds of plants, like in a botanical sense. Whereas this class is for plants
# that are planted and currently exist
@export var plant_resource: PlantResource = null
# Note: when we add more problems (termites, sunstroke, whatever) we'll want to
#       make this all more general. not just add like, "termite_level" as a
#       variable. maybe add a struct or enum for troubles? and everything is a
#       float. and it has one for limits (in the resource) and one for status.
#       and another one for if it's being tended to in that way.
var thirst_timer: float
var being_watered: bool
@export var drink_speed: float = 3.0
var drink_timer: float
var warning_list: Array[Warning]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_warnings()
	thirst_timer = 0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (plant_resource == null):
		return
	thirst_timer += delta
	if (thirst_timer >= plant_resource.thirst_limit):
		set_warnings_visibility("water_warning", true)
	else:
		set_warnings_visibility("water_warning", false)
	pass

func _input_event(_cam: Camera3D, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _index: int):
	if (GameState.current_tool_mode == Enums.ToolMode.WATERING
	and event is InputEventMouseButton and event.pressed):
		water_plant()
		print("Just watered a plant!")

func set_warnings_visibility(warning_name: String, visibility: bool):
	for warning in warning_list:
		if warning.warning_name == warning_name:
			warning.visible = visibility

# you have to call this function when you make a new plant, name is the same as
# the plant's resource
func set_plant_type(plant_resource_name: String):
	var filepath = ("res://plants/resources/{name}.tres"
		.format({"name": plant_resource_name}))
	plant_resource = load(filepath)
	
	if plant_resource == null:
		print(("Attempt to set plant to type {name} (filepath {filepath}) failed.")
			.format({"name": name, "filepath": filepath}))
		return
	
	plant_resource.prepare_resource(self)
	$Sprite.texture = plant_resource.texture
	pass
	
func water_plant(timer_reduction: float = 0):
	thirst_timer = 0 if timer_reduction == 0 else thirst_timer - min(thirst_timer, timer_reduction)
	return

func add_warnings():
	var warning_scene = load("res://plants/warnings/warning.tscn")
	var water_warning = warning_scene.instantiate()
	water_warning.set_warning_type("water_warning")
	warning_list.push_back(water_warning)
	self.add_child(water_warning)

func remove_warnings():
	for warning in warning_list:
		warning.queue_free()
	warning_list.clear()
