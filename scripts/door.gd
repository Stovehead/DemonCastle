extends StaticBody2D

const CAMERA_UNLOCKED_LIMIT:int = 10000000
const TWEEN_SPEED:float = 80.0

@export_range(-1, 1, 2) var direction:int = 1
@export var next_stage_path:String
@export var next_stage_position:Vector2

@onready var raycast:RayCast2D = $RayCast
@onready var collision:CollisionShape2D = $Collision
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var start_walk_timer:Timer = $StartWalkTimer
@onready var start_scroll_timer:Timer = $StartScrollTimer

var next_stage:PackedScene
var player_moving:bool = false
var edge_of_next_screen:float

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_stage_path)
	raycast.target_position.x *= direction
	scale.x = direction

# Checks if the player reached the door, starts the door sequence if they did
func check_player_reached_door() -> void:
	if(is_instance_valid(Globals.current_player) && raycast.is_colliding()):
		if(Globals.current_player is Player && Globals.current_player.is_on_floor()):
			next_stage = ResourceLoader.load_threaded_get(next_stage_path)
			assert(next_stage != null, "Failed to load stage")
			process_mode = Node.PROCESS_MODE_ALWAYS
			raycast.enabled = false
			# Remove control from player
			Globals.current_player.player_has_control = false
			Globals.current_player.cutscene_control = false
			# Load next stage
			Globals.game_instance.load_next_stage(next_stage, next_stage_position)
			# Reparent self so that it doesn't get unloaded early
			reparent(Globals.game_instance.next_stage)
			#await get_tree().create_timer(0.2, true, true).timeout
			# Move camera back into the limits
			Globals.game_instance.camera.global_position = Globals.game_instance.camera.get_screen_center_position()
			# Remove camera limits so it can scroll
			Globals.game_instance.camera.limit_right = CAMERA_UNLOCKED_LIMIT
			Globals.game_instance.camera.limit_left = -CAMERA_UNLOCKED_LIMIT
			# Move camera to door position
			Globals.game_instance.camera_on_player = false
			var camera_tween:Tween = get_tree().create_tween()
			camera_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			var camera_tween_time:float = abs(global_position.x - Globals.game_instance.camera.global_position.x)/TWEEN_SPEED
			camera_tween.tween_property(Globals.game_instance.camera, "global_position:x", global_position.x, camera_tween_time)
			await camera_tween.finished
			SfxManager.play_sound_effect(SfxManager.DOOR)
			animation_player.play("open")
			start_walk_timer.start()
			await start_walk_timer.timeout
			# Move player to the next stage
			Globals.current_player.cutscene_control = true
			Globals.current_player.cutscene_move_direction = direction
			Globals.current_player.cutscene_move_speed_factor = 1
			# Make sure the player can't collide with the door
			Globals.current_player.set_collision_mask_value(5, false)
			player_moving = true
			edge_of_next_screen = Globals.game_instance.next_stage.global_position.x + get_viewport_rect().size.x/2
			if(direction == 1):
				edge_of_next_screen += Globals.game_instance.next_stage.left_limit
			else:
				edge_of_next_screen += Globals.game_instance.next_stage.right_limit

# Checks if the player reached the next stage, finishes the door sequence if they did
func check_player_reached_target() -> void:
	var player_x_position:float = Globals.current_player.global_position.x
	var player_spawner_x_position:float = Globals.game_instance.next_stage.player_spawner.global_position.x
	var player_delta_x:float = Globals.current_player.get_position_delta().x 
	if(Globals.crossed_point(player_x_position, player_spawner_x_position, player_delta_x)):
		# Stop the player
		player_moving = false
		# Move the player to the correct position if they went too fast
		Globals.current_player.global_position.x = Globals.game_instance.next_stage.player_spawner.global_position.x
		Globals.current_player.cutscene_control = false
		SfxManager.play_sound_effect(SfxManager.DOOR)
		animation_player.play("close")
		start_scroll_timer.start()
		await start_scroll_timer.timeout
		# Move the camera to the next stage
		var camera_tween:Tween = get_tree().create_tween()
		camera_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		var camera_tween_time:float = abs(edge_of_next_screen - Globals.game_instance.camera.global_position.x)/TWEEN_SPEED
		camera_tween.tween_property(Globals.game_instance.camera, "global_position:x", edge_of_next_screen, camera_tween_time)
		await camera_tween.finished
		# Make it so that the player can collide with doors again
		Globals.current_player.set_collision_mask_value(5, true)
		# Give control back to the player
		Globals.current_player.player_has_control = true
		Globals.game_instance.switch_stage()
		Globals.game_instance.camera_on_player = true
		# This is probably unnecessary
		process_mode = Node.PROCESS_MODE_INHERIT
		queue_free()

func _physics_process(_delta: float) -> void:
	if(player_moving):
		check_player_reached_target()
	else:
		check_player_reached_door()
