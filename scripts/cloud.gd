extends Sprite2D

const SPEED:float = -7.5

func _physics_process(delta: float) -> void:
	position.x += SPEED * delta
