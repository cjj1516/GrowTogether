extends Resource
class_name WarningResource

@export var compressed_texture: CompressedTexture2D
var texture: Texture2D

func prepare_resource(warning: Node3D):
	texture = compressed_texture
	pass
