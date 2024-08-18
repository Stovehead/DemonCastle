extends Node2D

@export var despawn_range = Vector2(240, 156)
var camera_position:Vector2

func _physics_process(delta: float) -> void:
	camera_position = Globals.game_instance.camera.get_screen_center_position()
	if(abs(camera_position.x - global_position.x) > despawn_range.x || abs(camera_position.y - global_position.y) > despawn_range.y):
		get_parent().queue_free()
