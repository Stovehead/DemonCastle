extends Node2D

const INITIAL_TIME_INTERVAL:float = 0.9
const TIME_INTERVAL:float = 4.25
const JUMP_HEIGHT:float = -360
const HALF_TILE_SIZE:int = 8
const SPAWN_SNAP_LENGTH:int = 32
const PLAYER_AVOID_RADIUS:float = 32

@onready var spawn_timer:Timer = $SpawnTimer
@onready var queued_spawn_timer:Timer = $QueuedSpawnTimer
@onready var fish_man_scene:PackedScene = preload("res://scenes/fish_man.tscn")

@export var radius:float = 160
@export var max_num_fish:int = 1
@export var valid_spawn_positions:Array[float]

var num_fish:int = 0
var fish_spawn_queued:bool = true

func spawn_fish() -> void:
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
	if(spawn_position.x == Globals.game_instance.current_stage.global_position.x + 224 || spawn_position.x == Globals.game_instance.current_stage.global_position.x + 288):
		# This is a dumb fucking solution, get rid of this eventually
		new_fish.middle_ray.enabled = false
	spawn_timer.start(TIME_INTERVAL)

func _ready() -> void:
	spawn_timer.start(INITIAL_TIME_INTERVAL)

func _on_spawn_timer_timeout() -> void:
	if(num_fish >= max_num_fish):
		fish_spawn_queued = true
		return
	spawn_fish()

func _on_fish_died() -> void:
	num_fish -= 1
	if(fish_spawn_queued):
		queued_spawn_timer.start()
		fish_spawn_queued = false

func _on_queued_spawn_timer_timeout() -> void:
	spawn_fish()
