extends Node2D

@onready var credits_music:AudioStream = preload("res://media/music/voyager.ogg")

func play_music() -> void:
	if(!is_instance_valid(Globals.game_instance)):
		return
	Globals.game_instance.music_player.stream = credits_music
	Globals.game_instance.music_player.play()
