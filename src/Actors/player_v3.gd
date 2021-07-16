extends "res://src/Actors/Actor.gd"

export var stomp_impulse: = 1000.0

onready var collision_shape_2d: = $CollisionShape2D
onready var animated_sprite: = $AnimatedSprite

var max_running_speed: = 2000
var max_falling_vel: = 2000

var stopping_friction: = 0.6
var running_friction: = 0.9
var jumps_left: = 2

var dash_direction = Vector2(1,0)
var can_dash = false
var dashing = false

# warning-ignore:unused_argument
func _on_EnemyDetector_area_entered(area):
	_velocity.y = -stomp_impulse

# warning-ignore:unused_argument
func _on_EnemyDetector_body_entered(body):
	hide()  # Player disappears after being hit.
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()

func _physics_process(delta):
	get_input(delta)
	jump()
	dash()
	gravity()
	friction()
	
	var animation = get_animation()
	animated_sprite.animation = animation
	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

# warning-ignore:unused_argument
func get_input(delta):
# Run
	if Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = false
		dash_direction = Vector2(1,0)
		_velocity.x += speed.x
	if Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = true
		dash_direction = Vector2(-1,0)
		_velocity.x -= speed.x

func jump():
	if is_on_floor():
		jumps_left = 2
		
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		# Jump cancels zero gravity
		dashing = false
		jumps_left -= 1
		
		if is_falling() or jumps_left == 0:
			_velocity.y = 0.0
		
		_velocity.y -= speed.y
		
		if Input.is_action_just_released("jump") and _velocity.y < 0.0:
			_velocity.y = 0.0

func dash():
	if is_on_floor():
		can_dash = true
		
	if Input.is_action_just_pressed("dash") and can_dash:
		_velocity = dash_direction.normalized() * max_running_speed
		can_dash = false
		dashing = true # turn off gravity while dashing
		yield(get_tree().create_timer(0.3), "timeout")
		dashing = false

func gravity():
	if not dashing:
		_velocity.y += gravity

	_velocity.y = min(_velocity.y,  max_falling_vel)

	#if next_to_wall() and vel.y > 100: 
		#_velocity.y = min(_velocity.y,  100)
		
func friction():
	# When I hold the key
	var running = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	
	if not running and is_on_floor():
		_velocity.x *= stopping_friction
	else:
		_velocity.x *= running_friction

func is_falling():
	return _velocity.y > 0.0	

func get_animation():
	var animation: = ""
	
	animation = "idle"
	
	var walking = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	
	if is_on_floor():
		if walking:
			animation = "run"
	elif is_falling():
		animation = "fall"
	elif !is_falling() and jumps_left > 0:
		animation = "jump"
	else:
		animation = "air_jump"
		
	return animation
