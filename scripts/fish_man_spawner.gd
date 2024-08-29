extends Node2D

const TIME_INTERVALS:Array[float] = [1.0, 3.0, 5.0]
const JUMP_HEIGHT:float = -350
const HALF_TILE_SIZE:int = 8
const SPAWN_SNAP_LENGTH:int = 32
const PLAYER_AVOID_RADIUS:float = 32

@onready var spawn_timer:Timer = $SpawnTimer
@onready var fish_man_scene:PackedScene = preload("res://scenes/fish_man.tscn")

@export var radius:float = 160
@export var max_num_fish:int = 1
@export var valid_spawn_positions:Array[float]

var num_fish:int = 0

func start_spawn_timer() -> void:
	spawn_timer.start(TIME_INTERVALS[randi()%TIME_INTERVALS.size()])

func _ready() -> void:
	start_spawn_timer()

func _on_spawn_timer_timeout() -> void:
	if(num_fish >= max_num_fish):
		return
	if(!is_instance_valid(Globals.game_instance)):
		return
	if(!is_instance_valid(Globals.current_player)):
		return
	if(!is_instance_valid(Globals.game_instance.current_stage)):
		return
	var is_valid_spawn_position:bool = false
	var spawn_position:Vector2
	var player_position = Globals.current_player.global_position
	var screen_center_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	while(!is_valid_spawn_position):
		spawn_position.x = Globals.game_instance.current_stage.global_position.x + valid_spawn_positions.pick_random()
		if(abs(spawn_position.x - player_position.x) < PLAYER_AVOID_RADIUS):
			continue
		if(spawn_position.x < screen_center_position.x - radius):
			continue
		if(spawn_position.x > screen_center_position.x + radius):
			continue
		is_valid_spawn_position = true
	var new_fish:FishMan = fish_man_scene.instantiate()
	spawn_position.y = global_position.y
	new_fish.direction = 1 if player_position.x > spawn_position.x else -1
	new_fish.custom_velocity.y = JUMP_HEIGHT
	new_fish.died.connect(_on_fish_died)
	num_fish += 1
	add_sibling(new_fish)
	new_fish.global_position = spawn_position
	start_spawn_timer()

func _on_fish_died() -> void:
	num_fish -= 1
