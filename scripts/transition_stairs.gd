class_name TransitionalStairs
extends Stairs

var next_stage:PackedScene
@export var next_stage_path:String
@export var load_position:Vector2
@export var id:int
@export_range(0, 1, 1) var target:int # 0 if bottom, 1 if top

@onready var black_screen_timer = $BlackScreenTimer

func _ready() -> void:
	super._ready()
	next_stage = load(next_stage_path)

func load_next_stage(game:Game) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game.blackout.visible = true
	game.load_next_stage(next_stage, load_position)
	reparent(game.next_stage)
	game.process_mode = Node.PROCESS_MODE_DISABLED

func switch_stage(game:Game) -> void:
	game.switch_stage()
	game.blackout.visible = false
	game.process_mode = Node.PROCESS_MODE_INHERIT

func find_corresponding_stairs() -> TransitionalStairs:
	for stair:TransitionalStairs in get_tree().get_nodes_in_group("transitional_stairs"):
			if(stair.id == id && stair != self):
				return stair
	return null

func set_player_variables(corresponding_stairs:TransitionalStairs, player:Player) -> void:
	if(is_instance_valid(corresponding_stairs)):
		player.current_stair = corresponding_stairs
		player.going_up_stairs = true
		if(player.player_direction == direction):
			player.animation_player.play("stair_up")
			player.player_direction = direction
			player.next_step = corresponding_stairs.bottom.global_position.x + Stairs.SINGLE_STAIR_HEIGHT * direction
			player.current_step = 0
			player.global_position = corresponding_stairs.bottom.global_position - Vector2(0, player.collision.shape.get_rect().size.y/2)
		else:
			player.animation_player.play("stair_down")
			player.player_direction = -direction
			player.next_step = corresponding_stairs.top.global_position.x - Stairs.SINGLE_STAIR_HEIGHT * direction
			player.current_step = corresponding_stairs.height
			player.global_position = corresponding_stairs.top.global_position - Vector2(0, player.collision.shape.get_rect().size.y/2)
	player.just_warped = true

func transition(player:Player):
	var game:Game = Globals.game_instance
	load_next_stage(game)
	black_screen_timer.start()
	await black_screen_timer.timeout
	var corresponding_stairs:TransitionalStairs = find_corresponding_stairs()
	set_player_variables(corresponding_stairs, player)
	switch_stage(game)
	queue_free()
