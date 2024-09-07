extends Node

const KONAMI_CODE:String = "uuddlrlrba"
const INPUTS:Dictionary = {
	'u': ["ui_up", "up"],
	'd': ["ui_down", "down"],
	'l': ["ui_left", "left"],
	'r': ["ui_right", "right"],
	'b': ["b", "cancel", "ui_cancel"],
	'a': ["a", "accept", "ui_accept"],
}

var progress:int = 0

func _physics_process(_delta: float) -> void:
	if(Globals.entered_konami_code):
		return
	for key in INPUTS:
		if(progress >= KONAMI_CODE.length()): break
		var possible_inputs = INPUTS[key]
		var found_input:bool = false
		var button_pressed:bool = false
		for input in possible_inputs:
			if(Input.is_action_just_pressed(input)):
				button_pressed = true
				if(KONAMI_CODE[progress] == key):
					progress += 1
					found_input = true
					break
				elif(KONAMI_CODE[0] == key):
					progress = 1
					found_input = true
					break
		if(found_input):
			break
		elif(button_pressed):
			progress = 0
	if(progress >= KONAMI_CODE.length()):
		Globals.entered_konami_code = true
		SfxManager.play_sound_effect(SfxManager.ONE_UP)
		progress = 0
