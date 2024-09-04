class_name DraculaFireballSpawner
extends Node2D

const FIREBALL_H_SPEED:float = 120.0
const FIREBALL_DAMAGE:int = 4
const MAX_PARALLEL_ANGLE:float = PI/3.0

@onready var fireball_scene:PackedScene = preload("res://scenes/fireball.tscn")

@export var separation_distance:float = 8.0
@export var min_separation_angle:float = PI/24.0
@export var min_angle:float = PI/32

func spawn_fireball(velocity:Vector2, angle:float, parallel:bool) -> void:
	var new_fireball:Fireball = fireball_scene.instantiate()
	var old_velocity_x:float = velocity.x
	var velocity_angle:float = velocity.angle()
	var velocity_magnitude:float = velocity.distance_to(Vector2.ZERO)
	velocity = Vector2.from_angle(velocity_angle + angle) * velocity_magnitude
	if(parallel):
		velocity.x = old_velocity_x
	new_fireball.velocity = velocity
	new_fireball.direction = sign(velocity.x)
	new_fireball.damage = FIREBALL_DAMAGE
	get_parent().add_sibling(new_fireball)
	new_fireball.global_position = global_position

func spawn_fireballs(target:Vector2) -> void:
	var angle_to_target = global_position.angle_to_point(target)
	if(angle_to_target > min_angle && angle_to_target < PI/2):
		angle_to_target = min_angle
	elif(angle_to_target < PI - min_angle && angle_to_target > PI/2):
		angle_to_target = PI - min_angle
	var fireball_velocity = Vector2(cos(angle_to_target), sin(angle_to_target)) * FIREBALL_H_SPEED
	var is_parallel:bool = !((angle_to_target < -PI/2 + MAX_PARALLEL_ANGLE && angle_to_target > -PI/2 - MAX_PARALLEL_ANGLE) || (angle_to_target > PI/2 - MAX_PARALLEL_ANGLE && angle_to_target < PI/2 + MAX_PARALLEL_ANGLE))
	var separation_angle:float = abs(global_position.angle_to_point(target + Vector2(0, separation_distance)) - angle_to_target)
	if(separation_angle < min_separation_angle):
		separation_angle = min_separation_angle
	spawn_fireball(fireball_velocity, 0, is_parallel)
	spawn_fireball(fireball_velocity, separation_angle, is_parallel)
	spawn_fireball(fireball_velocity, -separation_angle, is_parallel)
