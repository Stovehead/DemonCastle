extends Node2D

@export var despawn_range = Vector2(240, 156)
var camera_position:Vector2

func _physics_process(_delta: float) -> void:
	if(is_instance_valid(Globals.game_instance)):
		camera_position = Globals.game_instance.camera.get_screen_center_position()
		var is_camera_in_range:bool = abs(camera_position.x - global_position.x) < despawn_range.x && abs(camera_position.y - global_position.y) < despawn_range.y
		var is_parent_processing:bool = get_parent().can_process()
		if(!is_camera_in_range && is_parent_processing):
			get_parent().queue_free()
