extends CharacterBody2D
class_name Npc

enum NpcColor {ORANGE, PURPLE, GREEN, BLUE}

@export var npc_color: NpcColor = NpcColor.ORANGE

@export_category("Sprites")
@export var texture_orange: Texture2D
@export var texture_purple: Texture2D
@export var texture_green: Texture2D
@export var texture_blue: Texture2D

@export_category("Movin' Settings")
@export var move_speed: float = 60.0
@export var edge_padding: float = 50.0
#this stops the little character from going to the direct edge^

#wandering distance just for this iteration gonna be different with adding rooms and such will use collision or a raycast for detecting then
var room_bounds: Rect2 

@onready var sprite_2d: Sprite2D = $Sprite2D

enum State {WANDERING, IDLE, WANTPLANT, ATPLANT}
var current_state: State = State.WANDERING


var target_pos: Vector2 = Vector2.ZERO
var timer: float =0.0
var plant_node: Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_color()
	setup_viewport_bounds()
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
			#this one doesnt rlly do anything at the moment but this is where any watering interaction will go
			pass
	
	move_and_slide()

func set_color() -> void:
	#I <3 match statements
	match npc_color:
		NpcColor.ORANGE:
			sprite_2d.texture = texture_orange
		NpcColor.GREEN:
			sprite_2d.texture = texture_green
		NpcColor.PURPLE:
			sprite_2d.texture = texture_purple
		NpcColor.BLUE:
			sprite_2d.texture = texture_blue

#this will be completely unneccasary when we are in 3d but for now it works
func setup_viewport_bounds() -> void:
	
	var vp = get_viewport()
	var vp_rect = vp.get_visible_rect()
	
	var center = Vector2.ZERO
	var camera = vp.get_camera_2d()
	if camera:
		center = camera.get_screen_center_position()
	else:
		center = vp_rect.size / 2.0
	
	room_bounds = Rect2(
		center.x - (vp_rect.size.x / 2.0) + edge_padding,
		center.y - (vp_rect.size.y / 2.0) + edge_padding,
		vp_rect.size.x - (edge_padding * 2.0),
		vp_rect.size.y - (edge_padding * 2.0)
	)

#grabs plant from the list
func get_plant() -> Node2D:
	var world_node = get_tree().current_scene
	var plants = world_node.plant_list
	if !plants.is_empty():
		return plants.pick_random() as Node2D
	else:
		return null


func pick_target() -> void:
	#random area inside the viewport
	target_pos = Vector2(
		randf_range(room_bounds.position.x, room_bounds.position.x + room_bounds.size.x),
		randf_range(room_bounds.position.y, room_bounds.position.y + room_bounds.size.y)
	)

func action_decision() -> void:
	#30% chance to do each thing 
	var availale_plant = get_plant()
	
	if randf() < 0.3:
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
	
	var direction = global_position.direction_to(target_pos)
	velocity = direction * move_speed
	
	if global_position.distance_to(target_pos) < 5.0:
		velocity = Vector2.ZERO
		action_decision()

func handle_idle(delta: float) -> void:
	timer -= delta
	velocity = Vector2.ZERO
	if timer <= 0.0:
		pick_target()
		current_state = State.WANDERING
		
func handle_wantplant() -> void:
	if not is_instance_valid(plant_node):
		pick_target()
		current_state = State.WANDERING
		return
	target_pos = plant_node.global_position
	var direction = global_position.direction_to(target_pos)
	velocity = direction * move_speed
	
	if global_position.distance_to(target_pos) < 15.0:
		velocity = Vector2.ZERO
		current_state = State.ATPLANT
		
		var pause_timer = get_tree().create_timer(randf_range(2,3))
		pause_timer.timeout.connect(done_interacting)

func done_interacting() -> void:
	plant_node = null
	pick_target()
	current_state = State.WANDERING
