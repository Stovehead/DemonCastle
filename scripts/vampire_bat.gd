extends CharacterBody2D

enum States{
	PERCH,
	FLY,
	SWOOP,
	WAIT,
}

const MUSIC_FADE_TIME:float = 2.7
const FLY_X_RANGE:Vector2 = Vector2(-160, 160)
const FLY_Y_RANGE:Vector2 = Vector2(-26, 36)
const FLY_SPEED:float = 66.67
const WAIT_TIMES:Array[float] = [0.533, 1.02, 2.05]
const SWOOP_SPEEDS:Array[float] = [90.0, 120.0, 150.0]
const SWOOP_TIMES:Array[float] = [1.5, 1.8, 2.2]
const MIN_Y_POSITION:float = 32.0
const MAX_Y_POSITION:float = 216.0
const REVERSE_GRAVITY:float = 60.0
const HALF_WIDTH:float = 24
const WAIT_AFTER_FIREBALL_TIME:float = 0.4
const FIREBALL_SPEED:float = 105.0
const BOSS_FLAME_SIZE:Vector2 = Vector2(8, 16)
const BOSS_FLAME_OFFSET:Vector2 = Vector2(-12, -16)
const TIME_TO_SPAWN_MAGIC_CRYSTAL:float = 2.067

@export var magic_crystal_spawner:MagicCrystalSpawner

@onready var hitbox:Hitbox = $Hitbox
@onready var health_component:HealthComponent = $HealthComponent
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite2D
@onready var stop_component:StopComponent = $StopComponent
@onready var start_flying_timer:Timer = $StartFlyingTimer
@onready var wait_timer:Timer = $WaitTimer
@onready var swoop_timer:Timer = $SwoopTimer
@onready var fireball_scene:PackedScene = preload("res://scenes/fireball.tscn")
@onready var boss_flame_scene:PackedScene = preload("res://scenes/boss_flame.tscn")

var current_state:States = States.PERCH
var fly_target:Vector2

func apply_reverse_gravity(delta:float) -> void:
	velocity.y -= REVERSE_GRAVITY * delta

func start_flying() -> void:
	current_state = States.FLY
	var camera_position = Globals.game_instance.camera.get_screen_center_position()
	fly_target = camera_position + Vector2(randf_range(FLY_X_RANGE.x, FLY_X_RANGE.y), randf_range(FLY_Y_RANGE.x, FLY_Y_RANGE.y))
	velocity = global_position.direction_to(fly_target) * FLY_SPEED

func start_swooping() -> void:
	current_state = States.SWOOP
	var player_position = Globals.current_player.global_position
	velocity = global_position.direction_to(player_position) * SWOOP_SPEEDS.pick_random()
	swoop_timer.start(SWOOP_TIMES.pick_random())

func start_wait() -> void:
	velocity = Vector2.ZERO
	current_state = States.WAIT
	wait_timer.start(WAIT_TIMES.pick_random())

func check_reached_fly_target() -> void:
	if(Globals.crossed_point(global_position.x, fly_target.x, get_position_delta().x)):
		start_wait()

func check_reached_screen_edge() -> void:
	var camera_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	var screen_half_width:float = get_viewport_rect().size.x/2.0
	var current_stage_position:Vector2 = Globals.game_instance.current_stage.global_position
	if(global_position.y < current_stage_position.y + MIN_Y_POSITION || global_position.y > current_stage_position.y + MAX_Y_POSITION):
		swoop_timer.stop()
		start_flying()
	elif(global_position.x - HALF_WIDTH < camera_position.x - screen_half_width || global_position.x + HALF_WIDTH > camera_position.x + screen_half_width):
		velocity.x *= -1

func spawn_boss_flame(spawn_position:Vector2) -> void:
	var new_boss_flame:Node2D = boss_flame_scene.instantiate()
	add_sibling(new_boss_flame)
	new_boss_flame.global_position = spawn_position

func spawn_boss_flames() -> void:
	for i in range(3):
		for j in range(2):
			spawn_boss_flame(global_position + BOSS_FLAME_OFFSET + Vector2(i*BOSS_FLAME_SIZE.x, j*BOSS_FLAME_SIZE.y))

func _physics_process(delta: float) -> void:
	if(stop_component.is_stopped):
		return
	match(current_state):
		States.PERCH, States.WAIT:
			pass
		States.FLY:
			check_reached_fly_target()
		States.SWOOP:
			apply_reverse_gravity(delta)
			check_reached_screen_edge()
	move_and_slide()

func _on_screen_locked() -> void:
	start_flying_timer.start()
	Globals.game_instance.fade_out_music(MUSIC_FADE_TIME)
	await Globals.game_instance.finished_music_fade
	Globals.game_instance.music_player.stream = Globals.game_instance.boss_music
	if(!Globals.game_instance.music_player.stream_paused):
		Globals.game_instance.music_player.play()

func _on_start_flying_timer_timeout() -> void:
	animation_player.play("fly")
	start_flying()

func _on_hitbox_got_hit(_attacker: Hurtbox) -> void:
	Globals.game_instance.enemy_hp_changed.emit(health_component.remaining_hp, false)
	if(health_component.remaining_hp <= 0):
		spawn_boss_flames()
		if(is_instance_valid(magic_crystal_spawner)):
			magic_crystal_spawner.spawn(TIME_TO_SPAWN_MAGIC_CRYSTAL)
		queue_free()
		return
	stop_component.stun()

func _on_wait_timer_timeout() -> void:
	if(Globals.current_player.global_position.y < global_position.y):
		var new_fireball:Fireball = fireball_scene.instantiate()
		var player_position = Globals.current_player.global_position
		new_fireball.velocity =  global_position.direction_to(player_position) * FIREBALL_SPEED
		new_fireball.direction = 1 if global_position.x < player_position.x else -1
		add_sibling(new_fireball)
		new_fireball.global_position = global_position
		swoop_timer.start(WAIT_AFTER_FIREBALL_TIME)
	else:
		start_swooping()

func _on_swoop_timer_timeout() -> void:
	start_flying()
