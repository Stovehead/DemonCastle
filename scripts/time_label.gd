extends Label

func _time_changed(new_time:int):
	text = "TIME " + "%04d" % clamp(new_time, 0, 9999)
