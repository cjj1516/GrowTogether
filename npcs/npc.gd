extends CharacterBody3D
class_name Npc

enum NpcColor {ORANGE, PURPLE, GREEN, BLUE}

@export var npc_color: NpcColor = NpcColor.ORANGE

@export_category("Sprites")
@export var texture_orange: Texture2D
@export var texture_purple: Texture2D
@export var texture_green: Texture2D
@export var texture_blue: Texture2D
@export var hand_texture: Texture2D

@export_category("Hand Tint Colors ")
@export var tint_orange: Color = Color("e78620ff")
@export var tint_purple: Color = Color("a255beff")
@export var tint_green: Color = Color("21e84eff")
@export var tint_blue: Color = Color("3adaffff")

@export_category("Movin' Settings")
@export var move_speed: float = 3.0
@export var edge_padding: float = 1.0
#this stops the little character from going to the direct edge^
@export var gravity: float = 9.8


@export_category("Squash and Stretch")
@export var stretch_amount: float = 0.25
@export var bounce_frequency: float = 16.0

var walk_anim_time: float = 0.0
var base_sprite_scale: Vector3 = Vector3.ONE


@export_category("Bounds")
@export var wander_bounds: Rect2 = Rect2(-2,-2, 6, 6)


@export_category("Dialogue")
@export var symbol_list: Array[Texture2D] = []
@export var conversation_turns: int = 4
@export var symbol_display_duration: float = 1.2
@export var conversation_cooldown: float = 5.0
@export var seek_search_radius: float = 12.0


@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var hand_sprite_3d: Sprite3D = $Hand
@onready var dialogue_bubble: Sprite3D = $DialogueBubble
@onready var symbol_sprite: Sprite3D = $DialogueBubble/SymbolSprite
@onready var interaction_area: Area3D = $InteractionArea

enum State {WANDERING, IDLE, WANTPLANT, ATPLANT, TRADING, INTERACTING_WITH_NPC}
var current_state: State = State.WANDERING


var target_pos: Vector3 = Vector3.ZERO
var target_npc: Npc = null
var timer: float =0.0
var plant_node: Node3D = null

var base_bubble_scale: Vector3 = Vector3.ONE
var base_symbol_scale: Vector3 = Vector3.ONE
var conversation_partner: Npc = null
var is_initiator: bool = false
var turns_remaining: int = 0
var is_on_cooldown: bool = false
var dialogue_tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("npcs")
	set_color()
	base_sprite_scale = sprite_3d.scale
	hand_sprite_3d.visible = false
	base_bubble_scale = dialogue_bubble.scale
	dialogue_bubble.visible = false
	dialogue_bubble.scale = Vector3.ZERO
	base_symbol_scale = symbol_sprite.scale
	pick_target()
	


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
			velocity.x = 0.0
			velocity.z = 0.0
		State.TRADING:
			handle_trading()
		State.INTERACTING_WITH_NPC:
			handle_interacting_with_npc()
			pass
	if not is_on_floor():
		velocity.y -= gravity * delta
		current_state = State.IDLE
	else:
		
		velocity.y = 0.0
	move_and_slide()
	squash_and_stretch(delta)

func set_color() -> void:
	#I <3 match statements
	match npc_color:
		NpcColor.ORANGE:
			sprite_3d.texture = texture_orange
			hand_sprite_3d.modulate = tint_orange
		NpcColor.GREEN:
			sprite_3d.texture = texture_green
			hand_sprite_3d.modulate = tint_green
		NpcColor.PURPLE:
			sprite_3d.texture = texture_purple
			hand_sprite_3d.modulate = tint_purple
		NpcColor.BLUE:
			sprite_3d.texture = texture_blue
			hand_sprite_3d.modulate = tint_blue



#grabs plant from the list
func get_plant() -> Node3D:
	var world_node = get_tree().current_scene
	var plants = world_node.plant_list
	if !plants.is_empty():
		return plants.pick_random() as Node3D
	else:
		return null

func get_available_npcs() -> Array[Npc]:
	var list: Array[Npc] = []
	for node in get_tree().get_nodes_in_group("npcs"):
		if node is Npc and node != self and not node.is_on_cooldown:
			if node.current_state in [State.WANDERING, State.IDLE]:
				if global_position.distance_to(node.global_position) <= seek_search_radius:
					list.append(node)
	return list

func pick_target() -> void:
	var nearby_npcs = get_available_npcs()
	
	if not nearby_npcs.is_empty() and randf() < 0.75:
		target_npc = nearby_npcs.pick_random()
		target_pos = target_npc.global_position
	else:
		target_npc = null
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
	if is_instance_valid(target_npc):
		if target_npc.current_state not in [State.WANDERING, State.IDLE]:
			# Target NPC became busy, give up and pick a new target
			target_npc = null
			pick_target()
			return
		target_pos = Vector3(target_npc.global_position.x, global_position.y, target_npc.global_position.z)

	var target_flat = Vector3(target_pos.x, global_position.y, target_pos.z)
	var direction = global_position.direction_to(target_flat)
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	var current_flat = Vector3(global_position.x, 0, global_position.z)
	var target_flat_pos = Vector3(target_pos.x, 0, target_pos.z)
	
	# If we are seeking an NPC and got close enough, start conversation
	if is_instance_valid(target_npc):
		if current_flat.distance_to(target_flat_pos) < 1.5:
			velocity.x = 0.0
			velocity.z = 0.0
			var partner = target_npc
			target_npc = null
			start_npc_conversation(partner)
	else:
		
		if current_flat.distance_to(target_flat_pos) < 0.2:
			velocity.x = 0.0
			velocity.z = 0.0
			action_decision()

