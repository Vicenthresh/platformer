extends Actor

export var stomp_impulse: = 1000.0

onready var animation_player: = $AnimationPlayer
onready var sprite: = $player
onready var collision_shape_2d: = $CollisionShape2D

var max_running_speed: = 2000
var max_falling_vel = 800
var stopping_friction = 0.6
var running_friction = 0.9
var jumps_left = 2

var dash_direction = Vector2(1,0)
var can_dash = false
var dashing = false

func _on_EnemyDetector_area_entered(area):
	new_velocity.y = -impulse

func _on_EnemyDetector_body_entered(body):
	hide()  # Player disappears after being hit.
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()

func _physics_process(delta):
    get_input(delta)
    gravity()
    friction()
	
    _velocity = move_and_slide(_velocity, FLOOR_NORMAL)
		
    var animation = get_animation()
    animation_player.play(animation)

func get_input(delta):
    # Run
    if Input.is_action_pressed("right"):
        dash_direction = Vector2(1,0)
	    _velocity.x += speed.x
    if Input.is_action_pressed("left"):
        dash_direction = Vector2(-1,0)
	    _velocity.x -= speed.x
    
    # Jump
    if Input.is_action_just_pressed("jump") and jumps_left > 0:
        if is_falling():
            _velocity.y = 0.0

        _velocity.y -= speed.y
        jumps_left -= 1

        if Input.is_action_just_released("jump") and !is_falling():
            _velocity.y = 0.0
    
    # Dash
    if is_on_floor():
        can_dash = true
    
    if Input.is_action_just_pressed("dash") and can_dash:
        _velocity = dash_direction.normalized() * max_running_speed
        can_dash = false
        dashing = true # turn off gravity while dashing
        yield(get_tree().create_timer(0.5), "timeout")
        dashing = false

func gravity():
	if not dashing:
		_velocity.y += gravity

    _velocity.y = min(_velocity.y,  max_falling_vel)

	if next_to_wall() and vel.y > 100: 
		_velocity.y = min(_velocity.y,  100)
        
func friction():
	# When I hold the key
	var running = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	if not running and is_on_floor():
		_velocity.x *= stopping_friction
	else:
		_velocity.x *= running_friction

func is_falling():
    return _velocity.y > 0.0	

func get_animation():
	var animation: = ""

	if _velocity.x != 0.0:
        if _velocity.x > 0:
            sprite.set_flip_h(false)
        else:
            sprite.set_flip_h(true)
		animation = "walk"
	else:
		animation ="idle"
		
	return animation
