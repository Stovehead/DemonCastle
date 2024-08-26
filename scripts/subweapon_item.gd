extends Upgrade

@export var subweapon_to_give:Player.Subweapons

func do_upgrade(player:Player):
	player.current_subweapon = subweapon_to_give
	player.subweapon_changed.emit(player.current_subweapon)
	SfxManager.play_sound_effect(SfxManager.WHIP_UPGRADE)
	get_parent().queue_free()
