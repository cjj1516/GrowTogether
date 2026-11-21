extends CharacterBody2D

@export var speed: float = 80.0
@export var min_move_time: float = 1.5
@export var max_move_time: float = 3.0
@export var min_pause_time: float = 1.0
@export var max_pause_time: float = 2.5
@export var screen_margin: float = 30.0 

@onready var body_sprite: Sprite2D = $GreenGuy
@onready var carried: Control = $Button 

enum State { IDLE, WALK }
var current_state: State = State.IDLE
var move_direction: float = 0.0
var timer: float = 0.0
var time_passed: float = 0.0
var original_carried_pos_y: float = 0.0

func _ready() -> void:
	randomize()
	_change_state()

func _enter_tree() -> void:
	
	if has_node("Button"):
		original_carried_pos_y = $Button.position.y
	

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		_change_state()

	
	if current_state == State.WALK:
		velocity.x = move_direction * speed
		
		
		time_passed += delta * 14.0
		var squash = sin(time_passed) * 0.12
		body_sprite.scale.x = (1.0 + squash) * sign(move_direction) if move_direction != 0 else (1.0 + squash)
		body_sprite.scale.y = 1.0 - squash
		
		carried.position.y = original_carried_pos_y + (sin(time_passed * 2.0) * 1.5)
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		
		
		body_sprite.scale = body_sprite.scale.lerp(Vector2(sign(body_sprite.scale.x) if body_sprite.scale.x != 0 else 1.0, 1.0), delta * 10.0)
		time_passed = 0.0
		carried.position.y = original_carried_pos_y

	move_and_slide()

	
	var viewport_width = get_viewport_rect().size.x
	if global_position.x < screen_margin:
		global_position.x = screen_margin
		move_direction = 1.0  
	elif global_position.x > viewport_width - screen_margin:
		global_position.x = viewport_width - screen_margin
		move_direction = -1.0 

func _change_state() -> void:
	if current_state == State.IDLE:
		
		current_state = State.WALK
		move_direction = [-1, 1].pick_random()
		timer = randf_range(min_move_time, max_move_time)
	else:
		
		current_state = State.IDLE
		move_direction = 0.0
		timer = randf_range(min_pause_time, max_pause_time)
