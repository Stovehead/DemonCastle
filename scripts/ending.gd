class_name Ending
extends Node2D

signal credits_finished

@onready var credits_music:AudioStream = preload("res://media/music/voyager.ogg")

func play_castle_collapse_sound() -> void:
	SfxManager.play_sound_effect(SfxManager.CASTLE_COLLAPSE)

func play_music() -> void:
	if(!is_instance_valid(Globals.game_instance)):
		return
	Globals.game_instance.music_player.stream = credits_music
	Globals.game_instance.music_player.play()

func emit_credits_finished():
	credits_finished.emit()
