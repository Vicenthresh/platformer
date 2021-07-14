extends Actor

export var stomp_impulse: = 1000.0

func _on_EnemyDetector_area_entered(area):
	_velocity = calculate_stomp_velocity(_velocity, stomp_impulse)

func _on_EnemyDetector_body_entered(body):
	queue_free()
	
func _physics_process(delta):
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

func get_direction() -> Vector2:
	return  Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 0.0
	)

func calculate_move_velocity(	
	linear_velocity: Vector2, 
	direction: Vector2, 
	speed: Vector2,
	is_jump_interrupted: bool) -> Vector2:
		var new_velocity: = linear_velocity
		new_velocity.x = speed.x * direction.x
		new_velocity.y += gravity * get_physics_process_delta_time()
		
		if direction.y == -1.0:
			new_velocity.y = speed.y * direction.y
		if not is_on_floor() and direction.y == 1.0:
			new_velocity.x *= 0.7
		if is_jump_interrupted:
			new_velocity.y = 0.0
			
		return new_velocity

func calculate_stomp_velocity(linear_velocity: Vector2, impulse: float) -> Vector2:
	var new_velocity: = linear_velocity
	new_velocity.y = -impulse
	return new_velocity
