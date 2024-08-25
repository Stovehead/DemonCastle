extends Upgrade

const HP_INCREASE_AMOUNT:int = 6

func do_upgrade(player:Player) -> void:
	player.health_component._increase_hp(HP_INCREASE_AMOUNT)
	player.hp_changed.emit(player.health_component.remaining_hp)
	SfxManager.play_sound_effect(SfxManager.HEART)
	get_parent().queue_free()
