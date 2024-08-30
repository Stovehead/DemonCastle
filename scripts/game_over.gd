extends Control

signal continue_game
signal end_game

var current_selection:int = 0

@export var heart:TextureRect

func _physics_process(_delta) -> void:
	if(Input.is_action_just_pressed("up") || Input.is_action_just_pressed("down")):
		SfxManager.play_sound_effect_no_overlap(SfxManager.SELECT)
		current_selection += 1
		if(current_selection > 1):
			current_selection = 0
		if(current_selection == 0):
			heart.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		else:
			heart.size_flags_vertical = Control.SIZE_SHRINK_END
	if(Input.is_action_just_pressed("start")):
		if(current_selection == 0):
			continue_game.emit()
		else:
			end_game.emit()

func reset() -> void:
	current_selection = 0
	heart.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
