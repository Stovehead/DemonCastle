class_name DraculaFireballSpawner
extends Node2D

const FIREBALL_H_SPEED:float = 120.0
const FIREBALL_DAMAGE:int = 4
const MAX_PARALLEL_ANGLE:float = PI/4

@onready var fireball_scene:PackedScene = preload("res://scenes/fireball.tscn")

@export var separation_angle:float = PI/20.0

func spawn_fireball(angle:float) -> void:
	var new_fireball:Fireball = fireball_scene.instantiate()
	var vector_to_target = Vector2(cos(angle), sin(angle))
	if((angle > 2*PI-MAX_PARALLEL_ANGLE && angle < MAX_PARALLEL_ANGLE) || (angle > PI/2 * MAX_PARALLEL_ANGLE && angle < 3*PI/2 - MAX_PARALLEL_ANGLE)):
		vector_to_target *= abs(FIREBALL_H_SPEED / vector_to_target.x)
	else:
		vector_to_target *= FIREBALL_H_SPEED
	new_fireball.velocity = vector_to_target
	new_fireball.direction = -1 if angle > PI/2 && angle < 3*PI/2 else 1
	new_fireball.damage = FIREBALL_DAMAGE
	get_parent().add_sibling(new_fireball)
	new_fireball.global_position = global_position

func spawn_fireballs(target:Vector2) -> void:
	var angle_to_target = global_position.angle_to_point(target)
	spawn_fireball(angle_to_target)
	spawn_fireball(angle_to_target - separation_angle)
	spawn_fireball(angle_to_target + separation_angle)
