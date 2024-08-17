extends Node

@export var pauser:Node
@export var whip:Whip
@onready var timer:Timer = $Timer

func do_whip_upgrade_animation():
	SfxManager.process_mode = Node.PROCESS_MODE_ALWAYS
	SfxManager.play_sound_effect(SfxManager.WHIP_UPGRADE)
	pauser.process_mode = Node.PROCESS_MODE_DISABLED
	Globals.current_player.sprite.use_parent_material = true
	get_tree().paused = true
	timer.start()


func _on_timer_timeout() -> void:
	SfxManager.process_mode = Node.PROCESS_MODE_INHERIT
	pauser.process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.current_player.sprite.use_parent_material = false
	whip.current_level += 1
	Globals.current_player.whip_level_changed.emit(whip.current_level)
	get_tree().paused = false
