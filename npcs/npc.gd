extends CharacterBody3D
class_name Npc

enum NpcColor {ORANGE, PURPLE, GREEN, BLUE}

@export var npc_color: NpcColor = NpcColor.ORANGE

@export_category("Sprites")
@export var texture_orange: Texture2D
@export var texture_purple: Texture2D
@export var texture_green: Texture2D
@export var texture_blue: Texture2D

@export_category("Movin' Settings")
@export var move_speed: float = 3.0
@export var edge_padding: float = 1.0
#this stops the little character from going to the direct edge^

@export_category("Bounds")
@export var wander_bounds: Rect2 = Rect2(-10,-10, 20, 20)

@onready var sprite_3d: Sprite3D = $Sprite3D

enum State {WANDERING, IDLE, WANTPLANT, ATPLANT}
var current_state: State = State.WANDERING


var target_pos: Vector3 = Vector3.ZERO
var timer: float =0.0
var plant_node: Node3D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_color()
	
	pick_target()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match current_state:
		State.WANDERING:
			handle_wander()
		State.IDLE:
			handle_idle(delta)
		State.WANTPLANT:
			handle_wantplant()
		State.ATPLANT:
			
			pass
	
	move_and_slide()

func set_color() -> void:
	#I <3 match statements
	match npc_color:
		NpcColor.ORANGE:
			sprite_3d.texture = texture_orange
		NpcColor.GREEN:
			sprite_3d.texture = texture_green
		NpcColor.PURPLE:
			sprite_3d.texture = texture_purple
		NpcColor.BLUE:
			sprite_3d.texture = texture_blue



#grabs plant from the list
func get_plant() -> Node3D:
	var world_node = get_tree().current_scene
	var plants = world_node.plant_list
	if !plants.is_empty():
		return plants.pick_random() as Node3D
	else:
		return null


func pick_target() -> void:
	#random area inside the dedicated area!
	var random_x = randf_range(wander_bounds.position.x + edge_padding, wander_bounds.position.x + wander_bounds.size.x - edge_padding)
	var random_z = randf_range(wander_bounds.position.y + edge_padding, wander_bounds.position.y + wander_bounds.size.y - edge_padding)
	target_pos = Vector3(random_x, global_position.y, random_z)

func action_decision() -> void:
	#50% chance to water, 25 to wander 25 to idle 
	var availale_plant = get_plant()
	
	if randf() < 0.5:
		plant_node = availale_plant
		current_state = State.WANTPLANT
	else:
		if randf() < 0.5:
			current_state = State.IDLE
			timer = randf_range(1.0,3.0)
		else:
			
			current_state = State.WANDERING
			pick_target()

func handle_wander() -> void:
	#flat so we can just ignore height difference
	var target_flat = Vector3(target_pos.x, global_position.y, target_pos.z)
	var direction = global_position.direction_to(target_flat)
	velocity = direction * move_speed
	
	if global_position.distance_to(target_pos) < 5.0:
		velocity = Vector3.ZERO
		action_decision()

func handle_idle(delta: float) -> void:
	timer -= delta
	velocity = Vector3.ZERO
	if timer <= 0.0:
		pick_target()
		current_state = State.WANDERING
		
func handle_wantplant() -> void:
	if not is_instance_valid(plant_node):
		pick_target()
		current_state = State.WANDERING
		return
	var plant_flat = Vector3(plant_node.global_position.x, global_position.y,plant_node.global_position.z)
	target_pos = plant_flat
	var direction = global_position.direction_to(target_pos)
	velocity = direction * move_speed
	
	if global_position.distance_to(target_pos) < 1.0:
		velocity = Vector3.ZERO
		current_state = State.ATPLANT
		plant_node.water_plant()
		give_seeds()
		
		var pause_timer = get_tree().create_timer(randf_range(2,3))
		pause_timer.timeout.connect(done_interacting)

func done_interacting() -> void:
	plant_node = null
	pick_target()
	current_state = State.WANDERING
	
func give_seeds() -> void:
	
	var sprite = plant_node.get_node("Sprite3D") as Sprite3D
	var texture_path = sprite.texture.resource_path
	var file_name = texture_path.get_file().get_basename()
	
	var world_node = get_tree().current_scene
	var seeds_to_give = randi_range(0, 2)
	world_node.add_plant_to_inventory(file_name, seeds_to_give)
	world_node.attempt_to_select_what_to_plant(file_name)
