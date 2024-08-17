extends Node

@onready var pause_sound = $AudioStreamPlayer

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("start") && Globals.current_player.player_has_control && !Globals.current_player.is_dead):
		if(get_tree().paused):
			get_tree().paused = false
			Globals.game_instance.music_player.stream_paused = false
			ShaderTime.time_scale = 1
		else:
			get_tree().paused = true
			Globals.game_instance.music_player.stream_paused = true
			pause_sound.play()
			ShaderTime.time_scale = 0
