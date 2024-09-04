class_name BatSpawner
extends Node

const TIME_INTERVAL:float = 6.4
const FAST_TIME_INTERVALS:Array[float] = [1.0, 3.0, 5.0]
const SPAWN_HEIGHT:float = 8.0
const HORIZONTAL_MARGIN:float = 64.0

@onready var spawn_timer:Timer = $SpawnTimer
@onready var bat_scene:PackedScene = preload("res://scenes/bat.tscn")

@export var radius:float = 200.0
@export var max_num_bats:int = 1
@export var valid_spawn_range:Vector2 = Vector2(0, 0)

var num_bats:int = 0
var screen_half_width:float = 0

func is_in_range(camera_position:Vector2) -> bool:
	if(valid_spawn_range.x == 0 && valid_spawn_range.y == 0):
		return true
	if(is_instance_valid(Globals.game_instance)):
		camera_position -= Globals.game_instance.current_stage.global_position
	return camera_position.x >= valid_spawn_range.x && camera_position.x <= valid_spawn_range.y

func _ready() -> void:
	if(is_instance_valid(Globals.game_instance)):
		screen_half_width = Globals.game_instance.get_viewport_rect().size.x/2.0
		if(Globals.game_instance.hard_mode):
			max_num_bats += 1
	if(num_bats < max_num_bats):
		spawn_timer.start()

func _on_bat_died() -> void:
	num_bats -= 1

func _on_spawn_timer_timeout() -> void:
	if(!is_instance_valid(Globals.game_instance)):
		return
	if(!is_instance_valid(Globals.current_player)):
		return
	var screen_center_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	if(!is_in_range(screen_center_position)):
		return
	var player_y:float = Globals.current_player.global_position.y
	var player_direction:float = Globals.current_player.player_direction
	var new_bat:Bat = bat_scene.instantiate()
	new_bat.direction = -player_direction
	if(screen_half_width != 0):
		var player_position:Vector2 = Globals.current_player.global_position
		if(player_position.x < screen_center_position.x - screen_half_width + HORIZONTAL_MARGIN):
			new_bat.direction = -1
		elif(player_position.x > screen_center_position.x + screen_half_width - HORIZONTAL_MARGIN):
			new_bat.direction = 1
	new_bat.died.connect(_on_bat_died)
	num_bats += 1
	add_sibling(new_bat)
	new_bat.global_position = Vector2(screen_center_position.x + radius * new_bat.direction * -1, player_y - SPAWN_HEIGHT)
	new_bat.initial_position = new_bat.global_position
	if(num_bats >= max_num_bats):
		spawn_timer.start(TIME_INTERVAL)
	else:
		spawn_timer.start(FAST_TIME_INTERVALS.pick_random())
