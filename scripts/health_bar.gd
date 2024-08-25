extends MarginContainer

@export var timer:Timer
@export var remaining_hp:TextureRect

var displayed_hp:int = 16
var current_hp:int = 16

func _hp_changed(new_hp:int, instant:bool) -> void:
	current_hp = new_hp
	if(instant):
		displayed_hp = current_hp
		remaining_hp.custom_minimum_size.x = max(displayed_hp * 4, 0)
		return
	if(timer.is_stopped()):
		timer.start()

func _update_hp_display() -> void:
	if(displayed_hp > current_hp):
		displayed_hp -= 1
	elif(displayed_hp < current_hp):
		displayed_hp += 1
	remaining_hp.custom_minimum_size.x = max(displayed_hp * 4, 0)
	if(displayed_hp == current_hp):
		timer.stop()
