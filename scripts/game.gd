class_name Game
extends Node2D

const STARTING_LIVES:int = 3

var debug_mode:bool = false

var current_stage:Stage
var next_stage:Stage
var camera_on_player:bool = true
var camera_tween_position:float
var camera_tween_speed:float
var last_checkpoint:PackedScene
var last_permanent_checkpoint:PackedScene
var last_loaded_stage:PackedScene
var num_lives:int = STARTING_LIVES
var score:int = 0
var time_left:int = 300

signal finished_camera_tween
signal stage_changed(stage:Stage)
signal player_hp_changed(new_hp:int, instant:bool)
signal enemy_hp_changed(new_hp:int, instant:bool)
signal score_changed(new_score:int)
signal time_left_changed(new_time:int)
signal hearts_changed(new_hearts:int)
signal lives_changed(new_lives:int)

@onready var debug_window:Window = $DebugWindow
@onready var camera:Camera2D = $Camera
@onready var music_player:AudioStreamPlayer = $MusicPlayer
@onready var test_stage:PackedScene = preload("res://scenes/castlevania_stage_1.tscn")
@onready var game_over_music:AudioStream = preload("res://media/music/game_over.wav")
@onready var blackout:ColorRect = $GUI/Blackout
@onready var full_blackout:ColorRect = $GUI/FullBlackout
@onready var time_timer:Timer = $TimeTimer
@onready var death_timer:Timer = $DeathTimer
@onready var black_screen_timer:Timer = $BlackScreenTimer
@onready var short_black_screen_timer:Timer = $ShortBlackScreenTimer
@onready var game_over_screen:Control = $"GUI/Game Over"

func _connect_player_signals(player:Player):
	player.hp_changed.connect(_on_player_hp_changed)
	player.hearts_changed.connect(_on_player_hearts_changed)
	player.died.connect(_on_player_died)

func update_stage_variables(stage:Stage, scene:PackedScene):
	if(stage is Stage):
		if(stage.has_checkpoint):
			last_checkpoint = scene
		if(stage.has_permanent_checkpoint):
			last_permanent_checkpoint = scene
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
			_connect_player_signals(Globals.current_player)
	camera.global_position = Globals.current_player.global_position
	camera.force_update_scroll()
	time_left = current_stage.starting_time
	time_timer.start()
	time_left_changed.emit(time_left)
	player_hp_changed.emit(16, true)
	enemy_hp_changed.emit(16, true)
	lives_changed.emit(num_lives)

func unload_current_stage(retain_player:bool) -> void:
	if(retain_player && Globals.current_player is Player):
		Globals.current_player.reparent(self)
		Globals.current_player.process_mode = Node.PROCESS_MODE_DISABLED
	current_stage.queue_free()

func load_next_stage(stage:PackedScene, load_position:Vector2):
	time_timer.stop()
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
	time_timer.start()
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
	if(Input.is_action_just_pressed("fullscreen")):
		if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if(camera_on_player):
		move_camera_to_player()
	else:
		if(camera.global_position.x != camera_tween_position):
			tween_camera_x(camera_tween_position, camera_tween_speed, delta)
	if(debug_mode && is_instance_valid(Globals.current_player)):
		debug_window.get_node("Camera2D").global_position = Globals.current_player.global_position

func _on_debug_window_close_requested():
	debug_window.hide()

func _on_time_timer_timeout():
	time_left -= 1
	time_left_changed.emit(time_left)
	if(time_left < 30):
		SfxManager.play_sound_effect(SfxManager.TIME_RUNNING_OUT)

func _on_player_hp_changed(new_hp:int):
	player_hp_changed.emit(new_hp, false)

func _on_player_hearts_changed(new_hearts:int):
	hearts_changed.emit(new_hearts)

func _on_player_died():
	music_player.stop()
	time_timer.stop()
	SfxManager.play_sound_effect(SfxManager.DEATH)
	death_timer.start()
	num_lives -= 1


func _on_death_timer_timeout():
	full_blackout.visible = true
	unload_current_stage(false)
	if(num_lives < 0):
		short_black_screen_timer.start()
	else:
		black_screen_timer.start()


func _on_black_screen_timer_timeout():
	lives_changed.emit(num_lives)
	load_stage(last_checkpoint, true)
	full_blackout.visible = false

func _on_continue_game():
	game_over_screen.process_mode = Node.PROCESS_MODE_DISABLED
	game_over_screen.visible = false
	full_blackout.visible = true
	score = 0
	score_changed.emit(score)
	num_lives = STARTING_LIVES
	last_checkpoint = last_permanent_checkpoint
	black_screen_timer.start()

func _on_end_game():
	get_tree().quit()


func _on_short_black_screen_timer_timeout():
	full_blackout.visible = false
	music_player.stream = game_over_music
	music_player.play()
	game_over_screen.visible = true
	game_over_screen.process_mode = Node.PROCESS_MODE_INHERIT
