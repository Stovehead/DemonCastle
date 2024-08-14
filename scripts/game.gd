class_name Game
extends Node2D

var debug_mode:bool = false

var current_stage:Stage
var next_stage:Stage
var camera_on_player:bool = true
var camera_tween_position:float
var camera_tween_speed:float
var last_checkpoint:PackedScene
var last_loaded_stage:PackedScene

signal finished_camera_tween
signal stage_changed(stage:Stage)

@onready var debug_window:Window = $DebugWindow
@onready var camera:Camera2D = $Camera
@onready var music_player:AudioStreamPlayer = $MusicPlayer
@onready var test_stage:PackedScene = preload("res://scenes/castlevania_stage_1.tscn")
@onready var blackout:ColorRect = $GUI/Blackout

func update_stage_variables(stage:Stage, scene:PackedScene):
	if(stage is Stage):
		if(stage.has_checkpoint):
			last_checkpoint = scene
	stage_changed.emit(stage)

func load_stage(stage:PackedScene, load_music:bool) -> void:
	if(is_instance_valid(next_stage)):
		next_stage.queue_free()
	current_stage = stage.instantiate()
	add_child(current_stage)
	var player_spawner:PlayerSpawner
	if(current_stage is Stage):
		update_stage_variables(current_stage, stage)
		current_stage.objects.process_mode = Node.PROCESS_MODE_INHERIT
		current_stage.objects.visible = true
		player_spawner = current_stage.player_spawner
		camera.limit_right = current_stage.right_limit
		camera.limit_left = current_stage.left_limit
		camera.limit_top = current_stage.top_limit
		camera.limit_bottom = current_stage.bottom_limit
		if(load_music):
			music_player.stream = current_stage.music
			music_player.play()
	if(player_spawner is PlayerSpawner):
		if(is_instance_valid(Globals.current_player) && Globals.current_player is Player):
			Globals.current_player.reparent(current_stage)
			Globals.current_player.global_position = player_spawner.global_position
			Globals.current_player.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			Globals.current_player = player_spawner.spawn_player()

func unload_current_stage(retain_player:bool) -> void:
	if(retain_player && Globals.current_player is Player):
		Globals.current_player.reparent(self)
		Globals.current_player.process_mode = Node.PROCESS_MODE_DISABLED
	current_stage.queue_free()

func load_next_stage(stage:PackedScene, load_position:Vector2):
	current_stage.objects.visible = false
	current_stage.objects.process_mode = Node.PROCESS_MODE_DISABLED
	next_stage = stage.instantiate()
	last_loaded_stage = stage
	if(next_stage is Stage):
		next_stage.global_position = current_stage.global_position + load_position
		next_stage.objects.visible = false
		current_stage.objects.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(next_stage)

func switch_stage():
	Globals.current_player.reparent(self)
	var temp_stage = current_stage
	current_stage = next_stage
	temp_stage.queue_free()
	if(current_stage is Stage):
		update_stage_variables(current_stage, last_loaded_stage)
		current_stage.objects.process_mode = Node.PROCESS_MODE_INHERIT
		current_stage.objects.visible = true
		camera.limit_right = current_stage.right_limit + current_stage.global_position.x
		camera.limit_left = current_stage.left_limit + current_stage.global_position.x
		camera.limit_top = current_stage.top_limit + current_stage.global_position.y
		camera.limit_bottom = current_stage.bottom_limit + current_stage.global_position.y
	next_stage = null
	Globals.current_player.reparent(current_stage)

func move_camera_to_player() -> void:
	if(is_instance_valid(Globals.current_player)):
		camera.global_position = Globals.current_player.global_position

func stop_music() -> void:
	music_player.stop()

func tween_camera_x(position:float, speed:float, delta:float):
	var old_position:float = camera.global_position.x
	camera.global_position.x = camera.global_position.x + speed * delta * 60
	var camera_movement_delta:float = camera.global_position.x - old_position
	camera.global_position = camera.global_position
	if((camera.global_position.x - position) * (camera.global_position.x - position - camera_movement_delta) <= 0):
		camera.global_position.x = position
		emit_signal("finished_camera_tween")

func _enter_tree():
	Globals.game_instance = self

func _ready() -> void:
	load_stage(test_stage, true)
	if(debug_mode):
		debug_window.show()
		debug_window.get_viewport().world_2d = get_viewport().world_2d

func _physics_process(delta) -> void:
	if(camera_on_player):
		move_camera_to_player()
	else:
		if(camera.global_position.x != camera_tween_position):
			tween_camera_x(camera_tween_position, camera_tween_speed, delta)
	if(debug_mode && is_instance_valid(Globals.current_player)):
		debug_window.get_node("Camera2D").global_position = Globals.current_player.global_position

func _on_debug_window_close_requested():
	debug_window.hide()
