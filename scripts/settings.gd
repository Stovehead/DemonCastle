extends Node

signal language_changed

var current_language:String = "en":
	set(new_language):
		if(new_language != current_language):
			current_language = new_language
			language_changed.emit()
		
var music_volume:float = 100.0
var sfx_volume:float = 100.0
var window_scale:int = 1

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("debug")):
		if(current_language == "en"):
			current_language = "jp"
		else:
			current_language = "en"
