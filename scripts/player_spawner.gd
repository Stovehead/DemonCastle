class_name PlayerSpawner
extends Node2D

@onready var player_scene:PackedScene = preload("res://scenes/player.tscn")
@export_range(-1, 1, 2) var facing_direction:int = 1

func spawn_player() -> Player:
	var new_player:Player = player_scene.instantiate()
	new_player.global_position = global_position
	new_player.player_direction = facing_direction
	add_sibling(new_player)
	return new_player
