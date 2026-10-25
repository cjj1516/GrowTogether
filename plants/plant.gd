extends Node2D
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plant_resource.prepare_resource(self)
	$Sprite2D.texture = plant_resource.texture
	thirst_timer = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	thirst_timer += delta
	if (thirst_timer >= plant_resource.thirst_limit):
		pass
	pass
