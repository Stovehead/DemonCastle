extends Node

@onready var pause_sound = $AudioStreamPlayer

func _physics_process(_delta: float) -> void:
	if(Input.is_action_just_pressed("start") && Globals.current_player.player_has_control && Globals.current_player.can_move_horizontally && !Globals.current_player.is_dead && !Globals.game_instance.full_blackout.visible && !Globals.game_instance.blackout.visible):
		if(!get_tree().paused):
			pause_sound.play()
			Globals.game_instance.pause_game()
