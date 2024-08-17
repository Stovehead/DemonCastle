extends Upgrade

func do_upgrade(player:Player):
	player.num_hearts += 5
	player.hearts_changed.emit(player.num_hearts)
	SfxManager.play_sound_effect(SfxManager.HEART)
	get_parent().queue_free()
