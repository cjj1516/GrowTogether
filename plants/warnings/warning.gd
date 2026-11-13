extends Node3D
class_name Warning

@export var warning_resource = null
var warning_name = null

func set_warning_type(new_name: String):
	var filepath = ("res://plants/warnings/resources/{name}.tres"
		.format({"name": new_name}))
	warning_resource = load(filepath)
	
	if warning_resource == null:
		print(("Attempt to set warning to type {name} (filepath {filepath}) failed.")
			.format({"name": new_name, "filepath": filepath}))
		return
	
	warning_resource.prepare_resource(self)
	$Sprite.texture = warning_resource.texture
	warning_name = new_name
	pass
