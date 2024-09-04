class_name CookieMonster
extends CharacterBody2D

const JUMP_X_VELOCITY:float = 42.0
const LOW_JUMP_Y_VELOCITY:float = -210.0
const HIGH_JUMP_Y_VELOCITY:float = -300.0
const JUMP_Y_OFFSET:float = -16.0
const HALF_WIDTH:float = 24.0
const TIME_TO_SPAWN_MAGIC_CRYSTAL:float = 2.533
const BOSS_FLAME_OFFSET:Vector2 = Vector2(-12, -16)
const BOSS_FLAME_SIZE:Vector2 = Vector2(8, 16)

@onready var gravity_component:GravityComponent = $GravityComponent
@onready var health_component:HealthComponent = $HealthComponent
@onready var stop_component:StopComponent = $StopComponent
@onready var high_jump_timer:Timer = $HighJumpTimer
@onready var low_jump_timer:Timer = $LowJumpTimer
@onready var fireball_timer:Timer = $FireballTimer
@onready var wait_timer:Timer = $WaitTimer
@onready var fireball_wait_timer:Timer = $FireballWaitTimer
@onready var crouch_timer:Timer = $CrouchTimer
@onready var holy_water_damage_timer:Timer = $HolyWaterDamageTimer
@onready var fireball_spawner:DraculaFireballSpawner = $DraculaFireballSpawner
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var fake_hitbox:FakeHitbox = $FakeHitbox
@onready var boss_flame_scene:PackedScene = preload("res://scenes/boss_flame.tscn")

@onready var screen_half_width:float = get_viewport_rect().size.x/2

var direction:int = 1
var jumping:bool = false
var magic_crystal_spawner:MagicCrystalSpawner

func spawn_boss_flame(spawn_position:Vector2) -> void:
	var new_boss_flame:Node2D = boss_flame_scene.instantiate()
	add_sibling(new_boss_flame)
	new_boss_flame.global_position = spawn_position

func spawn_boss_flames() -> void:
	for i in range(3):
		for j in range(3):
			spawn_boss_flame(global_position + BOSS_FLAME_OFFSET + Vector2(i*BOSS_FLAME_SIZE.x, j*BOSS_FLAME_SIZE.y))

func check_holy_waters() -> void:
	var found_holy_water:bool = false
	for area in fake_hitbox.get_overlapping_areas():
		if(area is HolyWater):
			found_holy_water = true
			break
	if(stop_component.is_frozen && !found_holy_water):
		stop_component.is_frozen = false
		stop_component.start()
		holy_water_damage_timer.stop()
	elif(!stop_component.is_frozen && found_holy_water):
		stop_component.is_frozen = true
		stop_component.stop()
		holy_water_damage_timer.start()

func face_player() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	direction = -1 if Globals.current_player.global_position.x < global_position.x else 1
	# Move and slide messes with scale.x, so we have to do this
	if(direction == -1):
		scale.y = -1
		rotation_degrees = 180
	else:
		scale.y = 1
		rotation_degrees = 0

func spawn_fireballs() -> void:
	SfxManager.play_sound_effect(SfxManager.BREATHE_FIRE)
	var target:Vector2 = global_position
	if(is_instance_valid(Globals.current_player)):
		target = Globals.current_player.global_position
	fireball_spawner.spawn_fireballs(target)

func start_jump(y_velocity:float) -> void:
	global_position.y += JUMP_Y_OFFSET
	velocity.x = JUMP_X_VELOCITY * direction
	velocity.y = y_velocity
	jumping = true

func start_high_jump() -> void:
	start_jump(HIGH_JUMP_Y_VELOCITY)

func start_low_jump() -> void:
	start_jump(LOW_JUMP_Y_VELOCITY)

func check_hit_ground() -> void:
	if(!jumping):
		return
	if(!is_on_floor()):
		return
	if(velocity.y < 0):
		return
	jumping = false
	velocity.x = 0
	animation_player.play("crouch")
	SfxManager.play_sound_effect(SfxManager.DOOR)
	crouch_timer.start()

func check_hit_edge_of_screen() -> void:
	if(!is_instance_valid(Globals.game_instance)):
		return
	var camera_position:Vector2 = Globals.game_instance.camera.get_screen_center_position()
	if(velocity.x > 0 && global_position.x + HALF_WIDTH >= camera_position.x + screen_half_width):
		velocity.x *= -1
	elif(velocity.x < 0 && global_position.x - HALF_WIDTH <= camera_position.x - screen_half_width):
		velocity.x *= -1

func process_hit() -> bool:
	var scaled_health:int = int(health_component.remaining_hp/4.0 + 0.75)
	Globals.game_instance.enemy_hp_changed.emit(scaled_health, false)
	if(health_component.remaining_hp == 0):
		spawn_boss_flames()
		if(is_instance_valid(magic_crystal_spawner)):
			magic_crystal_spawner.spawn(TIME_TO_SPAWN_MAGIC_CRYSTAL)
		queue_free()
		return true
	return false

func _ready() -> void:
	if(is_instance_valid(Globals.game_instance)):
		Globals.game_instance.enemy_hp_changed.emit(16, false)

func _physics_process(delta: float) -> void:
	check_holy_waters()
	if(stop_component.is_stopped):
		return
	face_player()
	velocity = gravity_component.apply_gravity(velocity, delta)
	check_hit_ground()
	check_hit_edge_of_screen()
	move_and_slide()

func _on_hitbox_got_hit(_attacker: Hurtbox) -> void:
	if(process_hit()):
		return
	stop_component.stun()

func _on_high_jump_timer_timeout() -> void:
	animation_player.play("high_jump")

func _on_low_jump_timer_timeout() -> void:
	animation_player.play("low_jump")

func _on_fireball_timer_timeout() -> void:
	animation_player.play("shoot_fireballs")
	animation_player.queue("idle")

func _on_wait_timer_timeout(just_did_fireball: bool) -> void:
	if(randi() % 2 == 0):
		just_did_fireball = true
	if(just_did_fireball):
		if(randi() % 2 == 0):
			high_jump_timer.start()
		else:
			low_jump_timer.start()
	else:
		fireball_timer.start()

func _on_crouch_timer_timeout() -> void:
	animation_player.play("idle")
	wait_timer.start()

func _on_holy_water_damage_timer_timeout() -> void:
	health_component._decrease_hp(1)
	process_hit()
