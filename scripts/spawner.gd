extends Node2D

const SPAWN_DISTANCE:Vector2 = Vector2(224, 140)

var child:InstancePlaceholder
var current_instance:Node2D
var last_camera_position:Vector2
var current_camera_position:Vector2

@export var create_once:bool = false
@export var stop_spawning_upon_death:bool = true

func _ready() -> void:
	if(get_child_count(false) > 0):
		child = get_children(false)[0]
	last_camera_position = Globals.game_instance.camera.get_screen_center_position()
	if(is_instance_valid(child)):
		if(within_camera_range(last_camera_position)):
			spawn()

func _physics_process(delta: float) -> void:
	current_camera_position = Globals.game_instance.camera.get_screen_center_position()
	if(!is_instance_valid(current_instance) && !within_camera_range(last_camera_position) && within_camera_range(current_camera_position)):
		spawn()
	last_camera_position = current_camera_position

func within_camera_range(camera_position:Vector2):
	return abs(camera_position.x - global_position.x) < SPAWN_DISTANCE.x && abs(camera_position.y - global_position.y) < SPAWN_DISTANCE.y

func spawn():
	if(child is InstancePlaceholder):
		current_instance = child.create_instance(false)
		if(create_once):
			set_script(null)
		elif(current_instance.has_signal("died") && stop_spawning_upon_death):
			current_instance.connect("died", _on_instance_died)

func _on_instance_died():
	set_script(null)
