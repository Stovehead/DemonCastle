extends CharacterBody2D

const SPEED:int = 52

@onready var hitbox:Hitbox = $Hitbox
@onready var health_component:HealthComponent = $HealthComponent
@onready var gravity_component:GravityComponent = $GravityComponent
@onready var sprite:Sprite2D = $Sprite2D
@onready var flame_spawner:FlameSpawner = $FlameSpawner
var facing_direction = -1

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	if(is_on_wall()):
		facing_direction = -1
		sprite.flip_h = facing_direction == -1
	if(is_on_floor()):
		velocity.x = SPEED * facing_direction
	else:
		velocity.x = 0
	move_and_slide()

func _on_hp_changed(new_hp:int) -> void:
	if(new_hp <= 0):
		flame_spawner.spawn_flame()
		queue_free()
