extends CharacterBody2D

@onready var gravity_component:GravityComponent = $GravityComponent
@onready var despawn_timer:Timer = $DespawnTimer
@export var despawn_on_hit_ground:bool = true

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	move_and_slide()
	if(is_on_floor() && despawn_on_hit_ground && despawn_timer.is_stopped()):
		despawn_timer.start()
