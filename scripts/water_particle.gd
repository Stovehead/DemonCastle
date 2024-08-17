extends CharacterBody2D

const DESPAWN_THRESHOLD:int = 200
var initial_position:Vector2
@onready var gravity_component:GravityComponent = $GravityComponent

func _ready() -> void:
	initial_position = global_position

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	move_and_slide()
	if(global_position.y > initial_position.y + DESPAWN_THRESHOLD):
		queue_free()
