class_name Fireball
extends CharacterBody2D

var direction:int = 1

@onready var sprite:Sprite2D = $Sprite2D
@onready var stop_component:StopComponent = $StopComponent
@onready var flame_spawner:FlameSpawner = $FlameSpawner

func _ready() -> void:
	sprite.flip_h = direction == -1

func _physics_process(delta: float) -> void:
	if(stop_component.is_stopped):
		return
	move_and_slide()

func _on_hitbox_got_hit(attacker: Hurtbox) -> void:
	flame_spawner.spawn_flame()
	queue_free()
