extends CharacterBody2D

const DESPAWN_THRESHOLD:int = 200
@onready var gravity_component:GravityComponent = $GravityComponent

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	move_and_slide()
