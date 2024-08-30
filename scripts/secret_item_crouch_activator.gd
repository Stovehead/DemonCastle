extends SecretItemActivator

func has_met_spawn_condition() -> bool:
	if(!is_instance_valid(secret_item_spawner)):
		return false
	if(!is_instance_valid(Globals.current_player)):
		return false
	if(!has_overlapping_areas()):
		return false
	if(!Globals.current_player.is_on_floor() || !Globals.current_player.player_has_control || !Globals.current_player.is_crouching):
		return false
	return true
