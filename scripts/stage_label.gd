extends Label

func _ready():
	Globals.game_instance.connect("stage_changed", update_label)

func update_label(new_stage:Stage):
	text = "STAGE " + "%02d" % new_stage.stage_number
