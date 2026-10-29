extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# returns null
func screen_raycast(screen_pos: Vector2):
	# 1. Calculate the start (origin) and direction of the ray from the 2D screen position
	var origin: Vector3 = project_ray_origin(screen_pos)
	var direction: Vector3 = project_ray_normal(screen_pos)
	# extend ray arbitrarily far. in practice this should always hit something
	# if the player tried to click on something
	var end: Vector3 = origin + direction * 1000
	
	# 2. Create the query parameters
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	# 3. Access the 3D physics space state
	var space_state = get_world_3d().direct_space_state
	
	# Optional: Exclude certain physics layers or objects if needed
	# query.collision_mask = 1 
	
	# 4. Cast the ray
	var result: Dictionary = space_state.intersect_ray(query)
	
	# 5. Handle the result
	if not result.is_empty():
		var hit_object = result.collider
		var hit_position = result.position
		var hit_normal = result.position
		
		# Example: Interact with the object if it has a specific method
		if hit_object.has_method("on_clicked"):
			hit_object.on_clicked()
		
		return hit_position
	
	return null
