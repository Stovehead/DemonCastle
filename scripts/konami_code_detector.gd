extends Node

const KONAMI_CODE:String = "uuddlrlrba"
const INPUTS:Dictionary = {
	"up": 'u',
	"down": 'd',
	"left": 'l',
	"right": 'r',
	"jump": 'a',
	"attack": 'b'
}

var progress:int = 0

func _physics_process(_delta: float) -> void:
	if(Globals.entered_konami_code):
		return
	for key in INPUTS:
		if(progress >= KONAMI_CODE.length()): break
		var value = INPUTS[key]
		if(value is String && key is String):
			if(Input.is_action_just_pressed(key)):
				if(KONAMI_CODE[progress] == value):
					progress += 1
				elif(KONAMI_CODE[0] == value):
					progress = 1
				else:
					progress = 0
	if(progress >= KONAMI_CODE.length()):
		Globals.entered_konami_code = true
		SfxManager.play_sound_effect(SfxManager.ONE_UP)
		progress = 0
