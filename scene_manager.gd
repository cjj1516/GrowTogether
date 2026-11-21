extends CanvasLayer


signal transitioned_in()
signal transitioned_out()

var current_scene: Node: set=set_current_scene

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	current_scene = get_tree().current_scene


func set_current_scene(value: Node) -> void:
	if current_scene == null:
		current_scene = value
		return

	current_scene = value
	var root: Window = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(value)


func transition_in() -> void:
	animation_player.play("in")


func transition_out() -> void:
	animation_player.play("out")


func transition_to() -> void:
	print("working")
	transition_in()
	await transitioned_in

	get_tree().change_scene_to_file("res://world/world.tscn")

	transition_out()
	await transitioned_out

	


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "in":
		transitioned_in.emit()
	elif anim_name == "out":
		transitioned_out.emit()
