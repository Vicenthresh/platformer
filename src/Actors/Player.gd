extends Actor

export var stomp_impulse: = 1000.0

onready var collision_shape_2d: = $CollisionShape2D
onready var dash_timer:= $DashTimer
onready var dash_cd_timer:= $DashCd

var wall_jump_velocity: = Vector2(-4.0, -1.0)
var max_speed: = 2000
var dash_cd = false

func _on_EnemyDetector_area_entered(area):
	_velocity = calculate_stomp_velocity(_velocity, stomp_impulse)

func _on_EnemyDetector_body_entered(body):
	hide()  # Player disappears after being hit.
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()

func _on_DashTimer_timeout():
	speed.x = 700
	speed.y = 1200
	gravity = 3000
	collision_shape_2d.set_deferred("disabled", false)

func _on_DashCd_timeout():
	dash_cd = false

func _physics_process(delta):
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var is_dashing: = false
	var direction: = get_direction()
	
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	
	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

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
	
	if Input.is_action_just_pressed("dash") and not dash_cd:
		speed.x *= 4.0
		speed.y = 0.0
		gravity = 0.0
		
		dash_cd = true
		dash_timer.start()
		dash_cd_timer.start()
		
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
