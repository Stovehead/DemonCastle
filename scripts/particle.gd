class_name Particle
extends CharacterBody2D

@onready var gravity_component:GravityComponent = $GravityComponent
@onready var sprite:Sprite2D = $Sprite2D

var gravity_enabled:bool = true

func _physics_process(delta: float) -> void:
	if(gravity_enabled):
		velocity = gravity_component.apply_gravity(velocity, delta)
	move_and_slide()
