extends Upgrade

const NUM_ADDED_HEARTS:int = 5

func do_upgrade(player:Player):
	player.num_hearts += NUM_ADDED_HEARTS
	player.hearts_changed.emit(player.num_hearts)
	SfxManager.play_sound_effect(SfxManager.HEART)
	get_parent().queue_free()
