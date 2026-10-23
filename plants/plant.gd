class_name Plant
extends Node

# Left here by Jon as a strong suggestion:
# Godot's custom resources seem very helpful in terms of defining multiple
# Kinds of plants, like in a botanical sense. Whereas this class is for plants
# that are planted and currently exist
var plant_resource: Resource
var color: int
var growth: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
