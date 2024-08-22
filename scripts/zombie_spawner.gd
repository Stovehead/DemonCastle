extends Node2D

const ZOMBIE_HALF_HEIGHT:float = 16
const SPAWN_TIME_RANGE:Vector2 = Vector2(1, 2)
const MAX_ZOMBIES:int = 5

var ray_left:RayCast2D
var ray_right:RayCast2D

@onready var zombie:PackedScene = preload("res://scenes/zombie.tscn")
@onready var spawn_timer:Timer = $SpawnTimer

@export var horizontal_range:float = 200
@export var top:float = -32
@export var bottom:float = 108

func init_rays() -> void:
	ray_left = RayCast2D.new()
	ray_right = RayCast2D.new()
	add_child(ray_right)
	add_child(ray_left)
	ray_right.position.x = horizontal_range
	ray_left.position.x = -horizontal_range
	ray_right.position.y = top
	ray_left.position.y = top
	ray_right.target_position.x = 0
	ray_left.target_position.x = 0
	ray_right.target_position.y = bottom - top
	ray_left.target_position.y = bottom - top
	ray_right.set_collision_mask_value(1, false)
	ray_right.set_collision_mask_value(2, true)
	ray_left.set_collision_mask_value(1, false)
	ray_left.set_collision_mask_value(2, true)

func is_valid_spawn(ray:RayCast2D) -> bool:
	return ray.is_colliding() && ray.get_collision_point().y > top - ZOMBIE_HALF_HEIGHT && ray.get_collision_point().x > Globals.game_instance.current_stage.position.x + Globals.game_instance.current_stage.left_limit && ray.get_collision_point().x < Globals.game_instance.current_stage.position.x + Globals.game_instance.current_stage.right_limit 

func spawn(spawn_position:Vector2):
	var new_zombie:Zombie = zombie.instantiate()
	add_sibling(new_zombie)
	new_zombie.global_position = spawn_position - Vector2(0, ZOMBIE_HALF_HEIGHT)
	new_zombie.orient_towards_player()

func _ready() -> void:
	init_rays()
	spawn_timer.start(randf_range(SPAWN_TIME_RANGE.x, SPAWN_TIME_RANGE.y))

func _physics_process(delta: float) -> void:
	if(is_instance_valid(Globals.game_instance)):
		global_position = Globals.game_instance.camera.get_screen_center_position()

func _on_spawn_timer_timeout() -> void:
	if(Globals.num_zombies < MAX_ZOMBIES):
		var right_ray_valid:bool = is_valid_spawn(ray_right)
		var left_ray_valid:bool = is_valid_spawn(ray_left)
		if(right_ray_valid && !left_ray_valid):
			spawn(ray_right.get_collision_point())
		elif(!right_ray_valid && left_ray_valid):
			spawn(ray_left.get_collision_point())
		elif(right_ray_valid && left_ray_valid):
			var random_selection:int = randi_range(0, 1)
			if(random_selection == 0):
				spawn(ray_right.get_collision_point())
			else:
				spawn(ray_left.get_collision_point())
	spawn_timer.start(randf_range(SPAWN_TIME_RANGE.x, SPAWN_TIME_RANGE.y))
