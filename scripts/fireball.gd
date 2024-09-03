class_name Fireball
extends CharacterBody2D

var direction:int = 1
var damage:int = 2

@onready var sprite:Sprite2D = $Sprite2D
@onready var stop_component:StopComponent = $StopComponent
@onready var flame_spawner:FlameSpawner = $FlameSpawner
@onready var hurtbox:Hurtbox = $Hurtbox

func _ready() -> void:
	sprite.flip_h = direction == -1
	hurtbox.damage = damage

func _physics_process(_delta: float) -> void:
	if(stop_component.is_stopped):
		return
	move_and_slide()

func _on_hitbox_got_hit(_attacker: Hurtbox) -> void:
	flame_spawner.spawn_flame()
	queue_free()
