extends Area2D

@export var next_stage_path:String
@export var target:float
@export var load_position:Vector2
@onready var sprites:Node2D = $Sprites
@onready var black_screen_timer:Timer = $BlackScreenTimer

var next_stage:PackedScene
var activated:bool = false
var finalized:bool = false
var going_towards_target:bool = false

func _physics_process(delta):
	if(activated && !finalized):
		if(going_towards_target):
			if(Globals.crossed_point(Globals.current_player.global_position.x, global_position.x + target, Globals.current_player.get_position_delta().x)):
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
		else:
			if(Globals.crossed_point(Globals.current_player.global_position.x, global_position.x, Globals.current_player.get_position_delta().x)):
				SfxManager.play_sound_effect(SfxManager.WARP)
				if(Globals.current_player.global_position.x > global_position.x + target):
					Globals.current_player.cutscene_move_direction = -1
				else:
					Globals.current_player.cutscene_move_direction = 1
				going_towards_target = true
				sprites.visible = true
	elif(has_overlapping_areas()):
		if(is_instance_valid(Globals.current_player) && Globals.current_player is Player && Globals.current_player.is_on_floor()):
			activated = true
			Globals.current_player.player_has_control = false
			Globals.current_player.cutscene_control = true
			Globals.current_player.cutscene_move_speed_factor = 0.25
			if(Globals.current_player.global_position.x > global_position.x):
				Globals.current_player.cutscene_move_direction = -1
			else:
				Globals.current_player.cutscene_move_direction = 1
