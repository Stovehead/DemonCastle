class_name Stage
extends Node2D

@export var tile_map:TileMap
@export var objects:Node2D
@export var player_spawner:PlayerSpawner
@export var left_limit:int = 0
@export var right_limit:int = 0
@export var top_limit:int = 8
@export var bottom_limit:int = 224
@export var music:AudioStream
@export var has_checkpoint:bool
