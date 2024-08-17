extends Timer

func _on_timeout() -> void:
	if(get_parent() != null):
		get_parent().queue_free()
	else:
		queue_free()
