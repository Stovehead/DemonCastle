extends Label

func _score_changed(new_score:int):
	text = "SCORE-" + "%06d" % clamp(new_score, 0, 999999)
