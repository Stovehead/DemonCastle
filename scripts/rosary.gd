extends Upgrade

const FLASH_TIME:float = 0.4

@onready var screen_wipe = preload("res://scenes/screen_wipe.tscn")

func do_upgrade(player:Player):
	var camera_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	var new_screen_wipe:Hurtbox = screen_wipe.instantiate()
	get_parent().add_sibling.call_deferred(new_screen_wipe)
	new_screen_wipe.set_deferred("global_position", camera_position)
	SfxManager.play_sound_effect(SfxManager.ROSARY)
	Globals.game_instance.flash_screen(FLASH_TIME)
	get_parent().queue_free()
