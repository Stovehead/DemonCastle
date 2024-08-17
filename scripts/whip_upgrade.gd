extends Upgrade

func _ready() -> void:
	Globals.game_instance.num_whip_upgrades += 1

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		Globals.game_instance.num_whip_upgrades -= 1

func do_upgrade(player:Player):
	player.whip_upgrade_pauser.do_whip_upgrade_animation()
	if(player.whip_level < 3):
		player.whip_level += 1
	get_parent().queue_free()
