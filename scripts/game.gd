class_name Game
extends Node2D

const STARTING_LIVES:int = 3
const MAX_LIVES:int = 99
const POINTS_1_UP_THRESHOLD = 30000
const MAX_SCORE:int = 999999 
const FADE_TIME:float = 0.25
const NUM_FLASH_FRAMES:int = 2

var debug_mode:bool = false

var showing_logos:bool = true
var load_test_stage:bool = true

var current_stage:Stage
var next_stage:Stage
var camera_on_player:bool = true
var camera_tween_position:float
var camera_tween_speed:float
var last_checkpoint:PackedScene
var last_permanent_checkpoint:PackedScene
var last_loaded_stage:PackedScene
var num_lives:int = STARTING_LIVES:
	set(new_num_lives):
		new_num_lives = clamp(new_num_lives, 0, MAX_LIVES)
		num_lives = new_num_lives
var next_score_threshold = POINTS_1_UP_THRESHOLD
var score:int = 0:
	set(new_score):
		if(new_score >= next_score_threshold):
			give_1up()
			next_score_threshold += POINTS_1_UP_THRESHOLD
		if(new_score > MAX_SCORE):
			new_score = MAX_SCORE
		score = new_score
var time_left:int = 300
var num_whip_upgrades:int = 0
var music_pause_counter:int = 0
var flashing:bool = false
var flash_accumulator:int = 0
var num_subweapon_hits:int = 0

signal finished_fade
signal finished_camera_tween
signal stage_changed(stage:Stage)
signal player_hp_changed(new_hp:int, instant:bool)
signal enemy_hp_changed(new_hp:int, instant:bool)
signal score_changed(new_score:int)
signal time_left_changed(new_time:int)
signal max_subweapons_changed(new_max_subweapons:int)
signal hearts_changed(new_hearts:int)
signal lives_changed(new_lives:int)
signal subweapon_changed(new_subweapon:int)
signal time_stopped
signal time_started
signal loaded_stage

@onready var debug_window:Window = $DebugWindow
@onready var camera:Camera2D = $Camera
@onready var music_player:AudioStreamPlayer = $MusicPlayer
@onready var test_stage:PackedScene = load("res://scenes/castlevania_stage_1_inside.tscn")
@onready var game_over_music:AudioStream = preload("res://media/music/game_over.ogg")
@onready var blackout:ColorRect = $GUI/Blackout
@onready var full_blackout:ColorRect = $GUI/FullBlackout
@onready var time_timer:Timer = $TimeTimer
@onready var death_timer:Timer = $DeathTimer
@onready var black_screen_timer:Timer = $BlackScreenTimer
@onready var short_black_screen_timer:Timer = $ShortBlackScreenTimer
@onready var game_over_screen:Control = $"GUI/Game Over"
@onready var hud:Control = $GUI/HUD
@onready var title_screen:TitleScreen = $GUI/TitleScreen
@onready var fade_rect:ColorRect = $Fade/ColorRect
@onready var flash_rect:ColorRect = $Flash/ColorRect
@onready var logos:Logos = $GUI/Logos
@onready var logos_timer:Timer = $LogosTimer
@onready var time_stop_timer:Timer = $TimeStopTimer

func clear_persistent() -> void:
	Globals.persistent_objects.clear()

func _connect_player_signals(player:Player):
	player.hp_changed.connect(_on_player_hp_changed)
	player.hearts_changed.connect(_on_player_hearts_changed)
	player.subweapon_changed.connect(_on_player_subweapon_changed)
	player.max_subweapons_changed.connect(_on_player_max_subweapons_changed)
	player.time_stopped.connect(_on_time_stopped)
	player.died.connect(_on_player_died)

func pause_music():
	music_pause_counter += 1
	music_player.stream_paused = true

func unpause_music():
	music_pause_counter -= 1
	if(music_pause_counter > 0):
		return
	music_player.stream_paused = false

func flash_screen(time:float):
	flashing = true
	flash_rect.visible = true
	await get_tree().create_timer(time, false, false).timeout
	flashing = false
	flash_rect.visible = false