func handle_idle(delta: float) -> void:
	timer -= delta
	velocity.x = 0.0
	velocity.z = 0.0
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
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	var current_flat = Vector3(global_position.x, 0, global_position.z)
	var plant_flat_pos = Vector3(plant_node.global_position.x,0, plant_node.global_position.z)
	
	if current_flat.distance_to(plant_flat_pos) < 1.0:
		velocity.x = 0.0
		velocity.z = 0.0
		
		current_state = State.ATPLANT
		plant_node.water_plant()
		give_seeds()
		
		var pause_timer = get_tree().create_timer(randf_range(2,3))
		pause_timer.timeout.connect(done_interacting)

func handle_trading() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	
	hand_sprite_3d.visible = true

func start_npc_conversation(partner: Npc) -> void:
	conversation_partner = partner
	current_state = State.INTERACTING_WITH_NPC
	is_initiator = true
	turns_remaining = conversation_turns
	
	# Force partner into interaction state as well
	partner.conversation_partner = self
	partner.current_state = State.INTERACTING_WITH_NPC
	partner.is_initiator = false
	partner.turns_remaining = conversation_turns
	
	# Initiator starts the conversation turn immediately
	show_random_symbol_turn()
	
func handle_interacting_with_npc() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	
func show_random_symbol_turn() -> void:
	if current_state != State.INTERACTING_WITH_NPC:
		return
	if symbol_list.is_empty():
		end_conversation()
		return
	var random_tex = symbol_list.pick_random()
	if symbol_sprite:
		symbol_sprite.texture = random_tex
		symbol_sprite.scale = base_symbol_scale
	dialogue_bubble.visible = true
	
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	
	dialogue_tween = create_tween()
	dialogue_bubble.scale = Vector3.ZERO
	
		
	dialogue_tween.tween_property(dialogue_bubble, "scale", base_bubble_scale * 1.1, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dialogue_tween.tween_property(dialogue_bubble, "scale", base_bubble_scale, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	
	dialogue_tween.tween_interval(symbol_display_duration)

	dialogue_tween.tween_property(dialogue_bubble, "scale", Vector3.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	dialogue_tween.tween_callback(func():
		dialogue_bubble.visible = false
		_on_symbol_turn_finished()
	)
	
func _on_symbol_turn_finished() -> void:
	turns_remaining -= 1
	if turns_remaining <= 0 or not is_instance_valid(conversation_partner):
		end_conversation()
	else:
		# Pass the turn to the partner after a short randomized texting delay 
		var delay = randf_range(0.5, 0.75)
		get_tree().create_timer(delay).timeout.connect(func():
			if is_instance_valid(conversation_partner) and current_state == State.INTERACTING_WITH_NPC:
				conversation_partner.show_random_symbol_turn()
		)
	
func end_conversation() -> void:
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	if dialogue_bubble:
		dialogue_bubble.visible = false
		dialogue_bubble.scale = Vector3.ZERO
		
	var partner = conversation_partner
	conversation_partner = null
	is_on_cooldown = true
	
	# Start cooldown timer
	get_tree().create_timer(conversation_cooldown).timeout.connect(func():
		is_on_cooldown = false
	)
	if is_instance_valid(partner) and partner.current_state == State.INTERACTING_WITH_NPC:
		partner.conversation_partner = null
		partner.is_on_cooldown = true
		get_tree().create_timer(conversation_cooldown).timeout.connect(func():
			partner.is_on_cooldown = false
		)
		partner.pick_target()
		partner.current_state = State.WANDERING
		
	pick_target()
	current_state = State.WANDERING

func done_interacting() -> void:
	hand_sprite_3d.visible= false
	plant_node = null
	pick_target()
	current_state = State.WANDERING
	
func give_seeds() -> void:
	
	var sprite = plant_node.get_node("Sprite") as Sprite3D
	var texture_path = sprite.texture.resource_path
	var file_name = texture_path.get_file().get_basename()
	
	var world_node = get_tree().current_scene
	var seeds_to_give = randi_range(0, 2)
	
	world_node.add_plant_to_inventory(file_name, seeds_to_give)
	world_node.attempt_to_select_what_to_plant(file_name)

func squash_and_stretch(delta:float) -> void:
	if velocity.length_squared() > 0.1 and current_state != State.IDLE:
		walk_anim_time += delta * bounce_frequency
		
		#sine wave for stretching 
		var stretch = sin(walk_anim_time) * stretch_amount
		
		sprite_3d.scale.y = base_sprite_scale.y * (1.0 + stretch)
		sprite_3d.scale.x = base_sprite_scale.x * (1.0 - stretch * 0.5)
		sprite_3d.scale.z = base_sprite_scale.x * (1.0 - stretch * 0.5)
	else:
		walk_anim_time = 0.0
		sprite_3d.scale = sprite_3d.scale.lerp(base_sprite_scale, delta * 12.0)
