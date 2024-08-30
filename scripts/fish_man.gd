class_name FishMan
extends CharacterBody2D

signal died

const SPEED:float = 45.0
const FIREBALL_INTERVALS:Array[float] = [2.4, 2.0, 1.33]
const FIREBALL_SPEED:float = 105.0
const FIREBALL_SPAWN_OFFSET:Vector2 = Vector2(0, -8)

var custom_velocity:Vector2 = Vector2(0, 0)

@onready var hitbox:Hitbox = $Hitbox
@onready var health_component:HealthComponent = $HealthComponent
@onready var gravity_component:GravityComponent = $GravityComponent
@onready var sprite:Sprite2D = $Sprite2D
@onready var flame_spawner:FlameSpawner = $FlameSpawner
@onready var stop_component:StopComponent = $StopComponent
@onready var left_ray:RayCast2D = $Left
@onready var middle_ray:RayCast2D = $Middle
@onready var right_ray:RayCast2D = $Right
@onready var start_walk_timer:Timer = $StartWalkTimer
@onready var attack_timer:Timer = $AttackTimer
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var fireball_scene:PackedScene = preload("res://scenes/fireball.tscn")

var hit_ground:bool = false
var direction = 1
var in_air:bool = true

func set_direction() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	if(Globals.current_player.global_position.x < global_position.x):
		direction = -1
	else:
		direction = 1
	sprite.flip_h = direction == -1

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		died.emit()

func check_is_in_ground() -> bool:
	left_ray.force_raycast_update()
	if(middle_ray.enabled):
		middle_ray.force_raycast_update()
	right_ray.force_raycast_update()
	var counter:int = 0
	if(left_ray.is_colliding()):
		counter += 1
	if(middle_ray.is_colliding()):
		counter += 1
	if(right_ray.is_colliding()):
		counter += 1
	return counter >= 2

func move(delta:float) -> void:
	hit_ground = false
	global_position.x += custom_velocity.x * delta
	global_position.y += custom_velocity.y * delta
	if(custom_velocity.y > 0):
		if(check_is_in_ground()):
			custom_velocity.y = 0
			global_position.y -= 1
			hit_ground = true
		while(check_is_in_ground()):
			global_position.y -= 1
		global_position.y = floor(global_position.y)
		global_position.y += 1

func check_is_on_ground() -> void:
	if(in_air):
		if(hit_ground):
			in_air = false
			SfxManager.play_sound_effect_no_overlap(SfxManager.FALL)
			start_walk_timer.start()
	else:
		if(!hit_ground):
			in_air = true
			attack_timer.paused = true
			animation_player.pause()
			custom_velocity.x = 0

func start_attack_timer() -> void:
	attack_timer.start(FIREBALL_INTERVALS.pick_random())

func spawn_fireball() -> void:
	var new_fireball:Fireball = fireball_scene.instantiate()
	new_fireball.direction = direction
	new_fireball.velocity.x = FIREBALL_SPEED * direction
	add_sibling(new_fireball)
	new_fireball.global_position = global_position + FIREBALL_SPAWN_OFFSET

func start_walking() -> void:
	set_direction()
	animation_player.play("walk")
	custom_velocity.x = SPEED * direction
	if(attack_timer.paused):
		attack_timer.paused = false
	else:
		start_attack_timer()

func _ready() -> void:
	sprite.flip_h = direction == -1
	attack_timer.paused = true
	animation_player.pause()

func _physics_process(delta: float) -> void:
	if(stop_component.is_stopped):
		return
	check_is_on_ground()
	custom_velocity = gravity_component.apply_gravity(custom_velocity, delta)
	velocity = custom_velocity
	move(delta)

func _on_hp_changed(new_hp: int) -> void:
	if(new_hp > 0):
		return
	flame_spawner.spawn_flame()
	queue_free()

func _on_start_walk_timer_timeout() -> void:
	animation_player.play()
	start_walking()

func _on_attack_timer_timeout() -> void:
	custom_velocity.x = 0
	animation_player.play("attack")
