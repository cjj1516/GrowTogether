extends Button

signal loaded()

@export var emits_loaded_signal: bool = true


func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(3.0).timeout
	loaded.emit()
	
func _on_pressed() -> void:
	SceneManager.transition_to()
	pass 
