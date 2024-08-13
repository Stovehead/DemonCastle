class_name TransitionalStairs
extends Stairs

@export var target_step:int = 1
@export var top_stage:PackedScene
@export var bottom_stage:PackedScene

@onready var black_screen_timer = $BlackScreenTimer

func transition(player:Player):
	var next_stage:PackedScene
	if(player.player_direction == direction):
		next_stage = top_stage
	else:
		next_stage = bottom_stage
	process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.game_instance.blackout.visible = true
	Globals.game_instance.process_mode = Node.PROCESS_MODE_DISABLED
	black_screen_timer.start()
	await black_screen_timer.timeout
	
