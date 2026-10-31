extends Node3D
class_name SpawnManager


@export_category("Spawning settings")
@export var npc_scene: PackedScene
@export var spawn_interval_min: float = 10.0
@export var spawn_interval_max: float = 15.0

@export_category("Plant Weights")
@export var base_weight: float = 1.0
@export var weight_per_plant: float = 2.0

var spawn_timer: Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_timer()
	pass # Replace with function body.

func _on_spawn_timeout() -> void:
	spawn_npc()
	start_random_timer()
	
	
func setup_timer() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timeout)
	start_random_timer()
	
func start_random_timer() -> void:
	var wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.start(wait_time)
	
	
func get_weighted_random_color() -> Npc.NpcColor:
	var counts = {
		Npc.NpcColor.ORANGE: 0,
		Npc.NpcColor.PURPLE: 0,
		Npc.NpcColor.GREEN: 0,
		Npc.NpcColor.BLUE: 0,
		
	}
	
	var world_node = get_tree().current_scene
	if world_node and "plant_list" in world_node:
		for plant in world_node.plant_list:
			#loops through worlds plant list
			if is_instance_valid(plant):
					var sprite = plant.get_node_or_null("Sprite") as Sprite3D
					if sprite and sprite.texture:
						var t_name = sprite.texture.resource_path.to_lower()
						if "yellow" in t_name: counts[Npc.NpcColor.ORANGE] += 1
						elif "red" in t_name: counts[Npc.NpcColor.PURPLE] += 1
						elif "green" in t_name: counts[Npc.NpcColor.GREEN] += 1
						elif "blue" in t_name: counts[Npc.NpcColor.BLUE] += 1
	var colors: Array[Npc.NpcColor] = [Npc.NpcColor.ORANGE, Npc.NpcColor.PURPLE, Npc.NpcColor.GREEN, Npc.NpcColor.BLUE]
	var weights: Array[float] = []
	var total_weight = 0.0
	
	#loops through the colors to determine weight
	for col in colors:
		var w = base_weight + (counts[col] * weight_per_plant)
		weights.append(w)
		total_weight += w
	var roll = randf() * total_weight
	var current_sum = 0.0
	
	#loops through weights, adds them to a total and when the roll is within or below the total picks that color
	for i in range(colors.size()):
		current_sum += weights[i]
		if roll <= current_sum:
			return colors[i]
	#orange fallback just incase
	return Npc.NpcColor.ORANGE

func spawn_npc() -> void:
	var chosen_color = get_weighted_random_color()
	var npc_instance = npc_scene.instantiate() as Npc
	npc_instance.npc_color = chosen_color
	
	get_tree().current_scene.add_child(npc_instance)
	npc_instance.global_position = global_position
	
	
