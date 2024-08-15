extends Label

func update_label(new_stage:Stage):
	text = "STAGE " + "%02d" % new_stage.stage_number
