extends StaticBody2D

@export_range(-1, 1, 2) var direction:int = 1
@export var next_stage:PackedScene
@export var next_stage_position:Vector2

@onready var raycast:RayCast2D = $RayCast
@onready var collision:CollisionShape2D = $Collision
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var start_walk_timer:Timer = $StartWalkTimer
@onready var start_scroll_timer:Timer = $StartScrollTimer

var player_moving:bool = false
var edge_of_next_screen:float

func _ready():
	raycast.target_position.x *= direction
	scale.x = direction

func _process(delta):
	if(player_moving):
		if((Globals.current_player.global_position.x-Globals.game_instance.next_stage.player_spawner.global_position.x)*(Globals.current_player.global_position.x-Globals.game_instance.next_stage.player_spawner.global_position.x-Globals.current_player.get_position_delta().x) <= 0):
			player_moving = false
			Globals.current_player.global_position.x = Globals.game_instance.next_stage.player_spawner.global_position.x
			Globals.current_player.cutscene_control = false
			SfxManager.play_sound_effect(SfxManager.DOOR)
			animation_player.play("close")
			start_scroll_timer.start()
			await start_scroll_timer.timeout
			Globals.game_instance.camera_tween_position = edge_of_next_screen
			await Globals.game_instance.finished_camera_tween
			collision.disabled = false
			Globals.current_player.player_has_control = true
			Globals.game_instance.switch_stage()
			Globals.game_instance.camera_on_player = true
			process_mode = Node.PROCESS_MODE_INHERIT
			set_script(null)
	else:
		if(is_instance_valid(Globals.current_player) && raycast.is_colliding()):
			if(Globals.current_player is Player && Globals.current_player.is_on_floor()):
				process_mode = Node.PROCESS_MODE_ALWAYS
				collision.disabled = true
				raycast.enabled = false
				Globals.current_player.player_has_control = false
				Globals.current_player.cutscene_control = false
				Globals.game_instance.camera.global_position = Globals.game_instance.camera.get_screen_center_position()
				Globals.game_instance.camera.limit_right = 10000000
				Globals.game_instance.camera.limit_left = -10000000
				Globals.game_instance.load_next_stage(next_stage, next_stage_position)
				reparent(Globals.game_instance.next_stage.objects)
				Globals.game_instance.camera_on_player = false
				Globals.game_instance.camera_tween_position = global_position.x
				Globals.game_instance.camera_tween_speed = direction
				await Globals.game_instance.finished_camera_tween
				SfxManager.play_sound_effect(SfxManager.DOOR)
				animation_player.play("open")
				start_walk_timer.start()
				await start_walk_timer.timeout
				Globals.current_player.cutscene_control = true
				Globals.current_player.cutscene_move_direction = direction
				Globals.current_player.cutscene_move_speed_factor = 1
				player_moving = true
				edge_of_next_screen = Globals.game_instance.next_stage.global_position.x + get_viewport_rect().size.x/2
				if(direction == 1):
					edge_of_next_screen += Globals.game_instance.next_stage.left_limit
				else:
					edge_of_next_screen += Globals.game_instance.next_stage.right_limit