func _on_time_stopped():
	SfxManager.play_sound_effect(SfxManager.STOPWATCH)
	time_stop_timer.start()
	pause_music()
	time_stopped.emit()

func update_stage_variables(stage:Stage, scene:PackedScene):
	if(stage is Stage):
		if(stage.has_checkpoint):
			last_checkpoint = scene
		if(stage.has_permanent_checkpoint):
			last_permanent_checkpoint = scene
	stage_changed.emit(stage)

func increase_subweapon_hits() -> void:
	num_subweapon_hits += 1
	num_subweapon_hits = min(num_subweapon_hits, Flame.SUBWEAPON_HITS_FOR_MULTISHOT_THRESHOLD)

func load_stage(stage:PackedScene, load_music:bool) -> void:
	clear_persistent()
	if(is_instance_valid(next_stage)):
		next_stage.queue_free()
	current_stage = stage.instantiate()
	add_child(current_stage)
	hud.visible = true
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
			Globals.current_player.player_direction = current_stage.player_spawner.facing_direction
			Globals.current_player.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			Globals.current_player = player_spawner.spawn_player()
			_connect_player_signals(Globals.current_player)
	camera.global_position = Globals.current_player.global_position
	camera.force_update_scroll()
	time_left = current_stage.starting_time
	if(current_stage.start_timer):
		time_timer.start()
	time_left_changed.emit(time_left)
	enemy_hp_changed.emit(16, true)
	lives_changed.emit(num_lives)
	Globals.current_player.emit_signals()
	loaded_stage.emit()

func unload_current_stage(retain_player:bool) -> void:
	if(retain_player && Globals.current_player is Player):
		Globals.current_player.reparent(self)
		Globals.current_player.process_mode = Node.PROCESS_MODE_DISABLED
	if(is_instance_valid(current_stage)):
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
		loaded_stage.emit()

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

func check_death_barrier() -> void:
	if(is_instance_valid(Globals.current_player) && !Globals.current_player.is_dead):
		if(Globals.current_player.global_position.y > current_stage.global_position.y + current_stage.death_barrier):
			Globals.current_player.death_barrier()

func stop_music() -> void:
	music_player.stop()

func fade_to_black(length:float):
	fade_rect.material.set_shader_parameter("start_time", ShaderTime.time)
	fade_rect.material.set_shader_parameter("fade_length", length)
	fade_rect.material.set_shader_parameter("backwards", false)
	fade_rect.visible = true
	await get_tree().create_timer(length, true, true).timeout
	finished_fade.emit()

func fade_from_black(length:float):
	fade_rect.material.set_shader_parameter("start_time", ShaderTime.time)
	fade_rect.material.set_shader_parameter("fade_length", length)
	fade_rect.material.set_shader_parameter("backwards", true)
	fade_rect.visible = true
	await get_tree().create_timer(length, true, true).timeout
	fade_rect.visible = false
	finished_fade.emit()

func tween_camera_x(new_position:float, speed:float, delta:float):
	var old_position:float = camera.global_position.x
	camera.global_position.x = camera.global_position.x + speed * delta * 60
	var camera_movement_delta:float = camera.global_position.x - old_position
	camera.global_position = camera.global_position
	if((camera.global_position.x - new_position) * (camera.global_position.x - new_position - camera_movement_delta) <= 0):
		camera.global_position.x = new_position
		finished_camera_tween.emit()

func give_1up() -> void:
	num_lives += 1
	SfxManager.play_sound_effect(SfxManager.ONE_UP)
	lives_changed.emit(num_lives)

func _enter_tree():
	Globals.game_instance = self

func _ready() -> void:
	randomize()
	if(debug_mode):
		debug_window.show()
		debug_window.get_viewport().world_2d = get_viewport().world_2d
	if(load_test_stage):
		showing_logos = false
		logos_timer.stop()
		title_screen.visible = false
		logos.visible = false
		num_lives = STARTING_LIVES
		load_stage(test_stage, true)
	else:
		fade_from_black(FADE_TIME)
		await finished_fade
		logos_timer.start()

