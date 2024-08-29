class_name FishMan
extends CharacterBody2D

signal died

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

var hit_ground:bool = false
var direction = 1
var in_air:bool = true

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
	else:
		if(!hit_ground):
			in_air = true

func _ready() -> void:
	sprite.flip_h = direction == -1

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
