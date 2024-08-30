extends Upgrade

@export var subweapon_to_give:Player.Subweapons

func do_upgrade(player:Player):
	if(player.current_subweapon != subweapon_to_give):
		player.max_num_subweapons = 1
		player.max_subweapons_changed.emit(player.max_num_subweapons)
	player.current_subweapon = subweapon_to_give
	player.subweapon_changed.emit(player.current_subweapon)
	SfxManager.play_sound_effect(SfxManager.WHIP_UPGRADE)
	get_parent().queue_free()
