extends Node

@onready var pause_sound = $AudioStreamPlayer

func unpause() -> void:
	get_tree().paused = false
	Globals.game_instance.unpause_music()
	ShaderTime.time_scale = 1

func pause() -> void:
	get_tree().paused = true
	Globals.game_instance.pause_music()
	pause_sound.play()
	ShaderTime.time_scale = 0

func _physics_process(_delta: float) -> void:
	if(Input.is_action_just_pressed("start") && Globals.current_player.player_has_control && !Globals.current_player.is_dead):
		if(get_tree().paused):
			unpause()
		else:
			pause()