func _process(_delta: float) -> void:
	if(flashing):
		if(flash_accumulator == NUM_FLASH_FRAMES):
			flash_rect.visible = !flash_rect.visible
			flash_accumulator = 0
		else:
			flash_accumulator += 1

func _physics_process(delta) -> void:
	if(showing_logos):
		if(!fade_rect.visible):
			if(Input.is_action_just_pressed("start")):
				logos_timer.stop()
			if(logos_timer.is_stopped()):
				if(logos.konami_logo.visible):
					fade_to_black(FADE_TIME)
					await finished_fade
					logos.konami_logo.visible = false
					logos.disclaimer.visible = true
					fade_from_black(FADE_TIME)
					await finished_fade
					logos_timer.start()
				else:
					fade_to_black(FADE_TIME)
					await finished_fade
					logos.disclaimer.visible = false
					logos.visible = false
					title_screen.visible = true
					fade_from_black(FADE_TIME)
					await finished_fade
					title_screen.process_mode = Node.PROCESS_MODE_INHERIT
					showing_logos = false
	if(debug_mode):
		debug_window.get_node("CameraOutline").global_position = camera.get_screen_center_position() - Vector2(192, 108)
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
	check_death_barrier()
	if(debug_mode && is_instance_valid(Globals.current_player)):
		debug_window.get_node("Camera2D").global_position = Globals.current_player.global_position

func _on_debug_window_close_requested():
	debug_window.hide()

func _on_time_timer_timeout():
	time_left -= 1
	time_left_changed.emit(time_left)
	if(time_left == 0):
		time_timer.stop()
		Globals.current_player.time_up = true
	elif(time_left < 30):
		SfxManager.play_sound_effect(SfxManager.TIME_RUNNING_OUT)

func _on_player_hp_changed(new_hp:int, instant:bool):
	player_hp_changed.emit(new_hp, instant)

func _on_player_hearts_changed(new_hearts:int):
	hearts_changed.emit(new_hearts)

func _on_player_subweapon_changed(new_subweapon:int) -> void:
	subweapon_changed.emit(new_subweapon)

func _on_player_max_subweapons_changed(new_max_subweapons:int) -> void:
	max_subweapons_changed.emit(new_max_subweapons)

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
	if(last_checkpoint == null):
		last_checkpoint = load("res://scenes/castlevania_intro_stage.tscn")
	load_stage(last_checkpoint, true)
	full_blackout.visible = false

func _on_continue_game():
	game_over_screen.process_mode = Node.PROCESS_MODE_DISABLED
	game_over_screen.visible = false
	full_blackout.visible = true
	score = 0
	score_changed.emit(score)
	num_lives = STARTING_LIVES
	next_score_threshold = POINTS_1_UP_THRESHOLD
	last_checkpoint = last_permanent_checkpoint
	black_screen_timer.start()

func _on_end_game():
	music_player.stop()
	game_over_screen.process_mode = Node.PROCESS_MODE_DISABLED
	game_over_screen.visible = false
	last_checkpoint = null
	title_screen.reset()
	game_over_screen.reset()
	full_blackout.visible = true
	await get_tree().create_timer(0.233, true, true).timeout
	title_screen.visible = true
	title_screen.process_mode = Node.PROCESS_MODE_INHERIT
	full_blackout.visible = false

func _on_short_black_screen_timer_timeout():
	full_blackout.visible = false
	music_player.stream = game_over_music
	music_player.play()
	game_over_screen.visible = true
	game_over_screen.process_mode = Node.PROCESS_MODE_INHERIT

func _on_title_screen_select_start() -> void:
	title_screen.visible = false
	title_screen.process_mode = Node.PROCESS_MODE_DISABLED
	full_blackout.visible = true
	num_lives = STARTING_LIVES
	black_screen_timer.start()

func _on_title_screen_select_quit() -> void:
	get_tree().quit()

func _on_title_screen_select_options() -> void:
	pass # Replace with function body.


func _on_time_stop_timer_timeout() -> void:
	unpause_music()
	time_started.emit()
