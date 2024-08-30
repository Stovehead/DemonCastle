class_name FallingObject
extends CharacterBody2D

@onready var gravity_component:GravityComponent = $GravityComponent
@onready var collision:CollisionShape2D = $CollisionShape2D
@onready var wall_detector:ShapeCast2D = $WallDetector
@onready var despawn_timer:Timer = $DespawnTimer
@export var despawn_on_hit_ground:bool = true
@export var gravity_enabled:bool = true


func _ready() -> void:
	if(is_instance_valid(wall_detector)):
		wall_detector.force_shapecast_update()

func _physics_process(delta: float) -> void:
	if(is_instance_valid(wall_detector)):
		if(wall_detector.is_colliding()):
			collision.disabled = true
		elif(collision.disabled):
				collision.disabled = false
	if(gravity_enabled):
		velocity = gravity_component.apply_gravity(velocity, delta)
		move_and_slide()
	if(is_on_floor() && despawn_on_hit_ground && despawn_timer.is_stopped()):
		despawn_timer.start()
