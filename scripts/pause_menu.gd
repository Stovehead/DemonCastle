class_name PauseMenu
extends Menu

func _process(_delta: float) -> void:
	if(!Globals.game_instance.game_paused):
		return
	super._process(_delta)
	update_cursor()

func _on_continue():
	Globals.game_instance.unpause_game()

func _on_end():
	Globals.game_instance.unpause_game()
	Globals.game_instance.return_to_title()
	current_selection = default_selection
