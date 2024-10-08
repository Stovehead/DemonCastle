class_name FlameSpawner
extends Node2D

@onready var flame:PackedScene = preload("res://scenes/flame.tscn")
@export var item_to_drop: Flame.Items

func spawn_flame() -> void:
	var new_flame:Flame = flame.instantiate()
	new_flame.item_to_drop = item_to_drop
	Globals.game_instance.current_stage.objects.add_child(new_flame)
	new_flame.global_position = global_position
