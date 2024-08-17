extends PlayerSpawner

var player:Player

const TARGET:float = -128
const NEXT_STAGE_PATH:String = "res://scenes/castlevania_stage_1.tscn"

@onready var game_start_timer:Timer = $GameStartTimer

func _physics_process(delta: float) -> void:
	if(is_instance_valid(player) && player is Player):
		if(Globals.crossed_point(player.global_position.x, global_position.x + TARGET, player.get_position_delta().x) && player.animation_player.assigned_animation == "walk"):
			player.animation_player.play("back")
			player.global_position.x = global_position.x + TARGET
			player.cutscene_control = false
			game_start_timer.start()

func spawn_player() -> Player:
	player = super.spawn_player()
	player.player_has_control = false
	player.cutscene_control = true
	player.cutscene_move_direction = facing_direction
	player.cutscene_move_speed_factor = 0.5
	return player

func _on_game_start_timer_timeout() -> void:
	Globals.game_instance.full_blackout.visible = true
	Globals.game_instance.last_checkpoint = load(NEXT_STAGE_PATH)
	Globals.game_instance.black_screen_timer.start()
	Globals.game_instance.unload_current_stage(false)
	queue_free()
