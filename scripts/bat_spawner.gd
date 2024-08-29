class_name BatSpawner
extends Node

const TIME_INTERVAL:float = 6.4
const SPAWN_HEIGHT:float = 8.0

@onready var spawn_timer:Timer = $SpawnTimer
@onready var bat_scene:PackedScene = preload("res://scenes/bat.tscn")

@export var radius:float = 200.0
@export var max_num_bats:int = 2

var num_bats:int = 0

func _on_bat_died() -> void:
	num_bats -= 1

func _on_spawn_timer_timeout() -> void:
	if(num_bats >= max_num_bats):
		return
	if(!is_instance_valid(Globals.game_instance)):
		return
	if(!is_instance_valid(Globals.current_player)):
		return
	var screen_center_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	var player_y:float = Globals.current_player.global_position.y
	var player_direction:float = Globals.current_player.player_direction
	var new_bat:Bat = bat_scene.instantiate()
	new_bat.direction = -player_direction
	new_bat.died.connect(_on_bat_died)
	num_bats += 1
	add_sibling(new_bat)
	new_bat.global_position = Vector2(screen_center_position.x + radius * player_direction, player_y - SPAWN_HEIGHT)
	new_bat.initial_position = new_bat.global_position
	spawn_timer.start(TIME_INTERVAL)
