extends Resource
class_name PlantResource

@export var color: int
@export var compressed_texture: CompressedTexture2D
var texture: Texture2D
@export var thirst_limit: float

func prepare_resource(plant: Node2D):
	texture = compressed_texture
	pass
