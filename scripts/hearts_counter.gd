extends Label

func _hearts_changed(new_hearts:int) -> void:
	text = "-" + "%02d" % clamp(new_hearts, 0, 99)
