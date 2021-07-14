extends Actor

export var stomp_impulse: = 1000.0

onready var animation_player: = $AnimationPlayer
onready var sprite: = $player
onready var collision_shape_2d: = $CollisionShape2D

var wall_jump_velocity: = Vector2(-5.0, -1.0)

func _on_EnemyDetector_area_entered(area):
	_velocity = calculate_stomp_velocity(_velocity, stomp_impulse)

func _on_EnemyDetector_body_entered(body):
	hide()  # Player disappears after being hit.
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()
	
func _physics_process(delta):
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction: = get_direction()
	
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	
	if direction.x > 0:
		sprite.set_flip_h(false)
	elif direction.x < 0:
		sprite.set_flip_h(true)
		
	var animation = get_animation()
	animation_player.play(animation)
	

func get_direction() -> Vector2:
	var direction: = Vector2.ZERO
	
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			direction.y = -1.0
		elif is_on_wall():
			direction.x *= wall_jump_velocity.x 
			direction.y = wall_jump_velocity.y
		else:
			direction.y = 0.0
		   
	return direction

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
		elif direction.y == 1.0:
			new_velocity.x *= 0.7
			
		if is_jump_interrupted:
			new_velocity.y = 0.0
		
		if is_on_wall():
			var max_velocity = 200
			new_velocity.y = min(new_velocity.y, max_velocity)
			
		return new_velocity

func calculate_stomp_velocity(linear_velocity: Vector2, impulse: float) -> Vector2:
	var new_velocity: = linear_velocity
	new_velocity.y = -impulse
	return new_velocity

func get_animation():
	var animation: = ""
	
	if is_on_floor():
		if _velocity.x != 0.0:
			animation = "walk"
		else:
			animation ="idle"
	else:
		if _velocity.y > 0.0:
			animation = "falling"
		else:
			animation = "jumping"
		
	return animation
	
	
	
