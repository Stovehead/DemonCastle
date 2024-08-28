extends Upgrade

func do_upgrade(player:Player):
	player.start_invincibility()
	get_parent().queue_free()
