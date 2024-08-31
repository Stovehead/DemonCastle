class_name MagicCrystalSpawner
extends Node2D

var child:InstancePlaceholder

@onready var spawn_timer:Timer = $SpawnTimer

func spawn(time:float) -> void:
	spawn_timer.start(time)

func _ready() -> void:
	if(get_child_count(false) == 0):
		return
	for potential_child in get_children(false):
		if(potential_child is InstancePlaceholder):
			child = potential_child
			return

func _on_spawn_timer_timeout() -> void:
	var new_magic_crystal:Node2D = child.create_instance(true)
	new_magic_crystal.global_position = global_position
