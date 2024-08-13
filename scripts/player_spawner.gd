class_name PlayerSpawner
extends Node2D

@onready var player_scene:PackedScene = preload("res://scenes/player.tscn")

func spawn_player() -> Player:
	var new_player:Player = player_scene.instantiate()
	new_player.global_position = global_position
	add_sibling(new_player)
	return new_player
