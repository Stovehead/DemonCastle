extends Label

func _lives_changed(new_lives:int):
	text = "P-" + "%02d" % clamp(new_lives, 0, 99)
