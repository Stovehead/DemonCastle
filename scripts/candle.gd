extends Node2D

@onready var flame_spawner:FlameSpawner = $FlameSpawner
@export var item_to_drop: Flame.Items

func _ready() -> void:
	flame_spawner.item_to_drop = item_to_drop

func _on_got_hit(_attacker: Hurtbox) -> void:
	flame_spawner.spawn_flame()
	queue_free()
