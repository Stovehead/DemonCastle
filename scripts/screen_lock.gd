class_name ScreenLock
extends VisibleOnScreenNotifier2D

@export var direction:int = 1

signal screen_locked

func _on_screen_entered():
	var viewport_rect:Rect2 = get_viewport_rect()
	if(direction == 1):
		Globals.game_instance.camera.limit_left = Globals.game_instance.camera.limit_right - viewport_rect.size.x
	else:
		Globals.game_instance.camera.limit_right = Globals.game_instance.camera.limit_left + viewport_rect.size.x
	screen_locked.emit()
