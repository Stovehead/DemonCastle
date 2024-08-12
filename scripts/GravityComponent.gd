extends Node

const GRAVITY:float = 500;

func apply_gravity(velocity:Vector2, delta:float) -> Vector2:
	velocity.y += GRAVITY * delta
	return velocity
