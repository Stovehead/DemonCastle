extends VisibleOnScreenNotifier2D

func _on_screen_entered():
	var current_camera_pos:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	var viewport_rect:Rect2 = get_viewport_rect()
	if(abs(current_camera_pos.x + viewport_rect.size.x/2 - Globals.game_instance.camera.limit_right) < abs(current_camera_pos.x - viewport_rect.size.x/2 - Globals.game_instance.camera.limit_left)):
		Globals.game_instance.camera.limit_left = current_camera_pos.x - viewport_rect.size.x/2
	else:
		Globals.game_instance.camera.limit_right = current_camera_pos.x + viewport_rect.size.x/2
