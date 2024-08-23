extends Upgrade

func do_upgrade(player:Player):
	player.health_component._increase_hp(6)
	player.hp_changed.emit(player.health_component.remaining_hp)
	SfxManager.play_sound_effect(SfxManager.HEART)
	get_parent().queue_free()
