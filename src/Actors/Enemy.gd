extends "res://src/Actors/Actor.gd"

onready var collision_shape_2d: = $CollisionShape2D

func _ready():
	set_physics_process(false)
	_velocity.x = -speed.x
	
func _on_StompDetector_body_entered(body):
	if body.global_position.y > get_node("StompDetector").global_position.y:
		return
	
	hide()
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()
	
func _physics_process(delta):
	_velocity.y += gravity * delta
	
	if is_on_wall():
		_velocity.x *= -1.0
		
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y
