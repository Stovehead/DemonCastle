extends Label

func update_label(new_stage:Stage):
	var stage_number:int = new_stage.stage_number
	if(Globals.game_instance.hard_mode):
		stage_number += Game.FINAL_STAGE_NUMBER + 1
	if(stage_number <= 0):
		stage_number = 1
	text = "STAGE " + "%02d" % stage_number
