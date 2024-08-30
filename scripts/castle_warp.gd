extends Area2D

const PLAYER_MOVE_SPEED_FACTOR:float = 0.25

@export var next_stage_path:String
@export var target:float
@export var load_position:Vector2
@onready var sprites:Node2D = $Sprites
@onready var black_screen_timer:Timer = $BlackScreenTimer

var next_stage:PackedScene
var activated:bool = false
var finalized:bool = false
var going_towards_target:bool = false

# Makes the player start walking towards the door
func start_warp() -> void:
	if(is_instance_valid(Globals.current_player) && Globals.current_player.is_on_floor()):
		activated = true
		Globals.current_player.player_has_control = false
		Globals.current_player.cutscene_control = true
		Globals.current_player.cutscene_move_speed_factor = PLAYER_MOVE_SPEED_FACTOR
		if(Globals.current_player.global_position.x > global_position.x):
			Globals.current_player.cutscene_move_direction = -1
		else:
			Globals.current_player.cutscene_move_direction = 1

# Transitions the player to the next stage
func load_next_stage():
	finalized = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.game_instance.blackout.visible = true
	next_stage = load(next_stage_path)
	Globals.game_instance.load_next_stage(next_stage, load_position)
	reparent(Globals.game_instance.next_stage)
	Globals.game_instance.process_mode = Node.PROCESS_MODE_DISABLED
	black_screen_timer.start()
	await black_screen_timer.timeout
	Globals.game_instance.switch_stage()
	Globals.game_instance.blackout.visible = false
	Globals.game_instance.process_mode = Node.PROCESS_MODE_INHERIT
	Globals.current_player.global_position = Globals.game_instance.current_stage.player_spawner.global_position
	Globals.current_player.player_has_control = true
	Globals.current_player.cutscene_control = false
	queue_free()

# Checks if the player reached the target, warps them if they did
func check_player_reached_target() -> void:
	var player_x_position:float = Globals.current_player.global_position.x
	var player_delta_x:float = Globals.current_player.get_position_delta().x
	if(Globals.crossed_point(player_x_position, global_position.x + target, player_delta_x)):
		load_next_stage()

# Checks if the player reached the door, makes them walks towards the target if they did
func check_player_reached_door():
	if(Globals.crossed_point(Globals.current_player.global_position.x, global_position.x, Globals.current_player.get_position_delta().x)):
		SfxManager.play_sound_effect(SfxManager.WARP)
		if(Globals.current_player.global_position.x > global_position.x + target):
			Globals.current_player.cutscene_move_direction = -1
		else:
			Globals.current_player.cutscene_move_direction = 1
		going_towards_target = true
		sprites.visible = true

# Checks if the player has reached the door or the target
func check_player() -> void:
	if(going_towards_target):
		check_player_reached_target()
	else:
		check_player_reached_door()

func _physics_process(_delta):
	if(activated && !finalized):
		check_player()
	elif(has_overlapping_areas()):
		start_warp()
