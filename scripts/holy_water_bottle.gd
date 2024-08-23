class_name Bottle
extends CharacterBody2D

@onready var gravity_component:GravityComponent = $GravityComponent

signal hit_ground(hit_position:Vector2)

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	move_and_slide()
	if(is_on_floor() || is_on_wall()):
		hit_ground.emit(global_position)
		queue_free()
