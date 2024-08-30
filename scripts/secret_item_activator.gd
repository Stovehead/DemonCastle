class_name SecretItemActivator
extends Area2D

@export var secret_item_spawner:SecretItemSpawner

func has_met_spawn_condition() -> bool:
	if(!is_instance_valid(secret_item_spawner)):
		return false
	if(!is_instance_valid(Globals.current_player)):
		return false
	if(!has_overlapping_areas()):
		return false
	if(!Globals.current_player.is_on_floor() || !Globals.current_player.player_has_control):
		return false
	return true

func _physics_process(_delta: float) -> void:
	if(!has_met_spawn_condition()):
		return
	secret_item_spawner.spawn()
	queue_free()
