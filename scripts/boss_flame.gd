extends Sprite2D

func _on_despawn_timer_timeout() -> void:
	queue_free()
