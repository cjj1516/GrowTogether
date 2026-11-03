extends Node3D
class_name Warning

@export var warning_resource = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Created a warning!") #DEBUG
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_warning_type(name: String):
	print("Set a warning's type to {name}!".format({"name": name})) #DEBUG
	var filepath = ("res://plants/warnings/resources/{name}.tres"
		.format({"name": name}))
	warning_resource = load(filepath)
	
	if warning_resource == null:
		print(("Attempt to set warning to type {name} (filepath {filepath}) failed.")
			.format({"name": name, "filepath": filepath}))
		return
	
	warning_resource.prepare_resource(self)
	$Sprite.texture = warning_resource.texture
	pass
