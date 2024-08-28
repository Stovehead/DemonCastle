class_name Bat
extends CharacterBody2D

signal died

const AMPLITUDE:float = 8.0
const FREQUENCY:float = 2.5
const SPEED:float = 67.0

@onready var hitbox:Hitbox = $Hitbox
@onready var health_component:HealthComponent = $HealthComponent
@onready var sprite:Sprite2D = $Sprite2D
@onready var flame_spawner:FlameSpawner = $FlameSpawner
@onready var stop_component:StopComponent = $StopComponent

var initial_position:Vector2

var direction:int = 1

var time:float = 0

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		died.emit()

func die() -> void:
	flame_spawner.spawn_flame()
	queue_free()

func _ready() -> void:
	velocity.x = SPEED * direction
	sprite.flip_h = direction == 1

func _physics_process(delta: float) -> void:
	if(stop_component.is_stopped):
		return
	global_position.y = initial_position.y + sin(time * FREQUENCY) * AMPLITUDE
	time += delta
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health_component.remaining_hp = 0
	die()

func _on_hp_changed(new_hp: int) -> void:
	if(new_hp > 0):
		return
	die()
