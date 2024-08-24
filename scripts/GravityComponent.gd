class_name GravityComponent
extends Node

const GRAVITY:float = 500;

func apply_gravity(velocity:Vector2, delta:float) -> Vector2:
	velocity.y += GRAVITY * delta
	return velocity

func apply_gravity_with_terminal_velocity(velocity:Vector2, terminal_velocity:float, delta:float) -> Vector2:
	var new_velocity:Vector2 = apply_gravity(velocity, delta)
	new_velocity.y = min(new_velocity.y, terminal_velocity)
	return new_velocity
